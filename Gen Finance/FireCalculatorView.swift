import SwiftUI

struct FireCalculatorView: View {
    @State private var currentSavings: String = ""
    @State private var monthlySIP: String = ""
    @State private var currentSalary: String = ""
    @State private var pfEmployeePercent: String = "12"
    @State private var pfEmployerPercent: String = "12"
    @State private var inflationPercent: String = "6"
    @State private var fireCorpus: Double? = nil
    @State private var showResult: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Current Status")
                .font(.headline)
                .foregroundStyle(.indigo.gradient.opacity(0.8))
            ) {
                NumericTextField(placeholder: "INR",
                                 title: "Current Savings",
                                 currentVal: $currentSavings)
                
                NumericTextField(placeholder: "INR",
                                 title: "Current Salary",
                                 currentVal: $currentSalary)
            }
            .listRowInsets(.init())
            
            Section(header: Text("SIP numbers")) {
                NumericTextField(placeholder: "INR",
                                 title: "Monthly SIP Investment",
                                 currentVal: $monthlySIP)
                
                Text("Take SIP value as input")
            }
            .listRowInsets(.init())
            
            
            
            Section(header: Text("Provident Fund (PF)")) {
                TextField("PF by Employee (% of salary)", text: $pfEmployeePercent)
                    .keyboardType(.decimalPad)
                TextField("PF by Employer (% of salary)", text: $pfEmployerPercent)
                    .keyboardType(.decimalPad)
            }
            .listRowInsets(.init())
            
            
            Section(header: Text("Assumptions")) {
                TextField("Expected Annual Inflation (%)", text: $inflationPercent)
                    .keyboardType(.decimalPad)
            }
            .listRowInsets(.init())
            
            
            Section {
                Button("Calculate FIRE Corpus") {
                    calculateFireCorpus()
                }
            }
            .listRowInsets(.init())
            
            if let corpus = fireCorpus, showResult {
                Section(header: Text("Estimated FIRE Corpus")) {
                    Text("₹\(corpus, specifier: ".2f")")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle(
            Text("FIRE Calculator")
                .foregroundStyle(.green))
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
        }
    }

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
