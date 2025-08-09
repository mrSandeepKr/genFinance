import SwiftUI

struct AgeInputSection: View {
    
    // MARK: - Init
    
    init(currentAge: Binding<String>,
         retirementAge:  Binding<String>,
         focusedField: FocusState<FireCalculatorView.Field?>.Binding) {
        self._currentAge = currentAge
        self._retirementAge = retirementAge
        self.focusedField = focusedField
    }
    
    // MARK: - View
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.7))
                SingleAgeInput(
                    title: "Current age",
                    value: $currentAge,
                    placeholder: "25",
                    min: 0,
                    max: 99,
                    field: .currentAge,
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
                    .fill(Color(.systemGray6).opacity(0.7))
                SingleAgeInput(
                    title: "Retirement age",
                    value: $retirementAge,
                    placeholder: "55",
                    min: 0,
                    max: 100,
                    field: .retirementAge,
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
    
    // MARK: - Init
    
    @Binding private var currentAge: String
    @Binding private var retirementAge: String
    private var focusedField: FocusState<FireCalculatorView.Field?>.Binding
}

struct SingleAgeInput: View {
    
    // MARK: - Init
    
    init(title: String,
         value: Binding<String>,
         placeholder: String,
         min: Int,
         max: Int,
         field: FireCalculatorView.Field,
         focusedField: FocusState<FireCalculatorView.Field?>.Binding) {
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
                .focused(focusedField, equals: field)
                .tint(.indigo)
                .keyboardType(.numberPad)
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .foregroundStyle(.indigo.gradient.opacity(0.9))
                .multilineTextAlignment(.center)
                .onChange(of: value) { oldValue, newValue in
                    onChange(oldValue, newValue)
                }
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Private
    
    private let title: String
    @Binding private var value: String
    private let placeholder: String
    private let min: Int
    private  let max: Int
    private  let field: FireCalculatorView.Field
    private  var focusedField: FocusState<FireCalculatorView.Field?>.Binding
    
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
