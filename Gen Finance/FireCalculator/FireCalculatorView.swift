import SwiftUI
import Foundation

struct FireCalculatorView: View {
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            backgroundView
            mainContentView
        }
    }
    
    // MARK: - View Components
    
    private var backgroundView: some View {
        VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
            .ignoresSafeArea()
    }
    
    private var mainContentView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                formContentView(proxy: proxy)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomButtonView
        }
        .navigationTitle("FIRE Calculator")
        .toolbar {
            resetButton
        }
        .onTapGesture {
            focusedField = nil
        }
        .navigationDestination(isPresented: $showResult) {
            resultDestinationView
        }
        .hideToolBarWithSwipeToDismiss()
    }
    
    private func formContentView(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 24) {
            preferencesSection
            assumptionsSection
            investmentsSection
            addInvestmentButton
                .id(addButtonAnchorId)
        }
        .padding(.horizontal, 15)
        .padding(.top, 20)
       // .padding(.bottom, keyboard.isKeyboardVisible ? 0 : 80)
        .onChange(of: scrollToBottomTick) { _, _ in
            scrollToBottom(proxy: proxy)
        }
    }
    
    private var bottomButtonView: some View {
        VStack {
            //Spacer()
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    calculateFireCorpus()
                }
            }) {
                calculateButton
            }
            .padding(.init(top: 16, leading: 12, bottom: 8, trailing: 12))
            .background(
                theme
                    .secondarySystemBackground
                    .ignoresSafeArea(.all, edges: .bottom)
                    .shadow(radius: 8)
            )
        }
        .offset(y: keyboard.isKeyboardVisible ? 200 : 0)
        .animation(.easeIn(duration: 0.3).delay(0.5), value: keyboard.isKeyboardVisible)
    }
    
    private var calculateButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.primary.gradient.opacity(0.7))
                .frame(height: 56)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [theme.contentPrimary.opacity(0.35), Color.clear]), startPoint: .top, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
                .shadow(color: theme.primary200, radius: 8, x: 0, y: 4)
            Text("Calculate FIRE Corpus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.alwaysLight)
                .shadow(color: theme.shadow, radius: 2, x: 0, y: 1)
        }
        .scaleEffect(showResult ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: showResult)
    }
    
    private var resetButton: some ToolbarContent {
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
            .foregroundColor(theme.primary)
            .font(.system(size: 16, weight: .medium))
        }
    }
    
    // MARK: - Form Views
    
    private var preferencesSection: some View {
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
    }
    
    private var assumptionsSection: some View {
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
    }
    
    @ViewBuilder
    private var investmentsSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(investments.enumerated()), id: \.element.uuid) { index, investment in
                investmentRow(index: index, investment: investment)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: investments.map { $0.uuid })
    }

    private func binding(for investment: InvestmentFormSectionInput) -> Binding<InvestmentFormSectionInput> {
        Binding(
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
        )
    }

    @ViewBuilder
    private func investmentRow(index: Int, investment: InvestmentFormSectionInput) -> some View {
        InvestmentFormSection(
            investment: binding(for: investment),
            focusedField: $focusedField,
            isResetting: $isResetting,
            animationDelay: Double(0.1) * Double(index),
            onDelete: { removeInvestment(investment.uuid) },
            animatingCards: $animatingCards,
            removingCards: $removingCards
        )
    }
    
    private var addInvestmentButton: some View {
        Button(action: addInvestment) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(theme.primary)
                Text("Add Investment")
                    .foregroundColor(theme.primary)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.primary.opacity(0.3), lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var resultDestinationView: some View {
        Group {
            if let fireCalculationResult {
                FireResultView(fireCalculationResult: fireCalculationResult)
            } else {
                Text("Something went wrong...")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addInvestment() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
		var currentInvestments = investments
        let newInvestment = InvestmentFormSectionInput(
			uuid: UUID(),
			name: "Investment \(currentInvestments.count + 1)",
			lumpsumAmount: "",
			monthlyContribution: "",
			expectedReturn: "12",
			expectedIncrease: "5"
		)
        
        animatingCards.insert(newInvestment.uuid)
		currentInvestments.append(newInvestment)
		updateInvestments(currentInvestments)
        scrollToBottomTick += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animatingCards.remove(newInvestment.uuid)
        }
	}
    
    private func removeInvestment(_ uuid: UUID) {
        // Add to removing cards set
        removingCards.insert(uuid)
        
        // Animate the removal
        withAnimation(.easeInOut(duration: 0.3)) {
            // The animation will be handled by the view
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var currentInvestments = investments
            currentInvestments.removeAll { $0.uuid == uuid }
            updateInvestments(currentInvestments)
            removingCards.remove(uuid)
        }
    }
    
    private func calculateFireCorpus() {
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
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                proxy.scrollTo(addButtonAnchorId, anchor: .bottom)
            }
        }
    }
    
    // MARK: - Private
    @Environment(\.appTheme) private var theme
    
    @StateObject private var keyboard = KeyboardResponder()
    @FocusState private var focusedField: Field?
    @State private var showResult: Bool = false
    @State private var fireCalculationResult: FireCalculationResult? = nil
    @State private var isResetting: Bool = false
    @State private var animatingCards: Set<UUID> = []
    @State private var removingCards: Set<UUID> = []
    @State private var scrollToBottomTick: Int = 0
    private let addButtonAnchorId = "BOTTOM_ANCHOR"
    
    // MARK: - AppStorage Properties
    
    @AppStorage("expectedMonthlyExpense") private var expectedMonthlyExpense: String = ""
    @AppStorage("expectedWithdrawalRateFromCorpus") private var expectedWithdrawalRateFromCorpus: String = "4"
    @AppStorage("inflationPercent") private var inflationPercent: String = "8"
    @AppStorage("currentAge") private var currentAge: String = "27"
    @AppStorage("retirementAge") private var retirementAge: String = "45"
    @AppStorage("investmentsData") private var investmentsData: Data = Data()
    
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
    
    private func updateInvestments(_ newInvestments: [InvestmentFormSectionInput]) {
        if let encoded = try? JSONEncoder().encode(newInvestments) {
            investmentsData = encoded
        }
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
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
