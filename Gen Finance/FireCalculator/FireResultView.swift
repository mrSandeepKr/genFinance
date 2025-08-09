import SwiftUI

struct FireResultView: View {
    let requiredCorpus: Double
    let projectedCorpus: Double
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 16) {
                Text("Required FIRE Corpus")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(requiredCorpus, format: .currency(code: "INR"))
                    .font(.largeTitle.bold())
                    .foregroundColor(.indigo)
            }
            VStack(spacing: 16) {
                Text("Projected Corpus at Retirement")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text(projectedCorpus, format: .currency(code: "INR"))
                    .font(.largeTitle.bold())
                    .foregroundColor(.green)
            }
            Spacer()
            Button(action: {
                // Dismiss or pop navigation
                // This will be handled by the parent view
            }) {
                Text("Back")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("FIRE Results")
    }
}

#Preview {
    FireResultView(requiredCorpus: 10000000, projectedCorpus: 8500000)
}
