import SwiftUI

struct PercentageInputField: View {

    // MARK: - Init

    init(
        value: Binding<String>,
        title: String = "Percentage",
        focusedField: FocusState<FireCalculatorView.Field?>.Binding,
        field: FireCalculatorView.Field
    ) {
        self._value = value
        self.title = title
        self.focusedField = focusedField
        self.field = field
    }

    // MARK: - View

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            ZStack(alignment: .trailing) {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .focused(focusedField, equals: field)
                    .multilineTextAlignment(.trailing)
                    .padding(.bottom, 2)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: (focusedField.wrappedValue == field)
                    )
                    .foregroundColor(
                        (focusedField.wrappedValue == field)
                            ? .primary : .secondary
                    )
                    .onChange(of: value) { oldValue, newValue in
                        guard let doubleValue = Double(newValue) else {
                            if newValue == "" {
                                value = ""
                            } else {
                                value = oldValue
                            }
                            return
                        }
                        if doubleValue > 100 {
                            value = "100"
                            return
                        }
                        let filtered = newValue.filter {
                            "0123456789.".contains($0)
                        }

                        let components = filtered.split(
                            separator: ".", maxSplits: 1,
                            omittingEmptySubsequences: false)
                        var result = ""

                        if let intPart = components.first {
                            let intString = String(intPart)
                            result += String(intString.prefix(3))
                        }
                        if components.count > 1 {
                            result += "."
                            result += String(components[1].prefix(2))
                        }

                        if result.isEmpty && !filtered.isEmpty {
                            result = "0"
                        }

                        value = result
                    }
                    .background(
                        Text(value.isEmpty ? "0" : value)
                            .font(
                                .system(
                                    size: 18, weight: .medium, design: .rounded)
                            )
                            .opacity(0)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            textWidth = max(geo.size.width, 20)
                                        }
                                        .onChange(of: value) { _, _ in
                                            textWidth = max(geo.size.width, 20)
                                        }
                                })
                    )
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .frame(width: 120)

                VStack {
                    Spacer()

                    Rectangle()
                        .frame(
                            width: textWidth,
                            height: (focusedField.wrappedValue == field) ? 2 : 1
                        )
                        .foregroundColor(
                            (focusedField.wrappedValue == field)
                                ? .indigo.opacity(0.5) : .gray.opacity(0.5)
                        )
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: (focusedField.wrappedValue == field))
                }
            }

            Text("%")
                .foregroundStyle(.secondary)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .padding(.trailing, 4)
        }
        .padding(.top, 14)
        .listRowSeparator(.hidden)
        .listRowInsets(.init())
    }

    // MARK: - Private

    @Binding private var value: String
    private let title: String
    private var focusedField: FocusState<FireCalculatorView.Field?>.Binding
    private var field: FireCalculatorView.Field?

    @State private var textWidth: CGFloat = 40
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
