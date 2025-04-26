import SwiftUI

struct PageIndicatorView: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Colors.accent : Colors.grey)
                    .frame(width: 5, height: 5)
                    .scaleEffect(index == currentPage ? 2.5 : 1.0)
                    .padding(2)
            }
        }
    }
} 
