import Foundation
let APP_CONFIG_CHANGED = "react-native-mdm/managedAppConfigDidChange"
let MDM_CONFIGURATION_KEY = "com.apple.configuration.managed"
let MDM_CACHED_CONFIGURATION_KEY = "com.appconfig.configuration.persisted"
@objc(MobileDeviceManager)
class RNMobileDeviceManager: RCTEventEmitter {
    //MARK: Lifecycle
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { notification in
            self.sendEvent(withName: APP_CONFIG_CHANGED, body: self.getAppConfig() ?? false)
            self.persistConfig(self.getAppConfig()) // Not sure this is really important - not leveraged in this module
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    //MARK: Overrides
    func requiresMainQueueSetup() -> Bool {
        return false
    }
    func constantsToExport()->[String:Any] {
        return ["APP_CONFIG_CHANGED": APP_CONFIG_CHANGED]
    }
    override func supportedEvents() -> [String] {
        return [APP_CONFIG_CHANGED]
    }
    //MARK: Core App Config functions
    func getAppConfig() -> [String:Any]? {
        return UserDefaults.standard.dictionary(forKey:MDM_CONFIGURATION_KEY)
    }
    @objc func isSupported(_ resolve: RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        if let _ = getAppConfig() {
            resolve(true)
        } else {
            resolve(false)
        }
    }
    @objc func getConfiguration(_ resolve: RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        if let a = getAppConfig() {
            resolve(a)
        } else {
            reject("not-support", "Managed App Config is not supported", nil)
        }
    }
    //MARK: Kiosk Mode support
    @objc func isAutonomousSingleAppModeSupported(_ resolve: @escaping RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        _isAutonomousSingleAppModeSupported() { result in
            resolve(result)
        }
    }
    func _isAutonomousSingleAppModeSupported(_ callback:@escaping (Bool)->Void) {
        DispatchQueue.main.async() {
            let enabled =  UIAccessibilityIsGuidedAccessEnabled()
            UIAccessibilityRequestGuidedAccessSession(!enabled) { didSucceed in
                if didSucceed {
                    UIAccessibilityRequestGuidedAccessSession(enabled) { didSucceed in
                        callback(didSucceed)
                    }
                } else {
                    callback(didSucceed) // false
                }
            }
        }
    }
    @objc func isSingleAppModeSupported(_ resolve: @escaping RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async() {
            resolve(UIAccessibilityIsGuidedAccessEnabled())
        }
    }
    @objc func isAutonomousSingleAppModeEnabled(_ resolve: @escaping RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        _isAutonomousSingleAppModeSupported() { isASAM in
            guard isASAM else { resolve(false) ; return }
            resolve(UIAccessibilityIsGuidedAccessEnabled())
        }
    }
    @objc func enableAutonomousSingleAppMode(_ resolve: @escaping RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async() {
            UIAccessibilityRequestGuidedAccessSession(true) { didSucceed in
                resolve(didSucceed)
            }
        }
    }
    @objc func disableAutonomousSingleAppMode(_ resolve: @escaping RCTPromiseResolveBlock , reject: RCTPromiseRejectBlock) {
        DispatchQueue.main.async() {
            UIAccessibilityRequestGuidedAccessSession(false) { didSucceed in
                resolve(didSucceed)
            }
        } 
    }
    //MARK: Saving persistent copy
    func persistConfig(_ obj:[String:Any]?) {
        let d = UserDefaults.standard
        if let o = obj {
            d.set(o, forKey: MDM_CACHED_CONFIGURATION_KEY)
        } else {
            d.removeObject(forKey: MDM_CACHED_CONFIGURATION_KEY)
        }
        d.synchronize()
    }
}
