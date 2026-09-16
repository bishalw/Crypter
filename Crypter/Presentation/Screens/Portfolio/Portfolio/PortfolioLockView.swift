//
//  PortfolioLockView.swift
//  Crypter
//

import SwiftUI
import LocalAuthentication

@MainActor
final class PortfolioLock: ObservableObject {
    static let storageKey = "locksPortfolio"

    @Published private(set) var isUnlocked = false
    @Published private(set) var failureMessage: String?

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: Self.storageKey)
    }

    /// Whether the device can actually do this, so Settings can hide the toggle
    /// rather than offer a switch that would fail.
    static var isAvailable: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    static var biometryName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)

        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "your passcode"
        }
    }

    func lock() {
        guard isEnabled else { return }
        isUnlocked = false
    }

    func unlock() async {
        guard isEnabled else {
            isUnlocked = true
            return
        }

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock your portfolio"
            )
            isUnlocked = success
            failureMessage = success ? nil : "Authentication failed."
        } catch {
            failureMessage = (error as? LAError)?.code == .userCancel ? nil : error.localizedDescription
        }
    }
}

/// Covers the portfolio until the owner authenticates.
struct PortfolioLockView: View {
    @ObservedObject var lock: PortfolioLock

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundColor(Color.theme.brandPrimary)
                .frame(width: 100, height: 100)
                .background(Circle().fill(Color.theme.brandSoft))

            VStack(spacing: 6) {
                Text("Portfolio locked")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text("Unlock with \(PortfolioLock.biometryName) to see your holdings.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if let failureMessage = lock.failureMessage {
                Text(failureMessage)
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.statusDanger)
            }

            Button {
                Task { await lock.unlock() }
            } label: {
                Text("Unlock")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.surfaceBackground)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 28)
                    .background(Capsule().fill(Color.theme.brandPrimary))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.surfaceBackground.ignoresSafeArea())
        .task {
            await lock.unlock()
        }
    }
}
