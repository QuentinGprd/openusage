import Foundation

@MainActor
protocol TelemetrySink: AnyObject {
    func capture(_ event: String, _ properties: [String: Any])
    func flush()
}

/// This build sends no telemetry. The sink keeps the recording call sites compiling, but every event is
/// dropped locally: no analytics SDK is linked, no install id leaves the Mac, and no crash report is
/// uploaded. See `docs/privacy.md`.
@MainActor
final class NoopTelemetrySink: TelemetrySink {
    func capture(_ event: String, _ properties: [String: Any]) {}
    func flush() {}
}
