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
                    FormSection(heading: "Preference", 
                               symbol: "person.crop.circle",
                               animationValue: currentAge,
                               isResetting: isResetting,
                               animationDelay: 0.0) {
                        AgeInputSection<Field>(currentAge: $currentAge,
                                        retirementAge: $retirementAge,
                                        focusedField: $focusedField,
                                        currentAgeField: .currentAge,
                                        retirementAgeField: .retirementAge)
                        
                        NumericTextField<Field>(placeholder: "INR",
                                         title: "Expected Monthly expense",
                                         currentVal: $expectedMonthlyExpense,
                                         focusedField: $focusedField,
                                         field: .expectedMonthlyExpense)
                        
                        Text("The expected monthly expense at retirement in current value of money.")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .offset(y: 5)
                        
                        PercentageInputField<Field>(value: $inflationPercent,
                                             title: "Expected Annual Inflation",
                                             focusedField: $focusedField,
                                             field: .inflationPercent)
                        
                        PercentageInputField<Field>(value: $expectedWithdrawalRateFromCorpus,
                                             title: "Expected Withdrawal Rate from corpus",
                                             focusedField: $focusedField,
                                             field: .expectedWithdrawalRateFromCorpus)
                    }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isResetting = true
                        resetToDefaults()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isResetting = false
                    }
                }
                .foregroundColor(.indigo)
                .font(.system(size: 16, weight: .medium))
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .navigationDestination(isPresented: $showResult) {
            if let fireCalculationResult {
                FireResultView(fireCalculationResult: fireCalculationResult)
            } else {
                Text("Something went wrong...")
            }
        }
        .hideToolBarWithSwipeToDismiss()
    }
    
    enum Field: Hashable {
        case expectedMonthlyExpense
        case expectedWithdrawalRateFromCorpus
        case expectedIncInSIPAmount
        case currentSavings
        case currentSalary
        case expectedSalaryIncrease
        case monthlySIP
        case expectedYearlyReturn
        case inflationPercent
        case currentAge
        case retirementAge
    }
    
    // MARK: - Private
    
    @StateObject private var keyboard = KeyboardResponder()
    @FocusState private var focusedField: Field?
    @State private var showResult: Bool = false
    @State private var fireCalculationResult: FireCalculationResult? = nil
    @State private var isResetting: Bool = false
    
    // MARK: - AppStorage Properties (Automatic Local Storage)
    
    @AppStorage("expectedMonthlyExpense") private var expectedMonthlyExpense: String = ""
    @AppStorage("expectedWithdrawalRateFromCorpus") private var expectedWithdrawalRateFromCorpus: String = "4"
    @AppStorage("expectedIncInSIPAmount") private var expectedIncInSIPAmount: String = "5"
    @AppStorage("currentSavings") private var currentSavings: String = ""
    @AppStorage("monthlySIP") private var monthlySIP: String = ""
    @AppStorage("expectedYearlyReturn") private var expectedYearlyReturn: String = "15"
    @AppStorage("currentSalary") private var currentSalary: String = ""
    @AppStorage("expectedSalaryIncrease") private var expectedSalaryIncrease: String = "5"
    @AppStorage("inflationPercent") private var inflationPercent: String = "8"
    @AppStorage("currentAge") private var currentAge: String = "27"
    @AppStorage("retirementAge") private var retirementAge: String = "45"
    
    func calculateFireCorpus() {
        // Parse inputs
        let monthlyExpense = Double(expectedMonthlyExpense) ?? 0
        let withdrawalRate = Double(expectedWithdrawalRateFromCorpus) ?? 0
        let currentAge = Int(currentAge) ?? 0
        let retirementAge = Int(retirementAge) ?? 0
        let currentSavings = Double(currentSavings) ?? 0
        let monthlySIP = Double(monthlySIP) ?? 0
        let expectedSIPIncrease = Double(expectedIncInSIPAmount) ?? 0
        let expectedReturn = Double(expectedYearlyReturn) ?? 0
        let currentSalary = Double(currentSalary) ?? 0
        let expectedSalaryIncrease = Double(expectedSalaryIncrease) ?? 0
        let inflationPercent = Double(inflationPercent) ?? 0
        
        fireCalculationResult = FireCalculatorFactory.calculate(
            monthlyExpense: monthlyExpense,
            expectedWithdrawalRateFromCorpus: withdrawalRate,
            currentAge: currentAge,
            retirementAge: retirementAge,
            currentSavings: currentSavings,
            monthlySIP: monthlySIP,
            expectedSIPIncrease: expectedSIPIncrease,
            expectedReturn: expectedReturn,
            currentSalary: currentSalary,
            expectedSalaryIncrease: expectedSalaryIncrease,
            inflationPercent: inflationPercent
        )
        showResult = true
    }
    
    private func resetToDefaults() {
        focusedField = nil
        
        expectedMonthlyExpense = ""
        expectedWithdrawalRateFromCorpus = "4"
        expectedIncInSIPAmount = "5"
        currentSavings = ""
        monthlySIP = ""
        expectedYearlyReturn = "15"
        currentSalary = ""
        expectedSalaryIncrease = "5"
        inflationPercent = "8"
        currentAge = "27"
        retirementAge = "45"
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
