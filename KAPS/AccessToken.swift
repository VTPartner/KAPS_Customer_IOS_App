import Foundation

class AccessToken {
    private static var cachedToken: String?
    private static var tokenExpiry: TimeInterval = 0
    
    static func getAccessToken() -> String? {
        // Return cached token if it's still valid
        if let token = cachedToken, !token.isEmpty, Date().timeIntervalSince1970 < tokenExpiry {
            return token
        }
        
        // Get new token
        return fetchNewToken()
    }
    
    private static func fetchNewToken() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var resultToken: String?
        
        let url = APIClient.baseUrl + "get_agent_app_firebase_access_token"
        
        NetworkManager.shared.getRequest(url: url) { result in
            switch result {
            case .success(let response):
                if let status = response["status"] as? String,
                   status == "success",
                   let token = response["token"] as? String {
                    // Cache the token with 50 minutes expiry
                    cachedToken = token
                    tokenExpiry = Date().timeIntervalSince1970 + (50 * 60)
                    resultToken = token
                }
            case .failure(let error):
                print("Error fetching access token: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30) // 30 seconds timeout
        return resultToken
    }
    
    static func getCustomerAccessToken() -> String? {
        // Return cached token if it's still valid
        if let token = cachedToken, !token.isEmpty, Date().timeIntervalSince1970 < tokenExpiry {
            return token
        }
        
        // Get new token
        return fetchCustomerNewToken()
    }
    
    private static func fetchCustomerNewToken() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var resultToken: String?
        
        let url = APIClient.baseUrl + "get_customer_app_firebase_access_token"
        
        NetworkManager.shared.getRequest(url: url) { result in
            switch result {
            case .success(let response):
                if let status = response["status"] as? String,
                   status == "success",
                   let token = response["token"] as? String {
                    // Cache the token with 50 minutes expiry
                    cachedToken = token
                    tokenExpiry = Date().timeIntervalSince1970 + (50 * 60)
                    resultToken = token
                }
            case .failure(let error):
                print("Error fetching customer access token: \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 30) // 30 seconds timeout
        return resultToken
    }
} 