import Foundation
let APP_CONFIG_CHANGED = "react-native-mdm/managedAppConfigDidChange"
@objc(MobileDeviceManager)
class RNMobileDeviceManager: RCTEventEmitter {
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { notification in
            self.settingsDidChange()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    override func supportedEvents() -> [String] {
        return [APP_CONFIG_CHANGED]
    }
    func settingsDidChange() {
        sendEvent(withName: APP_CONFIG_CHANGED, body: getAppConfig() ?? false)
    }
    func constantsToExport()->[String:Any] {
        return ["APP_CONFIG_CHANGED": APP_CONFIG_CHANGED]
    }
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