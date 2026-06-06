import AppKit
import SwiftUI

struct FileBrowserView: View {
    @EnvironmentObject private var navigation: AppNavigation
    @EnvironmentObject private var store: FileProcessingStore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Header(title: "File Browser", subtitle: "Select any local file and calculate an MD5 hash without loading it into memory.")

            HStack(spacing: 12) {
                Button {
                    selectFile()
                } label: {
                    Label("Choose File", systemImage: "folder")
                }
                .buttonStyle(.borderedProminent)

                if store.selectedFile != nil {
                    Button {
                        store.startHashing()
                    } label: {
                        Label("Start MD5", systemImage: "play.fill")
                    }
                    .disabled(isHashing)

                    Button {
                        store.cancel()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .disabled(!isHashing)
                }
            }

            if let selectedFile = store.selectedFile {
                FileSummary(url: selectedFile, bytes: store.totalBytes)

                ProgressView(value: store.progress) {
                    Text(progressTitle)
                } currentValueLabel: {
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(store.processedBytes), countStyle: .file)) of \(ByteCountFormatter.string(fromByteCount: Int64(store.totalBytes), countStyle: .file))")
                }
                .progressViewStyle(.linear)
                .opacity(isHashing || store.progress > 0 ? 1 : 0.5)
            } else {
                ContentUnavailableView("No File Selected", systemImage: "doc.badge.plus")
                    .frame(maxWidth: .infinity, minHeight: 260)
            }

            resultView

            Spacer()
        }
        .padding(28)
        .navigationTitle("File Processing")
        .environmentObject(store)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    navigation.filePath.append(FileDestination.details)
                } label: {
                    Label("Details", systemImage: "doc.text.magnifyingglass")
                }
                .disabled(store.selectedFile == nil)

                Button {
                    navigation.filePath.append(FileDestination.hashResults)
                } label: {
                    Label("Hash Results", systemImage: "number.square")
                }
            }
        }
    }

    private var isHashing: Bool {
        if case .hashing = store.state { return true }
        return false
    }

    private var progressTitle: String {
        switch store.state {
        case .hashing: "Hashing file..."
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        case .failed: "Failed"
        default: "Ready"
        }
    }

    @ViewBuilder
    private var resultView: some View {
        switch store.state {
        case .completed(let result):
            HashResultCard(result: result)
        case .failed(let message):
            ErrorBanner(message: message) {
                store.startHashing()
            }
        case .cancelled:
            Text("Hashing cancelled.")
                .foregroundStyle(.secondary)
        default:
            EmptyView()
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if panel.runModal() == .OK, let url = panel.url {
            store.selectFile(url)
        }
    }
}

struct FileDetailsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Header(title: "File Details", subtitle: "The browser screen keeps its processing state while this route is open.")
            ActivityRow(title: "Large file support", detail: "FileHandle reads fixed-size chunks, so files over 10 GB are processed with bounded memory.")
            ActivityRow(title: "Cancellation", detail: "The background task checks cancellation between chunks.")
            ActivityRow(title: "Progress", detail: "Processed bytes are published on the main actor for SwiftUI.")
            Spacer()
        }
        .padding(28)
        .navigationTitle("File Details")
    }
}

struct HashResultsView: View {
    @EnvironmentObject private var store: FileProcessingStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Header(title: "Hash Results", subtitle: "Completed hashes appear on the File Browser screen after processing.")
            switch store.state {
            case .completed(let result):
                HashResultCard(result: result)
            case .hashing:
                ProgressView(value: store.progress) {
                    Text("Hashing \(store.selectedFile?.lastPathComponent ?? "selected file")...")
                } currentValueLabel: {
                    Text("\(ByteCountFormatter.string(fromByteCount: Int64(store.processedBytes), countStyle: .file)) of \(ByteCountFormatter.string(fromByteCount: Int64(store.totalBytes), countStyle: .file))")
                }
                .progressViewStyle(.linear)
            case .failed(let message):
                ErrorBanner(message: message) {
                    store.startHashing()
                }
            case .cancelled:
                Text("Hashing cancelled.")
                    .foregroundStyle(.secondary)
            default:
                Text("Select a file and run MD5 from File Browser.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(28)
        .navigationTitle("Hash Results")
    }
}

struct FileSummary: View {
    let url: URL
    let bytes: UInt64

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(url.lastPathComponent)
                .font(.headline)
                .lineLimit(nil)
                .textSelection(.enabled)
            Text(url.path(percentEncoded: false))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .textSelection(.enabled)
            Text(ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct HashResultCard: View {
    let result: FileHashResult

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("MD5 Result", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.green)
            Text(result.md5)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
            Text("\(ByteCountFormatter.string(fromByteCount: Int64(result.byteCount), countStyle: .file)) in \(result.duration.formatted(.number.precision(.fractionLength(2))))s")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}
