import SwiftUI

struct Info2View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 35)
            
            Image("img2")
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding(15)
            
            Spacer()
                .frame(height: 35)
            
            Text("Choose vehicle of your choice")
                .font(.custom("Gilroy-Black", size: 24))
                .foregroundColor(Colors.black)
                .multilineTextAlignment(.center)
                .padding(5)
            
            Text("Get quotes for vehicles which can carry from 20 kgs to 2000 kgs and book instantly without any waiting")
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
