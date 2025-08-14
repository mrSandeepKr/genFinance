import Foundation

/// Struct to hold the result of FIRE calculation
struct FireCalculationResult {
    let requiredCorpus: Double
    let projectedCorpus: Double
    let yearlyData: [YearlyCorpusPoint]
}

struct YearlyCorpusPoint {
    let year: Int
    let totalCorpus: Double
    let savings: Double
    let sip: Double
}

/// Engine to perform FIRE calculations
struct FireCalculatorFactory {
    /// Calculates the required corpus and projected corpus at retirement
    /// - Parameters:
    ///   - monthlyExpense: Expected monthly expense in retirement (Double)
    ///   - withdrawalRate: Safe withdrawal rate (as percent, e.g. 4 for 4%)
    ///   - currentAge: Current age of the user
    ///   - retirementAge: Age at which user plans to retire
    ///   - currentSavings: Current savings (Double)
    ///   - monthlySIP: Monthly SIP investment (Double)
    ///   - expectedSIPIncrease: Expected annual increase in SIP (percent, e.g. 5 for 5%)
    ///   - expectedReturn: Expected annual return on investments (percent, e.g. 12 for 12%)
    ///   - currentSalary: Current annual salary (Double)
    ///   - inflationPercent: Expected annual inflation (percent)
    /// - Returns: FireCalculationResult
    static func calculate(
        monthlyExpense: Double,
        expectedWithdrawalRateFromCorpus: Double,
        currentAge: Int,
        retirementAge: Int,
        currentSavings: Double,
        monthlySIP: Double,
        expectedSIPIncrease: Double,
        expectedReturn: Double,
        currentSalary: Double,
        expectedSalaryIncrease: Double,
        inflationPercent: Double
    ) -> FireCalculationResult {
        
        let yearsToRetirement = Double(retirementAge - currentAge)
        let annualReturn = expectedReturn / 100.0
        
        // 1. Required corpus
        let swr = expectedWithdrawalRateFromCorpus / 100.0
        let inflation = inflationPercent / 100.0
        let inflatedMonthlyExpense = monthlyExpense * pow(1.0 + inflation, yearsToRetirement)
        let inflatedAnnualExpense = inflatedMonthlyExpense * 12
        let requiredCorpus = inflatedAnnualExpense / swr
        
        // 2a. Project current savings
        let projectedSavings = currentSavings * pow(1.0 + annualReturn, yearsToRetirement)
        
        // 2b. Project SIP
        
        let sipIncrease = expectedSIPIncrease / 100.0
        var sipBalance = 0.0
        var yearlySip = monthlySIP * 12.0
        
        for _ in 0..<Int(yearsToRetirement) {
            // Grow the sipBalance
            sipBalance *= (1.0 + annualReturn)
            
            // Invest the yearly amount
            sipBalance += yearlySip
            
            // Inc the yearlySip
            yearlySip *= (1.0 + sipIncrease)
        }
        
        // 3. Total
        let projectedCorpus = projectedSavings + sipBalance
        
        return FireCalculationResult(requiredCorpus: requiredCorpus,
                                     projectedCorpus: projectedCorpus,
                                     yearlyData: yearlyCorpusProjection(monthlyExpense: monthlyExpense,
                                                                        expectedWithdrawalRateFromCorpus: expectedWithdrawalRateFromCorpus,
                                                                        currentAge: currentAge,
                                                                        retirementAge: retirementAge,
                                                                        currentSavings: currentSavings,
                                                                        monthlySIP: monthlySIP,
                                                                        expectedSIPIncrease: expectedSIPIncrease,
                                                                        expectedReturn: expectedReturn,
                                                                        currentSalary: currentSalary,
                                                                        expectedSalaryIncrease: expectedSalaryIncrease,
                                                                        inflationPercent: inflationPercent))
    }



    private static func yearlyCorpusProjection(
        monthlyExpense: Double,
        expectedWithdrawalRateFromCorpus: Double,
        currentAge: Int,
        retirementAge: Int,
        currentSavings: Double,
        monthlySIP: Double,
        expectedSIPIncrease: Double,
        expectedReturn: Double,
        currentSalary: Double,
        expectedSalaryIncrease: Double,
        inflationPercent: Double
    ) -> [YearlyCorpusPoint] {
        let yearsToRetirement = Int(retirementAge - currentAge)
        let annualReturn = expectedReturn / 100.0
        let sipIncrease = expectedSIPIncrease / 100.0
        var savings = currentSavings
        var sipBalance = 0.0
        var yearlySip = monthlySIP * 12.0
        var yearlyData: [YearlyCorpusPoint] = []
        for year in 0..<yearsToRetirement {
            // Grow savings
            savings *= (1.0 + annualReturn)
            // Grow SIP
            sipBalance *= (1.0 + annualReturn)
            sipBalance += yearlySip
            yearlySip *= (1.0 + sipIncrease)
            let total = savings + sipBalance
            yearlyData.append(YearlyCorpusPoint(
                year: year + 1 + currentAge,
                totalCorpus: total,
                savings: savings,
                sip: sipBalance
            ))
        }
        return yearlyData
    }

}

