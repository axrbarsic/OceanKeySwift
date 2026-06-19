import Foundation

enum AppStorageDirectory {
    private nonisolated(unsafe) static var applicationSupportOverride: URL?

    static func configureApplicationSupportOverride(_ directory: URL?) {
        applicationSupportOverride = directory
    }

    static func applicationSupportSubdirectory(
        fileManager: FileManager = .default
    ) -> URL {
        if let applicationSupportOverride {
            try? fileManager.createDirectory(at: applicationSupportOverride, withIntermediateDirectories: true)
            return applicationSupportOverride
        }

        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = supportDirectory.appendingPathComponent("OceanKeySwift", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
