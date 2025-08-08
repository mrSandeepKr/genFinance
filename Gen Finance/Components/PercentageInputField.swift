import SwiftUI

struct PercentageInputField: View {
    @Binding var value: String
    @FocusState private var isFocused: Bool
    var title: String = "Percentage"

    @State private var textWidth: CGFloat = 40

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()

            ZStack(alignment: .bottom) {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .padding(.bottom, 2)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
                    .foregroundColor(isFocused ? .primary : .secondary)
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
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        
                        let components = filtered.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
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
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .opacity(0)
                            .background(GeometryReader { geo in
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

                HStack {
                    Spacer()
                    
                    Rectangle()
                        .frame(width: textWidth, height: isFocused ? 2 : 1)
                        .foregroundColor(isFocused ? .indigo.opacity(0.5) : .gray.opacity(0.5))
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                }
            }

            Text("%")
                .foregroundStyle(.secondary)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .padding(.trailing, 4)
        }
        .padding(.vertical, 14)
        .listRowSeparator(.hidden)
        .listRowInsets(.init())
    }
}



#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
