import SwiftUI

struct LocationHeaderView: View {
    let address: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "location.fill")
                .font(.system(size: 20))
                .foregroundColor(Colors.primary)
                .frame(width: 32, height: 32)
                .padding(3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Location")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Text(address)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(5)
    }
}

#Preview {
    LocationHeaderView(address: "123 Main St, City, Country")
} 