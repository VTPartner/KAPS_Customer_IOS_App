import SwiftUI

struct Info3View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 35)
            
            Image("img3")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(15)
            
            Spacer()
                .frame(height: 35)
            
            Text("Safe and Reliable Delivery")
                .font(.custom("Gilroy-Black", size: 24))
                .foregroundColor(Colors.black)
                .multilineTextAlignment(.center)
                .padding(5)
            
            Text("Superior safety ensured with our team of verified & trained partners")
                .font(.custom("Gilroy-Bold", size: 14))
                .foregroundColor(Colors.grey)
                .multilineTextAlignment(.center)
                .padding(5)
            
            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .shadow(radius: 5)
    }
} 
