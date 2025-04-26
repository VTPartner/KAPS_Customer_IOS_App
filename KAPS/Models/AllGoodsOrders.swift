import Foundation

struct AllGoodsOrders: Identifiable, Codable {
    let id = UUID()
    let orderId: String
    let vehicleName: String
    let vehicleImage: String
    let bookingTiming: String
    let totalTime: String
    let totalPrice: String
    let paymentMethod: String
    let senderName: String
    let senderNumber: String
    let receiverName: String
    let receiverNumber: String
    let pickupAddress: String
    let dropAddress: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case vehicleName = "vehicle_name"
        case vehicleImage = "vehicle_image"
        case bookingTiming = "booking_timing"
        case totalTime = "total_time"
        case totalPrice = "total_price"
        case paymentMethod = "payment_method"
        case senderName = "sender_name"
        case senderNumber = "sender_number"
        case receiverName = "receiver_name"
        case receiverNumber = "receiver_number"
        case pickupAddress = "pickup_address"
        case dropAddress = "drop_address"
    }
} 