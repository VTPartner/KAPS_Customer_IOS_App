import Foundation

struct CountryCode: Identifiable {
    let id = UUID()
    let code: String
    let flag: String
    let name: String
    let dialCode: String
    
    static let defaultCodes = [
        CountryCode(code: "IN", flag: "🇮🇳", name: "India", dialCode: "+91")
    ]
} 