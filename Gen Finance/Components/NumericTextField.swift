//
//  NumericTextField.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 03/08/25.
//

import SwiftUI

struct NumericTextField: View {

    // MARK: - Init

    init(placeholder: String, title: String? = nil, currentVal: Binding<String>) {
        self.placeholder = placeholder
        self.title = title
        self._currentVal = currentVal
        self._formattedContent = State(initialValue: currentVal.wrappedValue.formattedInINR)
    }

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.primary)
            }
            TextField(placeholder, text: $formattedContent)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .keyboardType(.numberPad)
                .shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 2)
                .onChange(of: formattedContent) { _, newVal in
                    currentVal = newVal.filter { "0123456789".contains($0) }
                    formattedContent = currentVal.formattedInINR
                }
                .padding(.init(top: 0, leading: 1, bottom: 0, trailing: 1))
        }
        .padding(.vertical, 10)
        .listRowInsets(.init())
        .listRowSeparator(.hidden)
    }

    // MARK: - Private

    private let placeholder: String
    private let title: String?
    @State private var formattedContent: String
    @Binding private var currentVal: String
}

extension Formatter {
    static let inr: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()
}

extension String {
    var formattedInINR: String {
        guard let doubleValue = Double(self) else {
            return self
        }
        print(doubleValue)
        return Formatter.inr.string(from: NSNumber(value: doubleValue)) ?? self
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
