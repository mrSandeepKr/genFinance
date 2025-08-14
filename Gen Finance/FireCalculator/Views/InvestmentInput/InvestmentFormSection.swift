import SwiftUI

struct InvestmentFormSection: View {

    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
               Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.primary.gradient.opacity(0.85))
                    .shadow(color: theme.primary080, radius: 2, x: 0, y: 1)
                TextField("Investment Name", text: $investment.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(theme.primary.gradient.opacity(0.8))
                    .focused(focusedField, equals: .investment(.name(investment.uuid.uuidString)))
            }
            .padding(.top, 16)
            
            Spacer(minLength: 10)
            
            content()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: theme.primary080, radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .scaleEffect(isResetting ? 0.95 : 1.0)
        .opacity(isResetting ? 0.7 : 1.0)
    }
    
    // MARK: - Init
    
    typealias T = FireCalculatorView.Field
    
    init(investment: Binding<InvestmentFormSectionInput>,
         focusedField: FocusState<T?>.Binding,
         isResetting: Binding<Bool>,
         animationDelay: Double,
         onDelete: @escaping () -> Void,
         animatingCards: Binding<Set<UUID>>,
         removingCards: Binding<Set<UUID>>) {
        self._investment = investment
        self.focusedField = focusedField
        self._isResetting = isResetting
        self.animationDelay = animationDelay
        self.onDelete = onDelete
        self._animatingCards = animatingCards
        self._removingCards = removingCards
    }
    
    // MARK: - Private
    
    @Environment(\.appTheme) private var theme
    
    @Binding private var investment: InvestmentFormSectionInput
    private var focusedField: FocusState<T?>.Binding
    @Binding var isResetting: Bool
    private let animationDelay: Double
    private let onDelete: () -> Void
    @Binding private var animatingCards: Set<UUID>
    @Binding private var removingCards: Set<UUID>
    
    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 16) {
            NumericTextField<T>(
                placeholder: "INR",
                title: "Current Lumpsum Investment",
                currentVal: $investment.lumpsumAmount,
                focusedField: focusedField,
                field: .investment(.lumpsumAmount(investment.uuid.uuidString))
            )
            NumericTextField<T>(
                placeholder: "INR",
                title: "Expected Monthly Investment",
                currentVal: $investment.monthlyContribution,
                focusedField: focusedField,
                field: .investment(.monthlyContribution(investment.uuid.uuidString))
            )
            PercentageInputField<FireCalculatorView.Field>(
                value: $investment.expectedReturn,
                title: "Expected Yearly Return",
                focusedField: focusedField,
                field: .investment(.expectedReturn(investment.uuid.uuidString))
            )
            PercentageInputField<FireCalculatorView.Field>(
                value: $investment.expectedIncrease,
                title: "Expected Increase in Investment",
                focusedField: focusedField,
                field: .investment(.expectedIncrease( investment.uuid.uuidString))
            )
            
            // Delete Button
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(theme.negative)
                    Text("Remove Investment")
                        .foregroundColor(theme.negative)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.negative.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .scaleEffect(animatingCards.contains(investment.uuid) ? 1.02 : 1.0)
        .opacity(removingCards.contains(investment.uuid) ? 0 : 1)
        .offset(y: removingCards.contains(investment.uuid) ? -15 : 0)
        .animation(.easeInOut(duration: 0.3), value: removingCards.contains(investment.uuid))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animatingCards.contains(investment.uuid))
    }
    
    private var cardTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8)
                .combined(with: .opacity)
                .combined(with: .offset(y: 30)),
            removal: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: -30))
        )
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
