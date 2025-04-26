import Foundation

struct APIClient {
    static let razorpayKey = "rzp_test_61op4YoSkMBW6u"
    static let mapKey = "AIzaSyAAlmEtjJOpSaJ7YVkMKwdSuMTbTx39l_o"
    
    private static let devMode = 1 // If Dev Mode is 1 then development server is on and if 0 then production server is on
    
//    static let baseUrl = devMode == 1
//        ? "http://100.24.44.74:8000/api/vt_partner/"
//        : "http://100.24.44.74/api/vt_partner/"
    
    static let baseUrl = devMode == 1
            ? "http://100.24.44.74:8000/api/vt_partner/"
            : "https://www.kaps9.in/api/vt_partner/"
}
