import SwiftUI

struct LicenseActivationView: View {
    @ObservedObject var manager: LicenseManager
    @State private var key = ""
    @FocusState private var keyFocused: Bool

    // SỬA LINK Ở ĐÂY NẾU SAU NÀY MUỐN ĐỔI.
    private let getKeyURL = URL(string: "https://tasksub.io/NMiObz")!
    private let zaloGroupURL = URL(string: "https://zalo.me/g/b9hrgchqbxgd80ogubuq")!
    private let telegramURL = URL(string: "https://t.me/sonchoigame123")!

    private let purple = Color(red: 0.55, green: 0.12, blue: 1.0)
    private let brightPurple = Color(red: 0.78, green: 0.30, blue: 1.0)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.07, green: 0.01, blue: 0.14), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(purple.opacity(0.28))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 150, y: -300)

            Circle()
                .fill(brightPurple.opacity(0.20))
                .frame(width: 280, height: 280)
                .blur(radius: 100)
                .offset(x: -150, y: 330)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(brightPurple)
                        .shadow(color: brightPurple.opacity(0.8), radius: 12)

                    Text("NSMOD")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(
                            LinearGradient(colors: [.white, brightPurple], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: purple.opacity(0.8), radius: 14)

                    Text("LICENSE SYSTEM")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .tracking(5)
                        .foregroundStyle(.white.opacity(0.78))

                    HStack(spacing: 13) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(brightPurple)

                        Text("Xác minh liên kết 1 lần để kích hoạt thiết bị.")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.88))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(purple.opacity(0.55), lineWidth: 1))

                    HStack(spacing: 12) {
                        Image(systemName: "key.fill")
                            .foregroundStyle(brightPurple)

                        TextField("ENTER YOUR KEY", text: $key)
                            .focused($keyFocused)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .onSubmit { activate() }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 17)
                    .frame(height: 58)
                    .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(brightPurple.opacity(0.85), lineWidth: 1.4))
                    .shadow(color: purple.opacity(0.28), radius: 12)

                    Button(action: activate) {
                        HStack(spacing: 10) {
                            Image(systemName: manager.isBusy ? "hourglass" : "bolt.fill")
                            Text(manager.isBusy ? "ĐANG XÁC MINH…" : "KÍCH HOẠT")
                        }
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(
                            LinearGradient(colors: [brightPurple, purple, Color(red: 0.30, green: 0.02, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.45), lineWidth: 1))
                        .shadow(color: purple.opacity(0.55), radius: 18, y: 8)
                    }
                    .buttonStyle(.plain)
                    .disabled(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || manager.isBusy)
                    .opacity(key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)

                    HStack(spacing: 10) {
                        actionButton("GET KEY", icon: "link", tint: Color(red: 1.0, green: 0.65, blue: 0.08)) {
                            UIApplication.shared.open(getKeyURL)
                        }

                        actionButton("NHÓM ZALO", icon: "person.2.fill", tint: Color(red: 0.08, green: 0.48, blue: 1.0)) {
                            UIApplication.shared.open(zaloGroupURL)
                        }

                        actionButton("TELEGRAM", icon: "paperplane.fill", tint: Color(red: 0.05, green: 0.72, blue: 1.0)) {
                            UIApplication.shared.open(telegramURL)
                        }
                    }

                    if let message = manager.message, !manager.isActive {
                        Text(message)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(message.contains("không hợp lệ") ? Color.red : .white.opacity(0.72))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(22)
                .background(.ultraThinMaterial.opacity(0.58), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .background(Color(red: 0.05, green: 0.01, blue: 0.10).opacity(0.72), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(brightPurple.opacity(0.75), lineWidth: 1.4))
                .shadow(color: purple.opacity(0.42), radius: 28)
                .padding(.horizontal, 18)
                .padding(.vertical, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .onChange(of: manager.isActive) { active in
            guard active else { return }
            // Chỉ xảy ra khi vừa nhập đúng Key ở màn hình này.
            UIApplication.shared.open(telegramURL)
        }
    }

    private func actionButton(_ title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(tint.opacity(0.17), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 17).stroke(tint, lineWidth: 1.5))
            .shadow(color: tint.opacity(0.25), radius: 10)
        }
        .buttonStyle(.plain)
    }

    private func activate() {
        keyFocused = false
        manager.activate(key: key)
    }
}
