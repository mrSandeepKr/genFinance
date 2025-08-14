import Foundation

struct Investment {
    let uuid: UUID
    let name: String
    let lumpsumAmount: Double
    let monthlyContribution: Double
    let expectedReturn: Double
    let expectedIncrease: Double
    
    init(uuid: UUID = UUID(),
         name: String,
         lumpsumAmount: Double,
         monthlyContribution: Double,
         expectedReturn: Double,
         expectedIncrease: Double) {
        self.uuid = uuid
        self.name = name
        self.lumpsumAmount = lumpsumAmount
        self.monthlyContribution = monthlyContribution
        self.expectedReturn = expectedReturn
        self.expectedIncrease = expectedIncrease
    }
}

struct FireCalculationResult {
    let requiredCorpus: Double
    let projectedCorpus: Double
    let yearlyData: [YearlyCorpusPoint]
}

struct YearlyInvestmentPoint {
    let year: Int
    let totalValue: Double
}

struct YearlyCorpusPoint {
    let year: Int
    let totalCorpus: Double
}

/// Engine to perform FIRE calculations
struct FireCalculatorFactory {
    /// Calculates the required corpus and projected corpus at retirement
    /// - Parameters:
    ///   - monthlyExpense: Expected monthly expense in retirement (Double)
    ///   - withdrawalRate: Safe withdrawal rate (as percent, e.g. 4 for 4%)
    ///   - currentAge: Current age of the user
    ///   - retirementAge: Age at which user plans to retire
    ///   - investments: Array of investment objects
    ///   - inflationPercent: Expected annual inflation (percent)
    /// - Returns: FireCalculationResult
    static func calculate(
        monthlyExpense: Double,
        expectedWithdrawalRateFromCorpus: Double,
        currentAge: Int,
        retirementAge: Int,
        investments: [Investment],
        inflationPercent: Double
    ) -> FireCalculationResult {
        
        let yearsToRetirement = Double(retirementAge - currentAge)
        
        // 1. Required corpus
        let swr = expectedWithdrawalRateFromCorpus / 100.0
        let inflation = inflationPercent / 100.0
        let inflatedMonthlyExpense = monthlyExpense * pow(1.0 + inflation, yearsToRetirement)
        let inflatedAnnualExpense = inflatedMonthlyExpense * 12
        let requiredCorpus = inflatedAnnualExpense / swr
        
        // 2. Calculate each investment separately
        let investmentResults = investments.map { investment in
            calculateInvestmentGrowth(
                investment: investment,
                yearsToRetirement: Int(yearsToRetirement),
                currentAge: currentAge
            )
        }
        
        // 3. Calculate total projected corpus
        let projectedCorpus = investmentResults.reduce(0) { $0 + $1.projectedValue }
        
        // 4. Generate yearly corpus data
        let yearlyData = generateYearlyCorpusData(
            investmentResults: investmentResults,
            yearsToRetirement: Int(yearsToRetirement),
            currentAge: currentAge
        )
        
        return FireCalculationResult(
            requiredCorpus: requiredCorpus,
            projectedCorpus: projectedCorpus,
            yearlyData: yearlyData
        )
    }
    
    /// Calculates the growth of a single investment
    private static func calculateInvestmentGrowth(
        investment: Investment,
        yearsToRetirement: Int,
        currentAge: Int
    ) -> InvestmentResult {
        let annualReturn = investment.expectedReturn / 100.0
        let increaseRate = investment.expectedIncrease / 100.0
        
        // Project lumpsum amount
        var lumpsumAmount = investment.lumpsumAmount
        var yearlyData: [YearlyInvestmentPoint] = []
        var contributionBalance = 0.0
        var yearlyContribution = investment.monthlyContribution * 12.0
        
        for year in 0..<yearsToRetirement {
            lumpsumAmount *= (1.0 + annualReturn)
            contributionBalance *= (1.0 + annualReturn)
            contributionBalance += yearlyContribution
            yearlyContribution *= (1.0 + increaseRate)
            
            yearlyData.append(YearlyInvestmentPoint(
                year: year + 1 + currentAge,
                totalValue: lumpsumAmount + contributionBalance
            ))
        }
        
        let projectedValue = lumpsumAmount + contributionBalance
        
        return InvestmentResult(
            investment: investment,
            projectedValue: projectedValue,
            yearlyData: yearlyData
        )
    }
    
    /// Generates combined yearly corpus data from all investments
    private static func generateYearlyCorpusData(
        investmentResults: [InvestmentResult],
        yearsToRetirement: Int,
        currentAge: Int
    ) -> [YearlyCorpusPoint] {
        var yearlyCorpusData: [YearlyCorpusPoint] = []
        
        for year in 0..<yearsToRetirement {
            let currentYear = year + 1 + currentAge
            var totalCorpus = 0.0
            
            for result in investmentResults {
                if let yearData = result.yearlyData.first(where: { $0.year == currentYear }) {
                    totalCorpus += yearData.totalValue
                }
            }
            
            yearlyCorpusData.append(YearlyCorpusPoint(
                year: currentYear,
                totalCorpus: totalCorpus
            ))
        }
        
        return yearlyCorpusData
    }
}

fileprivate struct InvestmentResult {
    let investment: Investment
    let projectedValue: Double
    let yearlyData: [YearlyInvestmentPoint]
}
