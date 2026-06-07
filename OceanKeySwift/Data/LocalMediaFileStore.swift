import Foundation
import UIKit

struct LocalMediaFileStore {
    private let rootDirectory: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        rootDirectory = supportDirectory.appendingPathComponent("OceanKeySwift", isDirectory: true)
    }

    func save(capturedMedia: CapturedMedia) throws -> MediaAttachment {
        switch capturedMedia {
        case .photo(let image):
            return try savePhoto(image)
        case .video(let temporaryURL):
            return try saveVideo(from: temporaryURL)
        }
    }

    func url(for attachment: MediaAttachment) -> URL {
        rootDirectory.appendingPathComponent(attachment.relativePath)
    }

    private func savePhoto(_ image: UIImage) throws -> MediaAttachment {
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            throw LocalMediaFileStoreError.cannotEncodePhoto
        }

        let id = UUID()
        let relativePath = "Media/\(id.uuidString).jpg"
        let destinationURL = rootDirectory.appendingPathComponent(relativePath)
        try prepareDirectory(for: destinationURL)
        try data.write(to: destinationURL, options: [.atomic])

        return MediaAttachment(id: id, kind: .photo, relativePath: relativePath, createdAt: Date())
    }

    private func saveVideo(from temporaryURL: URL) throws -> MediaAttachment {
        let id = UUID()
        let relativePath = "Media/\(id.uuidString).mov"
        let destinationURL = rootDirectory.appendingPathComponent(relativePath)
        try prepareDirectory(for: destinationURL)

        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: temporaryURL, to: destinationURL)

        return MediaAttachment(id: id, kind: .video, relativePath: relativePath, createdAt: Date())
    }

    private func prepareDirectory(for fileURL: URL) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}

enum LocalMediaFileStoreError: LocalizedError {
    case cannotEncodePhoto

    var errorDescription: String? {
        switch self {
        case .cannotEncodePhoto:
            "Не удалось сохранить фото."
        }
    }
}

