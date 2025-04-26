import SwiftUI

struct OffersCarouselView: View {
    let offers: [OfferModel]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(offers) { offer in
                    OfferCardView(offer: offer)
                }
            }
        }
    }
}

struct OfferCardView: View {
    let offer: OfferModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: offer.bannerImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 280, height: 160)
            .clipped()
            .cornerRadius(8)
            
//            Text(offer.bannerTitle)
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.black)
//            
//            Text(offer.bannerDescription)
//                .font(.system(size: 14))
//                .foregroundColor(.gray)
//                .lineLimit(2)
        }
        .frame(width: 280)
    }
}

#Preview {
    OffersCarouselView(offers: [])
} 
