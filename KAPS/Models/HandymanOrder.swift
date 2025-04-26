import Foundation

struct HandymanOrder: Identifiable, Codable {
    let id = UUID()
    let orderId: String
    let bookingTiming: String
    let bookingStatus: String
    let totalPrice: String
    let paymentMethod: String
    let serviceName: String
    let subCategoryName: String
    let distance: String
    let totalTime: String
    let pickupAddress: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case bookingTiming = "booking_timing"
        case bookingStatus = "booking_status"
        case totalPrice = "total_price"
        case paymentMethod = "payment_method"
        case serviceName = "service_name"
        case subCategoryName = "sub_cat_name"
        case distance
        case totalTime = "total_time"
        case pickupAddress = "pickup_address"
    }
} 