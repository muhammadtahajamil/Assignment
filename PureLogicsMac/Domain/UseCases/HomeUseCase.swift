//
//  HomeUseCase.swift
//  PureLogicsMac
//
//  Created by Apple on 15/08/2026.

enum LockerType {
    case desktop
    case dropbox
    case googleDrive
    case onedrive
    
    var bookmark:String{
        switch self{
        case .desktop:
            return "DesktopUrlBookmark"
        case .dropbox:
            return "DropboxUrlBookmark"
        case .googleDrive:
            return "GoogleDriveUrlBookmark"
        case .onedrive:
            return "OneDriveUrlBookmark"
        }
    }
}


actor HomeUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    func checkDesktopUrl()->URL?{
        guard let url = getDriveUrlfromDefaults(key: LockerType.desktop.bookmark) else {
            return nil
        }
        return loadBookmark(bookmarkdata: url)
    }
    func checkDropboxUrl()->URL?{
        guard let url = getDriveUrlfromDefaults(key: LockerType.dropbox.bookmark) else {
            return nil
        }
        return loadBookmark(bookmarkdata: url)
    }
    func checkGoogleDriveUrl()->URL?{
        guard let url = getDriveUrlfromDefaults(key: LockerType.googleDrive.bookmark) else {
            return nil
        }
        return loadBookmark(bookmarkdata: url)
    }
    func checkOnedriveUrl()->URL?{
        guard let url = getDriveUrlfromDefaults(key:LockerType.onedrive.bookmark) else {
            return nil
        }
        return loadBookmark(bookmarkdata: url)
    }
    
    
    func setDriveUrlfromDefaults(url:URL, key:String) throws{
        do {
            // Create a security-scoped bookmark
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            // Store in a UserDefaults
            UserDefaults.standard.set(bookmarkData, forKey: key)

            print("✅ Bookmark saved for URL: \(url.path)")
        } catch {
            throw error
        }
    }
    
    private func getDriveUrlfromDefaults(key:String) -> Data? {
        if let storedUrl = UserDefaults.standard.url(forKey: key),
           let bookmarkData = Data(base64Encoded: storedUrl.absoluteString) {
            return bookmarkData
        }
        return nil
    }
    
    private func loadBookmark(bookmarkdata:Data) -> URL? {
        do {
            var isStale = false
            
            // Resolve the bookmark to get the original URL
            let resolvedURL = try URL(resolvingBookmarkData: bookmarkdata, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("Bookmark is stale, consider recreating it.")
            }
            
            // Start accessing the security-scoped resource
            if resolvedURL.startAccessingSecurityScopedResource() {
                print("Resolved and accessing URL: \(resolvedURL.path)")
                return resolvedURL
            } else {
                print("Failed to access security-scoped resource.")
                return nil
            }
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}
