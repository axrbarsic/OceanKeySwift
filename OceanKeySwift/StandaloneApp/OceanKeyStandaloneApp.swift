import HospitalityFoundation
import OceanKeyHostedRoot
import OceanKeyLabContainer
import SwiftUI

@main
struct OceanKeyStandaloneApp: App {
    private static let bundleIdentifier = "com.alex.oceankey.swift"

    var body: some Scene {
        WindowGroup {
            OceanKeyEmbeddedRootView(
                bootstrap: OceanKeyHostedRootBootstrap(
                    runtimeContract: Self.runtimeContract,
                    configureApplicationSupportOverride: AppStorageDirectory.configureApplicationSupportOverride
                )
            )
            .preferredColorScheme(.dark)
        }
    }

    private static var runtimeContract: HospitalityContainerRuntimeContract {
        HospitalityContainerRuntimeContract.hosted(
            descriptor: OceanKeyLabContainer.descriptor,
            payloadKind: .thinStandaloneAppTarget,
            hostIdentity: HospitalityAppIdentity(
                displayName: "OceanKey Swift",
                bundleIdentifier: bundleIdentifier,
                storageNamespace: bundleIdentifier
            ),
            runtimeBundleIdentifier: bundleIdentifier,
            applicationSupportRoot: "OceanKeySwift",
            interactionPolicy: .standalone
        )
    }
}
