import SwiftUI

struct ServicesGridView: View {
    let services: [ServiceModel]
    @State private var showBookingTypeSheet = false
    @State private var selectedService: ServiceModel?
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            ForEach(services) { service in
                ServiceItemView(service: service)
                    .onTapGesture {
                        if service.categoryId == 1 || service.categoryId == 2 {
                            selectedService = service
                            showBookingTypeSheet = true
                        } else {
                            navigateToService(service, isLocal: nil)
                        }
                    }
            }
        }
        .sheet(isPresented: $showBookingTypeSheet) {
            if let service = selectedService {
                BookingTypeSheet(service: service) { isLocal in
                    navigateToService(service, isLocal: isLocal)
                }
            }
        }
    }
    
    private func navigateToService(_ service: ServiceModel, isLocal: Bool?) {
        // Save booking preferences
        if let isLocal = isLocal {
            PreferenceManager.shared.setStringValue(isLocal ? "local" : "outstation", forKey: "booking_type")
            PreferenceManager.shared.setIntegerValue(service.categoryId, forKey: "booking_category")
            PreferenceManager.shared.setDoubleValue(Date().timeIntervalSince1970, forKey: "booking_timestamp")
        }
        
        // Navigate based on service type
        if service.categoryId == 1 {
            // Navigate to GoodsPickupMapLocationView
        } else if service.categoryId == 2 {
            // Navigate to CabBookingPickupLocationView
        } else {
            // Navigate to AllServiceView
        }
    }
}

struct ServiceItemView: View {
    let service: ServiceModel
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: service.categoryImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            
            Text(service.categoryName)
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct BookingTypeSheet: View {
    let service: ServiceModel
    let onSelect: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                dismiss()
                onSelect(true)
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Local Booking")
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Button {
                dismiss()
                onSelect(false)
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Outstation Booking")
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .presentationDetents([.height(200)])
    }
}

#Preview {
    ServicesGridView(services: [])
} 
