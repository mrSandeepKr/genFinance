import Foundation

/// Struct to hold the result of FIRE calculation
struct FireCalculationResult {
    let requiredCorpus: Double
    let projectedCorpus: Double
}

/// Engine to perform FIRE calculations
struct FireCalculatorEngine {
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
    ///   - currentPfContribution: Current montly PF contribution (Double)
    ///   - currentPfBalance: Current PF balance (Double)
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
        currentPfContribution: Double,
        currentPfBalance: Double,
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
        
        // 2c. Project PF
        
        let pfMonthlyRate = pow(1.0 + 0.085, 1.0/12.0) - 1
        var pfBalance = currentPfBalance
        var monthlyPfContribution = currentPfContribution
        
        for _ in 0..<Int(yearsToRetirement) {
            for _ in 0..<12 {
                pfBalance *= (1.0 + pfMonthlyRate)
                pfBalance += monthlyPfContribution
            }
            monthlyPfContribution *= (1 + (expectedSalaryIncrease / 100.00))
        }
        
        // 3. Total
        let projectedCorpus = projectedSavings + sipBalance + pfBalance
        
        return FireCalculationResult(requiredCorpus: requiredCorpus, projectedCorpus: projectedCorpus)
    }

}
