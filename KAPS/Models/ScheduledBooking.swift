import Foundation

struct ScheduledBooking: Identifiable, Codable {
    let id = UUID()
    let scheduleId: String
    let bookingId: String
    let scheduledTime: String
    let categoryId: String
    let scheduledDate: String
    let categoryName: String
    let categoryImage: String
    let pickupAddress: String
    let totalPrice: String
    let bookingStatus: String
    let serviceName: String
    let subCatName: String
    let dropAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case scheduleId = "schedule_id"
        case bookingId = "booking_id"
        case scheduledTime = "scheduled_time"
        case categoryId = "category_id"
        case scheduledDate = "scheduled_date"
        case categoryName = "category_name"
        case categoryImage = "category_image"
        case pickupAddress = "pickup_address"
        case totalPrice = "total_price"
        case bookingStatus = "booking_status"
        case serviceName = "service_name"
        case subCatName = "sub_cat_name"
        case dropAddress = "drop_address"
    }
} 