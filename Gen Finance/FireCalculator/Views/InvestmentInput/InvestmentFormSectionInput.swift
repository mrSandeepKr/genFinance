//
//  InvestmentInput.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 14/08/25.
//

import Foundation

struct InvestmentFormSectionInput: Codable {
    
    var uuid: UUID
    var name: String
    var lumpsumAmount: String
    var monthlyContribution: String
    var expectedReturn: String
    var expectedIncrease: String
    
    init(uuid: UUID = UUID(),
         name: String,
         lumpsumAmount: String,
         monthlyContribution: String,
         expectedReturn: String,
         expectedIncrease: String) {
        self.uuid = uuid
        self.name = name
        self.lumpsumAmount = lumpsumAmount
        self.monthlyContribution = monthlyContribution
        self.expectedReturn = expectedReturn
        self.expectedIncrease = expectedIncrease
    }
    
    func toInvestment() -> Investment? {
        guard let lumpsum = lumpsumAmount.doubleValue,
              let monthly = monthlyContribution.doubleValue,
              let returnRate = expectedReturn.doubleValue,
              let increase = expectedIncrease.doubleValue else {
            return nil
        }
        
        return Investment(
            uuid: uuid,
            name: name,
            lumpsumAmount: lumpsum,
            monthlyContribution: monthly,
            expectedReturn: returnRate,
            expectedIncrease: increase
        )
    }
}

fileprivate extension String {
    var doubleValue: Double? {
        if isEmpty {
            return 0
        }
        return Double(self)
    }
}
