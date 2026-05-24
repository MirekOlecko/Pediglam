import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        HStack {
            Text("Pediglam")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primaryText)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
}
