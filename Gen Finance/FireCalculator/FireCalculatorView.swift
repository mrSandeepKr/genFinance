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
                    }
                    
                    FormSection(heading: "Assumptions",
                               symbol: "lightbulb",
                               animationValue: inflationPercent,
                               isResetting: isResetting,
                               animationDelay: 0.4) {
                        PercentageInputField<Field>(value: $expectedWithdrawalRateFromCorpus,
                                             title: "Expected Withdrawal Rate from corpus",
                                             focusedField: $focusedField,
                                             field: .expectedWithdrawalRateFromCorpus)
                        PercentageInputField<Field>(value: $inflationPercent,
                                             title: "Expected Annual Inflation",
                                             focusedField: $focusedField,
                                             field: .inflationPercent)
                    }
                    
                    investmentsSection()
                    
                    // Add Investment Button
                    Button(action: addInvestment) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.indigo)
                            Text("Add Investment")
                                .foregroundColor(.indigo)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.indigo.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    
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
    
    // MARK: - Configuration

    enum Field: Hashable {
        case expectedMonthlyExpense
        case expectedWithdrawalRateFromCorpus
        case inflationPercent
        case currentAge
        case retirementAge
        case investment(InvestmentField)
    }
    
    enum InvestmentField: Hashable {
        case name(String)
        case lumpsumAmount(String)
        case monthlyContribution(String)
        case expectedReturn(String)
        case expectedIncrease(String)
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
    @AppStorage("inflationPercent") private var inflationPercent: String = "8"
    @AppStorage("currentAge") private var currentAge: String = "27"
    @AppStorage("retirementAge") private var retirementAge: String = "45"
    @AppStorage("investmentsData") private var investmentsData: Data = Data()
	
	// Computed property to work with investments array
	private var investments: [InvestmentFormSectionInput] {
		get {
			guard let decoded = try? JSONDecoder().decode([InvestmentFormSectionInput].self, from: investmentsData) else {
				return [
					InvestmentFormSectionInput(
						uuid: UUID(),
						name: "Mutual Funds",
						lumpsumAmount: "",
						monthlyContribution: "",
						expectedReturn: "12",
						expectedIncrease: "5"
					)
				]
			}
			return decoded
		}
	}
	
	// Helper method to update investments
	private func updateInvestments(_ newInvestments: [InvestmentFormSectionInput]) {
		if let encoded = try? JSONEncoder().encode(newInvestments) {
			investmentsData = encoded
		}
	}
    
    private func addInvestment() {
		var currentInvestments = investments
		currentInvestments.append(InvestmentFormSectionInput(
			uuid: UUID(),
			name: "Investment \(currentInvestments.count + 1)",
			lumpsumAmount: "",
			monthlyContribution: "",
			expectedReturn: "12",
			expectedIncrease: "5"
		))
		updateInvestments(currentInvestments)
	}
    
    private func removeInvestment(_ uuid: UUID) {
        var currentInvestments = investments
        currentInvestments.removeAll { $0.uuid == uuid }
        updateInvestments(currentInvestments)
    }
    
    @ViewBuilder
    private func investmentsSection() -> some View {
        ForEach(investments, id: \.uuid) { investment in
            InvestmentFormSection(
                investment: Binding(
                    get: { 
                        investments.first { $0.uuid == investment.uuid } ?? investment
                    },
                    set: { newValue in
                        var currentInvestments = investments
                        if let index = currentInvestments.firstIndex(where: { $0.uuid == investment.uuid }) {
                            currentInvestments[index] = newValue
                            updateInvestments(currentInvestments)
                        }
                    }
                ),
                focusedField: $focusedField,
                isResetting: $isResetting,
                animationDelay: Double(0.1) * Double(investments.firstIndex(where: { $0.uuid == investment.uuid }) ?? 0),
                onDelete: {
                    removeInvestment(investment.uuid)
                }
            )
        }
    }
    
    func calculateFireCorpus() {
        let monthlyExpense = Double(expectedMonthlyExpense) ?? 0
        let withdrawalRate = Double(expectedWithdrawalRateFromCorpus) ?? 0
        let currentAge = Int(currentAge) ?? 0
        let retirementAge = Int(retirementAge) ?? 0
        let inflationPercent = Double(inflationPercent) ?? 0
        let investmentObjects = investments.compactMap { $0.toInvestment() }
        
        fireCalculationResult = FireCalculatorFactory.calculate(
            monthlyExpense: monthlyExpense,
            expectedWithdrawalRateFromCorpus: withdrawalRate,
            currentAge: currentAge,
            retirementAge: retirementAge,
            investments: investmentObjects,
            inflationPercent: inflationPercent
        )
        showResult = true
    }
    
    private func resetToDefaults() {
        focusedField = nil
        
        expectedMonthlyExpense = ""
        expectedWithdrawalRateFromCorpus = "4"
        inflationPercent = "8"
        currentAge = "27"
        retirementAge = "45"
        updateInvestments([])
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
