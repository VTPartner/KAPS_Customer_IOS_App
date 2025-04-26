import Foundation

class PreferenceManager {
    static let shared = PreferenceManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - String Values
    func setStringValue(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func getStringValue(_ key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    // MARK: - Boolean Values
    func setBooleanValue(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func getBooleanValue(_ key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    // MARK: - Integer Values
    func setIntegerValue(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func getIntegerValue(_ key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    
    // MARK: - Double Values
    func setDoubleValue(_ value: Double, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func getDoubleValue(_ key: String) -> Double {
        return defaults.double(forKey: key)
    }
    
    // MARK: - Clear All
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
} 
