//
//  BillboardAd.swift
//
//
//  Created by Hidde van der Ploeg on 30/06/2023.
//

import Foundation
import SwiftUI

public struct BillboardAd: Codable, Identifiable, Hashable {
    public static func == (lhs: BillboardAd, rhs: BillboardAd) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var id: String {
        return "\(self.default.name)+\(appStoreID)"
    }

    /// Should be the Apple ID of App that's connected to the Ad (e.g. 1596487035)
    public let appStoreID: String

    /// Default content (usually in English)
    public let `default`: LocalizedContent

    /// Localized content for different languages
    public let locales: [String: LocalizedContent]

    /// Main Background color in HEX format
    public let backgroundColor: String

    /// Text color in HEX format
    public let textColor: String

    /// Main tint color in HEX format
    public let tintColor: String

    /// For fullscreen media styling (should be true when the main image is a photo)
    public let fullscreen: Bool

    /// Allows blurred background when the main image is a PNG
    public let transparent: Bool

    public var background: Color {
        return Color(hex: self.backgroundColor)
    }

    public var text: Color {
        return Color(hex: self.textColor)
    }

    public var tint: Color {
        return Color(hex: self.tintColor)
    }

    /// App Store Link based on `appStoreID`
    public var appStoreLink: URL? {
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    public var appIconURL: URL? {
        return URL(string: "http://itunes.apple.com/lookup?id=\(appStoreID)")
    }

    public func getAppIcon() async throws -> Data? {
        guard let appIconURL else { return nil }
        let session = URLSession(configuration: BillboardViewModel.networkConfiguration)
        session.sessionDescription = "Fetching App Icon"

        do {
            let (data, _) = try await session.data(from: appIconURL)
            let decoder = JSONDecoder()
            let response = try decoder.decode(AppIconResponse.self, from: data)
            guard let artworkUrlStr = response.results.first?.artworkUrl100, let artworkURL = URL(string: artworkUrlStr) else { return nil }

            return try? Data(contentsOf: artworkURL)

        } catch {
            return nil
        }
    }

    public func getLocalizedContent(for locale: String) -> LocalizedContent {
        return locales[locale] ?? `default`
    }

    public func getName() -> String {
        getLocalizedContent().name
    }

    public func getTitle() -> String {
        getLocalizedContent().title
    }

    public func getDescription() -> String {
        getLocalizedContent().description
    }

    public func mediaURL() -> URL {
        getLocalizedContent().media
    }

    private func getLocalizedContent() -> LocalizedContent {
        let preferredLanguages = Locale.preferredLanguages

        for language in preferredLanguages {
            let languageCode = Locale(identifier: language).languageCode ?? language

            // Check if the preferred language matches the default language
            if languageCode == getDefaultLanguageCode() {
                return `default`
            }

            // Check if we have a localization for this language
            if let localizedContent = locales[languageCode] {
                return localizedContent
            }
        }

        // If no match found, return default
        return `default`
    }

    private func getDefaultLanguageCode() -> String {
        // Assuming the default language is English. Adjust if different.
        return "en"
    }

}

public struct LocalizedContent: Codable, Hashable {
    /// Name of ad (e.g. NowPlaying)
    public let name: String

    /// Title that's displayed on the Ad (Recommended to be no more than 25 characters)
    public let title: String

    /// Description that's displayed on the Ad (Recommended to be no more than 140 characters)
    public let description: String

    /// URL of image that's used in the Ad
    public let media: URL
}

public struct AppIconResponse: Codable {
    let results: [AppIconResult]
}

public struct AppIconResult: Codable {
    let artworkUrl100: String
}
