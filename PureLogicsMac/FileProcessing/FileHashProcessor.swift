import CryptoKit
import Foundation

struct FileHashResult: Equatable {
    let url: URL
    let byteCount: UInt64
    let md5: String
    let duration: TimeInterval
}

@MainActor
final class FileProcessingStore: ObservableObject {
    enum State: Equatable {
        case idle
        case hashing
        case completed(FileHashResult)
        case cancelled
        case failed(String)
    }

    @Published var selectedFile: URL?
    @Published var progress: Double = 0
    @Published var processedBytes: UInt64 = 0
    @Published var totalBytes: UInt64 = 0
    @Published var state: State = .idle

    private var task: Task<Void, Never>?

    deinit {
        task?.cancel()
    }

    func selectFile(_ url: URL) {
        task?.cancel()
        selectedFile = url
        progress = 0
        processedBytes = 0
        totalBytes = fileSize(url)
        state = .idle
    }

    func startHashing() {
        guard let selectedFile else { return }

        task?.cancel()
        progress = 0
        processedBytes = 0
        totalBytes = fileSize(selectedFile)
        state = .hashing

        task = Task { [weak self, selectedFile] in
            guard let self else { return }
            let startedAt = Date()
            do {
                let result = try await FileHashProcessor.hashMD5(url: selectedFile) { processed, total in
                    self.processedBytes = processed
                    self.totalBytes = total
                    self.progress = total > 0 ? Double(processed) / Double(total) : 0
                }

                guard !Task.isCancelled else {
                    self.markCancelled()
                    return
                }

                let completed = FileHashResult(
                    url: result.url,
                    byteCount: result.byteCount,
                    md5: result.md5,
                    duration: Date().timeIntervalSince(startedAt)
                )
                self.markCompleted(completed)
            } catch is CancellationError {
                self.markCancelled()
            } catch {
                self.markFailed(error.localizedDescription)
            }
        }
    }

    func cancel() {
        task?.cancel()
        state = .cancelled
    }

    private func markCompleted(_ result: FileHashResult) {
        progress = 1
        processedBytes = result.byteCount
        totalBytes = result.byteCount
        state = .completed(result)
    }

    private func markCancelled() {
        state = .cancelled
    }

    private func markFailed(_ message: String) {
        state = .failed(message)
    }

    private func fileSize(_ url: URL) -> UInt64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .totalFileAllocatedSizeKey])
        return UInt64(values?.fileSize ?? values?.totalFileAllocatedSize ?? 0)
    }
}

enum FileHashProcessor {
    struct HashOutput {
        let url: URL
        let byteCount: UInt64
        let md5: String
    }

    static func hashMD5(
        url: URL,
        chunkSize: Int = 8 * 1024 * 1024,
        progress: @MainActor @Sendable @escaping (UInt64, UInt64) -> Void
    ) async throws -> HashOutput {
        try await Task.detached(priority: .utility) {
            let accessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
            let totalBytes = (attributes[.size] as? NSNumber)?.uint64Value ?? 0

            let handle = try FileHandle(forReadingFrom: url)
            defer {
                try? handle.close()
            }

            var hasher = Insecure.MD5()
            var processedBytes: UInt64 = 0

            while true {
                try Task.checkCancellation()
                let data = try handle.read(upToCount: chunkSize) ?? Data()
                if data.isEmpty { break }

                hasher.update(data: data)
                processedBytes += UInt64(data.count)
                await progress(processedBytes, totalBytes)
            }

            let digest = hasher.finalize()
            let md5 = digest.map { String(format: "%02hhx", $0) }.joined()
            return HashOutput(url: url, byteCount: processedBytes, md5: md5)
        }.value
    }
}
