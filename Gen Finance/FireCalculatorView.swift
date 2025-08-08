import SwiftUI
import Foundation

struct FireCalculatorView: View {
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    FormSection(heading: "Preference") {
                        AgeInputSection(currentAge: $currentAge,
                                        retirementAge: $retirementAge,
                                        focusedField: $focusedField)
                    }
                    FormSection(heading: "Current Status") {
                        NumericTextField(placeholder: "INR",
                                         title: "Current Savings",
                                         currentVal: $currentSavings,
                                         focusedField: $focusedField,
                                         field: .currentSavings)
                        
                        NumericTextField(placeholder: "INR",
                                         title: "Current Salary",
                                         currentVal: $currentSalary,
                                         focusedField: $focusedField,
                                         field: .currentSalary)
                    }
                    
                    FormSection(heading: "SIP numbers") {
                        NumericTextField(placeholder: "INR",
                                         title: "Monthly SIP Investment",
                                         currentVal: $monthlySIP,
                                         focusedField: $focusedField,
                                         field: .monthlySIP)
                    }
                    
                    FormSection(heading: "PF Contribution") {
                        PercentageInputField(value: $pfEmployeePercent,
                                             title: "PF by Employee",
                                             focusedField: $focusedField,
                                             field: .pfEmployeePercent)
                        PercentageInputField(value: $pfEmployerPercent,
                                             title: "PF by Employer",
                                             focusedField: $focusedField,
                                             field: .pfEmployerPercent)
                    }
                    
                    FormSection(heading: "Assumptions") {
                        PercentageInputField(value: $inflationPercent,
                                             title: "Expected Annual Inflation",
                                             focusedField: $focusedField,
                                             field: .inflationPercent)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(.horizontal, 15)
            .padding(.bottom, keyboard.isKeyboardVisible ? 0 : 80)
            
            VStack {
                Spacer()
                Button(action: calculateFireCorpus) {
                    Text("Calculate FIRE Corpus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo.gradient.opacity(0.6))
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                        .cornerRadius(8)
                }
                .padding(.init(top: 16, leading: 12, bottom: 8, trailing: 12))
                .background(
                    Color(.systemBackground).edgesIgnoringSafeArea(.bottom).shadow(radius: 8)
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle("FIRE Calculator")
        .onTapGesture {
            focusedField = nil
        }
    }
    
    enum Field: Hashable {
        case currentSavings
        case currentSalary
        case monthlySIP
        case pfEmployeePercent
        case pfEmployerPercent
        case inflationPercent
        case currentAge
        case retirementAge
    }
    
    // MARK: - Private
    
    @StateObject private var keyboard = KeyboardResponder()
    
    @State private var currentSavings: String = ""
    @State private var monthlySIP: String = ""
    @State private var currentSalary: String = ""
    @State private var pfEmployeePercent: String = "12"
    @State private var pfEmployerPercent: String = "12"
    @State private var inflationPercent: String = "6"
    @State private var fireCorpus: Double? = nil
    @State private var showResult: Bool = false
    @FocusState private var focusedField: Field?
    
    @State private var currentAge: String = "25"
    @State private var retirementAge: String = "55"
    
    
    func calculateFireCorpus() {
        // Parse inputs
        let savings = Double(currentSavings) ?? 0
        let sip = Double(monthlySIP) ?? 0
        let salary = Double(currentSalary) ?? 0
        let pfEmp = (Double(pfEmployeePercent) ?? 0) / 100.0
        let pfEmpr = (Double(pfEmployerPercent) ?? 0) / 100.0
        let inflation = (Double(inflationPercent) ?? 0) / 100.0
        let years = 30.0 // Assume 30 years to FIRE for simplicity
        let annualReturn = 0.12 // Assume 12% annual return on investments
        let swr = 0.04 // 4% safe withdrawal rate
        
        // PF calculation (grows with inflation)
        var pfBalance = 0.0
        var pfSalary = salary
        for _ in 0..<Int(years) {
            let yearlyContribution = pfSalary * (pfEmp + pfEmpr)
            pfBalance = (pfBalance + yearlyContribution) * (1 + inflation)
            pfSalary *= (1 + inflation)
        }
        
        // SIP calculation (monthly compounding)
        let months = years * 12
        let monthlyReturn = pow(1 + annualReturn, 1/12.0) - 1
        var sipBalance = 0.0
        for _ in 0..<Int(months) {
            sipBalance = (sipBalance + sip) * (1 + monthlyReturn)
        }
        
        // Total corpus
        let totalCorpus = savings * pow(1 + annualReturn, years) + pfBalance + sipBalance
        fireCorpus = totalCorpus / swr
        showResult = true
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
