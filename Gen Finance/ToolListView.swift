import SwiftUI

struct ToolListView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 10)
                List {
                    NavigationLink(destination: FireCalculatorView()) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .yellow)
                            
                            Text("Fire Calculator")
                        }
                        .padding(.init(top: 10, leading: 1, bottom: 10, trailing: 1))
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.visible, edges: .bottom)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Finance Tools")
        }
    }
}

#Preview {
    ToolListView()
} 
