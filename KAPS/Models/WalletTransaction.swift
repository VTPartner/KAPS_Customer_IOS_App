import Foundation

struct WalletTransaction: Identifiable, Codable {
    let id = UUID()
    let transactionId: String
    let transactionType: String
    let amount: Double
    let status: String
    let transactionDate: String
    let remarks: String
    let paymentMode: String
    let razorPayID: String
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case transactionType = "transaction_type"
        case amount
        case status
        case transactionDate = "transaction_date"
        case remarks
        case paymentMode = "payment_mode"
        case razorPayID = "razorpay_payment_id"
    }
} 