"use strict";
import { DeviceEventEmitter, NativeModules } from "react-native";
const { MobileDeviceManager } = NativeModules;
async function isSupported() {
  return await MobileDeviceManager.isSupported();
}
async function getConfiguration() {
  return await MobileDeviceManager.getConfiguration();
}
function addListener(callback) {
  return DeviceEventEmitter.addListener(
    MobileDeviceManager.APP_CONFIG_CHANGED,
    callback
  );
}
async function isAutonomousSingleAppModeSupported() {
  return await MobileDeviceMananger.isAutonomousSingleAppModeSupported();
}
async function isSingleAppModeEnabled() {
  return await MobileDeviceMananger.isSingleAppModeEnabled();
}
async function isAutonomousSingleAppModeEnabled() {
  return await MobileDeviceMananger.isAutonomousSingleAppModeEnabled();
}
async function enableAutonomousSingleAppMode() {
  return await MobileDeviceMananger.enableAutonomousSingleAppMode();
}
async function disableAutonomousSingleAppMode() {
  return await MobileDeviceManager.disableAutonomousSingleAppMode();
}

export default {
  isSupported,
  getConfiguration,
  addListener,
  isAutonomousSingleAppModeSupported,
  isAutonomousSingleAppModeEnabled,
  isSingleAppModeEnabled,
  enableAutonomousSingleAppMode,
  disableAutonomousSingleAppMode
};
