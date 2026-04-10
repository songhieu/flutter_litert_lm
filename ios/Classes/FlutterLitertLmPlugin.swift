import Flutter
import UIKit

/// Flutter plugin for LiteRT-LM on iOS.
///
/// Note: LiteRT-LM Swift SDK is currently in development by Google.
/// This plugin provides the platform channel interface and will bridge to
/// the native SDK once it becomes available.
/// For now, it returns appropriate errors indicating iOS support is pending.
public class FlutterLitertLmPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "flutter_litert_lm",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "flutter_litert_lm/stream",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterLitertLmPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createEngine":
            handleCreateEngine(call, result: result)
        case "disposeEngine":
            handleDisposeEngine(call, result: result)
        case "createConversation":
            handleCreateConversation(call, result: result)
        case "disposeConversation":
            handleDisposeConversation(call, result: result)
        case "sendMessage":
            handleSendMessage(call, result: result)
        case "startMessageStream":
            handleStartMessageStream(call, result: result)
        case "countTokens":
            handleCountTokens(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Handler methods
    // TODO: Bridge to LiteRT-LM Swift/C++ SDK when available.
    // The channel protocol matches Android — once the native SDK ships,
    // swap these stubs for real calls.

    private func handleCreateEngine(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(
            code: "UNSUPPORTED",
            message: "LiteRT-LM iOS SDK is not yet available. Swift support is in development.",
            details: nil
        ))
    }

    private func handleDisposeEngine(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }

    private func handleCreateConversation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(
            code: "UNSUPPORTED",
            message: "LiteRT-LM iOS SDK is not yet available.",
            details: nil
        ))
    }

    private func handleDisposeConversation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }

    private func handleSendMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(
            code: "UNSUPPORTED",
            message: "LiteRT-LM iOS SDK is not yet available.",
            details: nil
        ))
    }

    private func handleStartMessageStream(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(
            code: "UNSUPPORTED",
            message: "LiteRT-LM iOS SDK is not yet available.",
            details: nil
        ))
    }

    private func handleCountTokens(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(
            code: "UNSUPPORTED",
            message: "LiteRT-LM iOS SDK is not yet available.",
            details: nil
        ))
    }
}
