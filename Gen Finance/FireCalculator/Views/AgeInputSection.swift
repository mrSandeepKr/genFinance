import SwiftUI

struct AgeInputSection<T: Hashable>: View {
    
    // MARK: - Init
    
    init(currentAge: Binding<String>,
         retirementAge:  Binding<String>,
         focusedField: FocusState<T?>.Binding,
         currentAgeField: T,
         retirementAgeField: T) {
        self._currentAge = currentAge
        self._retirementAge = retirementAge
        self.focusedField = focusedField
        self.currentAgeField = currentAgeField
        self.retirementAgeField = retirementAgeField
    }
    
    // MARK: - View
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                SingleAgeInput(
                    title: "Current age",
                    value: $currentAge,
                    placeholder: "25",
                    min: 0,
                    max: 99,
                    field: currentAgeField,
                    focusedField: focusedField
                )
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 8)

            VStack {
                Divider()
                    .frame(width: 1)
                    .background(Color(.systemGray4))
            }
            .frame(height: 60)
            .padding(.vertical, 8)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                SingleAgeInput(
                    title: "Retirement age",
                    value: $retirementAge,
                    placeholder: "55",
                    min: 0,
                    max: 100,
                    field: retirementAgeField,
                    focusedField: focusedField
                )
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 8)
        }
        .padding(.top, 14)
        .padding(.horizontal)
    }
    
    // MARK: - Private
    
    @Binding private var currentAge: String
    @Binding private var retirementAge: String
    private var focusedField: FocusState<T?>.Binding
    private var currentAgeField: T
    private var retirementAgeField: T
}

struct SingleAgeInput<T: Hashable>: View {
    
    // MARK: - Init
    
    init(title: String,
         value: Binding<String>,
         placeholder: String,
         min: Int,
         max: Int,
         field: T,
         focusedField: FocusState<T?>.Binding) {
        self.title = title
        self._value = value
        self.placeholder = placeholder
        self.min = min
        self.max = max
        self.field = field
        self.focusedField = focusedField
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            TextField(placeholder, text: $value)
                .tint(theme.primary)
                .focused(focusedField, equals: field)
                .keyboardType(.numberPad)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundStyle(theme.contentPrimary)
                .multilineTextAlignment(.center)
                .onChange(of: value) { oldValue, newValue in
                    onChange(oldValue, newValue)
                }
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(theme.contentSecondary)
        }
    }
    
    // MARK: - Private
    
    @Environment(\.appTheme) private var theme
    
    private let title: String
    @Binding private var value: String
    private let placeholder: String
    private let min: Int
    private  let max: Int
    private  let field: T
    private  var focusedField: FocusState<T?>.Binding
    
    private func onChange(_ oldValue: String,_ newValue: String) {
        let filtered = newValue.filter { "0123456789".contains($0) }
        let trimmed = String(filtered.prefix(3))
        var intValue = Int(trimmed) ?? min
        if intValue < min { intValue = min }
        if intValue > max { intValue = max }
        value = intValue == 0 ? "" : String(intValue)
    }
}


#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
