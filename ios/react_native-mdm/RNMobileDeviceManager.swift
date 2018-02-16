import Foundation
let APP_CONFIG_CHANGED = "react-native-mdm/managedAppConfigDidChange"
let MDM_CONFIGURATION_KEY = "com.apple.configuration.managed"
@objc(MobileDeviceManager)
class RNMobileDeviceManager: RCTEventEmitter {
    //MARK: Lifecycle
    var listeners = 0
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { notification in
            if self.listeners > 0 { self.sendEvent(withName: APP_CONFIG_CHANGED, body: self.getAppConfig() ?? false) }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    //MARK: Overrides
    override func addListener(_ eventName: String!) {
        if eventName == APP_CONFIG_CHANGED { listeners = listeners + 1 }
    }
    override func removeListeners(_ count: Double) {
        listeners = listeners - Int(count)
    }
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
}
