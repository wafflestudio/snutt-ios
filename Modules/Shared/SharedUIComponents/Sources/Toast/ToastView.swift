import SwiftUI
import SwiftUIUtility

struct ToastItemView: View {
    let toast: Toast
    let onButtonTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            if let button = toast.button {
                Button {
                    onButtonTap()
                } label: {
                    Text(button.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: "#B2F6F3"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(Color.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    struct PreviewContainer: View {
        @Environment(\.presentToast) var presentToast

        var body: some View {
            VStack(spacing: 20) {
                Text("Toast Preview")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                VStack(spacing: 16) {
                    Button("간단한 토스트") {
                        presentToast(
                            Toast(
                                message: "관심강좌가 등록되었습니다."
                            )
                        )
                    }

                    Button("버튼 있는 토스트") {
                        presentToast(
                            Toast(
                                message: "검색탭 우측 상단에서 관심강좌 목록을 확인해보세요.",
                                button: ToastButton(
                                    title: "보기",
                                    action: {
                                        print("보기 버튼 탭됨")
                                    }
                                )
                            )
                        )
                    }

                    Button("긴 메시지 토스트") {
                        presentToast(
                            Toast(
                                message: "수업 시작 10분 전에 푸시 알림을 보내드립니다.",
                                button: ToastButton(
                                    title: "확인",
                                    action: {
                                        print("확인 버튼 탭됨")
                                    }
                                )
                            )
                        )
                    }

                    Button("빈자리 알림 토스트") {
                        presentToast(
                            Toast(
                                message: "더보기탭에서 빈자리 알림 목록을 확인해보세요.",
                                button: ToastButton(
                                    title: "보기",
                                    action: {
                                        print("빈자리 알림 탭됨")
                                    }
                                )
                            )
                        )
                    }

                    Button("여러 개 연속 표시") {
                        presentToast(Toast(message: "첫 번째 토스트"))
                        Task {
                            try? await Task.sleep(for: .milliseconds(500))
                            presentToast(
                                Toast(
                                    message: "두 번째 토스트",
                                    button: ToastButton(title: "확인", action: {})
                                )
                            )
                            try? await Task.sleep(for: .milliseconds(500))
                            presentToast(Toast(message: "세 번째 토스트"))
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
        }
    }

    return PreviewContainer()
        .overlayToast()
}
