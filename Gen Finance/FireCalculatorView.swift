import SwiftUI
import Foundation

struct FireCalculatorView: View {
    
    // MARK: - View
    
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    FormSection(heading: "Preference", symbol: "person.crop.circle") {
                        AgeInputSection(currentAge: $currentAge,
                                        retirementAge: $retirementAge,
                                        focusedField: $focusedField)
                        
                        NumericTextField(placeholder: "INR",
                                         title: "Expected Monthly expense",
                                         currentVal: $currentSavings,
                                         focusedField: $focusedField,
                                         field: .currentSavings)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5), value: currentAge)
                    FormSection(heading: "Current Status", symbol: "banknote") {
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
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: currentSalary)
                    FormSection(heading: "SIP numbers", symbol: "chart.line.uptrend.xyaxis") {
                        NumericTextField(placeholder: "INR",
                                         title: "Monthly SIP Investment",
                                         currentVal: $monthlySIP,
                                         focusedField: $focusedField,
                                         field: .monthlySIP)
                        PercentageInputField(value: $expectedYearlyReturn,
                                             title: "Expected Yearly Return",
                                             focusedField: $focusedField,
                                             field: .expectedYearlyReturn)
                        .offset(y: 10)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: monthlySIP)
                    FormSection(heading: "PF Contribution", symbol: "building.columns") {
                        NumericTextField(placeholder: "INR",
                                         title: "Current PF Balance",
                                         currentVal: $currentPfBalance,
                                         focusedField: $focusedField,
                                         field: .currentPfBalance)
                        PercentageInputField(value: $pfEmployeePercent,
                                             title: "PF by Employee",
                                             focusedField: $focusedField,
                                             field: .pfEmployeePercent)
                        PercentageInputField(value: $pfEmployerPercent,
                                             title: "PF by Employer",
                                             focusedField: $focusedField,
                                             field: .pfEmployerPercent)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: pfEmployeePercent)
                    FormSection(heading: "Assumptions", symbol: "lightbulb") {
                        PercentageInputField(value: $inflationPercent,
                                             title: "Expected Annual Inflation",
                                             focusedField: $focusedField,
                                             field: .inflationPercent)
                        PercentageInputField(value: $expectedWithdrawalRateFromCorpus,
                                             title: "Expected Withdrawal Rate from corpus",
                                             focusedField: $focusedField,
                                             field: .expectedWithdrawalRateFromCorpus)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: inflationPercent)
                }
                .padding(.horizontal, 15)
                .padding(.top, 20)
                .padding(.bottom, keyboard.isKeyboardVisible ? 0 : 80)
            }
            VStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        calculateFireCorpus()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.indigo.gradient.opacity(0.7))
                            .frame(height: 56)
                            .overlay(
                                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.35), Color.clear]), startPoint: .top, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            )
                            .shadow(color: Color.indigo.opacity(0.18), radius: 8, x: 0, y: 4)
                        Text("Calculate FIRE Corpus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                    }
                    .scaleEffect(showResult ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showResult)
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
        case expectedMonthlyExpense
        case expectedWithdrawalRateFromCorpus
        case currentSavings
        case currentSalary
        case monthlySIP
        case expectedYearlyReturn
        case pfEmployeePercent
        case pfEmployerPercent
        case currentPfBalance
        case inflationPercent
        case currentAge
        case retirementAge
    }
    
    // MARK: - Private
    
    @StateObject private var keyboard = KeyboardResponder()
        @FocusState private var focusedField: Field?
        @State private var showResult: Bool = false
        @State private var fireCorpus: Double? = nil
        
        @State private var expectedMonthlyExpense: String = ""
        @State private var expectedWithdrawalRateFromCorpus: String = "4"
        @State private var currentSavings: String = ""
        @State private var monthlySIP: String = ""
        @State private var expectedYearlyReturn: String = "15"
        @State private var currentSalary: String = ""
        @State private var pfEmployeePercent: String = "12"
        @State private var pfEmployerPercent: String = "12"
        @State private var currentPfBalance: String = ""
        @State private var inflationPercent: String = ""
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

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
