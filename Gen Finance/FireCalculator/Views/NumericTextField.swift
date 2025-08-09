//
//  NumericTextField.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 03/08/25.
//

import SwiftUI

struct NumericTextField: View {
    
    // MARK: - Init
    
    init(placeholder: String, title: String, currentVal: Binding<String>, focusedField: FocusState<FireCalculatorView.Field?>.Binding, field: FireCalculatorView.Field) {
        self.placeholder = placeholder
        self.title = title
        self._currentVal = currentVal
        self._formattedContent = State(initialValue: currentVal.wrappedValue.formattedInINR)
        self.focusedField = focusedField
        self.field = field
    }
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color.primary)
            
            TextField(placeholder, text: $formattedContent)
                .focused(focusedField, equals: field)
                .tint(.indigo)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(focusedField.wrappedValue == field ? Color(.systemGray6).opacity(0.9) : Color(.systemGray6).opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: focusedField.wrappedValue == field)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke( Color.indigo.opacity(0.2), lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.2), value: focusedField.wrappedValue == field)
                )                .keyboardType(.numberPad)
                .shadow(color: focusedField.wrappedValue == field ? Color.indigo.opacity(0.1) : Color.black.opacity(0.07),
                        radius: focusedField.wrappedValue == field ? 6 : 3, x: 0, y: 2)
                .onChange(of: formattedContent) { _, newValue in
                    onChange(newValue)
                }
                .padding(.init(top: 0, leading: 1, bottom: 0, trailing: 1))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Private
    
    private let placeholder: String
    private let title: String
    @Binding private var currentVal: String
    @State private var formattedContent: String
    private var focusedField: FocusState<FireCalculatorView.Field?>.Binding
    private var field: FireCalculatorView.Field
    
    private func onChange(_ newValue: String) {
        currentVal = newValue.filter { "0123456789".contains($0) }
        formattedContent = currentVal.formattedInINR
    }
}

fileprivate extension Formatter {
    static let inr: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()
}

fileprivate extension String {
    var formattedInINR: String {
        guard let doubleValue = Double(self) else {
            return self
        }
        return Formatter.inr.string(from: NSNumber(value: doubleValue)) ?? self
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
