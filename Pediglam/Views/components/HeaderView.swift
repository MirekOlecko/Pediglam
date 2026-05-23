import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Binding var showSettings: Bool
    
    @State private var rotationDegree: Double = 0.0
    
    var body: some View {
        HStack {
            Text("Pediglam")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Button(action: {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    rotationDegree = 360.0
                }
                viewModel.loadEvents()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.iosBlue)
                    .rotationEffect(.degrees(rotationDegree))
            }
            .onChange(of: viewModel.isLoading) { loading in
                if !loading {
                    withAnimation(.linear(duration: 0.3)) {
                        rotationDegree = 0.0
                    }
                }
            }
            .padding(.trailing, 10)
            
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
}
