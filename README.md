# PureLogicsMac

Native macOS SwiftUI assignment app for the Senior iOS & macOS Engineer brief.

## Build

```bash
swift build
swift run PureLogicsMac
```

The project is a Swift Package executable app and uses Swift Package Manager for dependencies. It targets macOS 14+ and integrates `GRDB.swift` for local persistence.

To create a proper macOS `.app` bundle with a bundle identifier:

```bash
./Scripts/build_app.sh
open Build/PureLogicsMac.app
```

Use this app-bundle flow if Xcode or Console prints `Cannot index window tabs due to missing main bundle identifier` while running the raw SwiftPM executable.

The app also disables automatic macOS window tabbing at startup so this warning is suppressed when running from Xcode's Swift Package scheme.

## Open in Xcode

Open the native Xcode project:

1. Launch Xcode.
2. Choose **File > Open...**.
3. Select `/Users/taha/Downloads/PureLogics/PureLogicsMac.xcodeproj`.
4. Choose the `PureLogicsMac` scheme and press Run.

The Xcode app target has `PRODUCT_BUNDLE_IDENTIFIER = com.purelogics.assignment.PureLogicsMac` and resolves the local Swift Package dependency from `Vendor/GRDB.swift`.

## What Is Implemented

- `NavigationSplitView` with Dashboard, Users, and File Processing sections.
- Independent `NavigationPath` per sidebar section so each stack survives section switching.
- DummyJSON users API with async/await networking, loading/error/offline states, retry, and cached-first loading.
- GRDB-backed SQLite persistence for offline user viewing.
- Native SwiftUI `Table` with search, sorting, and stable selection for the user dataset.
- File picker and chunked MD5 hashing using `FileHandle`, `CryptoKit`, `Task`, cancellation, and progress updates.
- Adaptive SwiftUI layouts for resize, collapsed sidebar, and full-screen use.

## Architecture

The app uses MVVM-style state ownership:

- Views are declarative SwiftUI screens.
- `AppNavigation` owns sidebar selection and independent navigation stacks.
- `UserStore` is `@MainActor` and owns user list state, selected user state, loading state, retry, and offline fallback behavior.
- `UserRepository` coordinates networking and GRDB persistence.
- `FileProcessingStore` owns file selection, progress, cancellation, and completed hash state.

Concurrency is split intentionally: UI-facing stores run on the main actor, network/database calls are awaited, and large file hashing runs in a detached utility-priority task with bounded memory.

## Trade-Offs

- The DummyJSON API currently exposes a few hundred users rather than millions. The UI still uses native `Table`, filtering, and sorting patterns suitable for larger local datasets.
- MD5 is implemented because the assignment requests it. For security-sensitive production systems, SHA-256 or stronger would normally be preferred.
- The project is packaged as SPM for reliable creation in an empty folder. A production App Store build would typically add an `.xcodeproj`, signing, sandbox entitlements, and app icons.

## Assumptions

- macOS 14 or newer is acceptable.
- Network access is available for the first successful user refresh.
- Offline mode means previously fetched users remain viewable from SQLite when refresh fails.

## Approximate Time Spent

About 3 hours for assignment reading, implementation, build fixes, and verification.
