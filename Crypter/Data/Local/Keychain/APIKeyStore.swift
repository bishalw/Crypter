//
//  APIKeyStore.swift
//  Crypter
//

import Foundation
import Security
import Combine

/// Stores the user's CoinGecko API key in the Keychain.
///
/// The key is read-only market data, not an account credential, but it is still
/// the user's property and does not belong in UserDefaults.
final class APIKeyStore: ObservableObject {

    enum Tier: String {
        /// Free key from the CoinGecko dashboard, sent as x-cg-demo-api-key.
        case demo
        /// Paid plan, sent as x-cg-pro-api-key against the pro host.
        case pro

        var headerField: String {
            switch self {
            case .demo: return "x-cg-demo-api-key"
            case .pro: return "x-cg-pro-api-key"
            }
        }

        var title: String {
            switch self {
            case .demo: return "Demo"
            case .pro: return "Pro"
            }
        }
    }

    @Published private(set) var key: String?
    @Published var tier: Tier {
        didSet {
            guard tier != oldValue else { return }
            defaults.set(tier.rawValue, forKey: tierKey)
        }
    }

    var hasKey: Bool {
        !(key ?? "").isEmpty
    }

    /// The header to attach to requests, if a key is set.
    var requestHeader: (field: String, value: String)? {
        guard let key, !key.isEmpty else { return nil }
        return (tier.headerField, key)
    }

    private let service = "com.bishalw.Crypter.coingecko"
    private let account = "apiKey"
    private let tierKey = "coingecko.keyTier"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.tier = Tier(rawValue: defaults.string(forKey: tierKey) ?? "") ?? .demo
        self.key = Self.read(service: service, account: account)
    }

    func save(_ newKey: String) {
        let trimmed = newKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            remove()
            return
        }

        guard let data = trimmed.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        guard SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess else { return }

        key = trimmed
    }

    func remove() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        SecItemDelete(query as CFDictionary)
        key = nil
    }

    private static func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
