import Combine
import Foundation
import Security

@MainActor
final class LicenseManager: ObservableObject {
    static let accessKey = "NSMODVIP"

    @Published private(set) var expirationDate: Date?
    @Published private(set) var isActive = false
    @Published private(set) var isBusy = false
    @Published private(set) var message: String?
    @Published private(set) var contactOwner: String?

    private let service = "com.NSMOD.external-ios.activation"
    private let activationAccount = "nsmod-activated"
    private let activationValue = "1"
    private var lastAttemptAt: Date?

    init() {
        isActive = hasActivated
    }

    var hasActivated: Bool {
        string(for: activationAccount) == activationValue
    }

    func beginLaunchSession() {
        isActive = hasActivated
        message = isActive ? nil : "Nhập Key để kích hoạt"
    }

    func activate(key: String) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isBusy else { return }

        if let lastAttemptAt, Date().timeIntervalSince(lastAttemptAt) < 1 {
            message = "Vui lòng thử lại sau một chút"
            return
        }

        lastAttemptAt = Date()
        isBusy = true
        message = "Đang xác minh…"

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isBusy = false

            guard trimmed == Self.accessKey else {
                self.isActive = false
                self.message = "Key không hợp lệ"
                return
            }

            // Chỉ lưu trạng thái đã kích hoạt, không lưu nội dung Key.
            self.save(self.activationValue, for: self.activationAccount)
            self.message = "Kích hoạt thành công"
            self.isActive = true
        }
    }

    func refresh() {
        isActive = hasActivated
        message = isActive ? nil : "Nhập Key để kích hoạt"
    }

    func deactivate() {
        delete(activationAccount)
        isActive = false
        message = "Đã xóa trạng thái kích hoạt"
    }

    private func string(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func save(_ value: String, for account: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(base as CFDictionary)
        var item = base
        item[kSecValueData as String] = Data(value.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }

    private func delete(_ account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
