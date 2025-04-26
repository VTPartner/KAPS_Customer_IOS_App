import SwiftUI

struct Info1View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 35)
            
            Image("img1")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(15)
            
            Spacer()
                .frame(height: 35)
            
            Text("Pickup & drop anywhere")
                .font(.custom("Gilroy-Black", size: 24))
                .foregroundColor(Colors.black)
                .multilineTextAlignment(.center)
                .padding(5)
            
            Text("Choose your pickup & drop location from within the area which you required.")
                .font(.custom("Gilroy-Bold", size: 14))
                .foregroundColor(Colors.grey)
                .multilineTextAlignment(.center)
                .padding(10)
            
            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .shadow(radius: 5)
    }
} 
