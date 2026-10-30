//
//  EvaluationEmailVerificationScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

/// Shows the evaluations once the user's email is verified, and the verification form until then.
struct EvaluationEmailVerificationGate<Content: View, Placeholder: View>: View {
    @State private var viewModel = EvaluationEmailVerificationViewModel()
    private let onClose: (() -> Void)?
    private let content: () -> Content
    private let placeholder: () -> Placeholder

    /// - Parameters:
    ///   - onClose: Adds a close button to the form, for gates presented modally.
    ///   - placeholder: Shown while the status is checked. Matching the content's own loading skeleton
    ///     makes the check and the content's loading read as one step.
    init(
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.onClose = onClose
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            switch viewModel.status {
            case .checking:
                placeholder()
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            case .unverified:
                EvaluationEmailVerificationScene(viewModel: viewModel, onClose: onClose)
                    .transition(.opacity)
            case .verified:
                content()
                    .transition(.opacity)
            }
        }
        .animation(.smooth(duration: 0.25), value: viewModel.status)
        .onLoad {
            await viewModel.checkStatus()
        }
    }
}

extension EvaluationEmailVerificationGate where Placeholder == EvaluationGateProgressView {
    init(onClose: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.init(onClose: onClose, content: content) { EvaluationGateProgressView() }
    }
}

struct EvaluationGateProgressView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
    }
}

struct EvaluationEmailVerificationScene: View {
    @Bindable var viewModel: EvaluationEmailVerificationViewModel
    let onClose: (() -> Void)?

    private enum Field {
        case email
        case code
    }

    @FocusState private var focusedField: Field?
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    emailSection
                    if viewModel.codeRecipient != nil {
                        codeSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    if viewModel.isEmailInUse {
                        emailInUseGuide
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                // Keeps the form at a readable width on iPad.
                .frame(maxWidth: 560, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(uiColor: .systemBackground))
            .safeAreaInset(edge: .bottom) {
                submitButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .frame(maxWidth: 560)
            }
            .animation(.defaultSpring, value: viewModel.codeRecipient)
            .animation(.defaultSpring, value: viewModel.isEmailInUse)
            .navigationTitle(EvaluationsStrings.verifyTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let onClose {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(EvaluationsStrings.close, systemImage: "xmark", action: onClose)
                    }
                }
            }
        }
        .analyticsScreen(.reviewEmailVerification)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(EvaluationsStrings.verifyHeadline)
                .font(.title3.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
            Text(EvaluationsStrings.verifyDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: Email

    private var emailSection: some View {
        fieldGroup(EvaluationsStrings.verifyEmail) {
            HStack(spacing: 8) {
                HStack(spacing: 2) {
                    TextField(EvaluationsStrings.verifyEmailPlaceholder, text: $viewModel.emailID)
                        .keyboardType(.asciiCapable)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.send)
                        .focused($focusedField, equals: .email)
                        .onSubmit(requestCode)
                    Text(EvaluationEmailVerificationViewModel.emailDomain)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .fieldStyle(isFocused: focusedField == .email)

                Button(action: requestCode) {
                    Group {
                        if viewModel.isRequestingCode {
                            ProgressView()
                        } else {
                            Text(
                                viewModel.codeRecipient == nil
                                    ? EvaluationsStrings.verifyRequestCode : EvaluationsStrings.verifyRequestCodeAgain
                            )
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.canRequestCode ? EvaluationDesignColor.accent : .secondary)
                    .padding(.horizontal, 16)
                    .frame(minWidth: 88, minHeight: 48)
                    .background(
                        viewModel.canRequestCode
                            ? EvaluationDesignColor.accentBackground : Color(uiColor: .secondarySystemBackground),
                        in: .rect(cornerRadius: 12, style: .continuous)
                    )
                }
                .buttonStyle(.animatable(scale: 0.97))
                .disabled(!viewModel.canRequestCode)
            }
        }
    }

    private func requestCode() {
        guard viewModel.canRequestCode else { return }
        errorAlertHandler.withAlert {
            try await viewModel.requestCode()
            focusedField = .code
        }
    }

    // MARK: Code

    private var codeSection: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let isExpired = viewModel.isCodeExpired(at: context.date)
            fieldGroup(EvaluationsStrings.verifyCode) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        TextField(EvaluationsStrings.verifyCodePlaceholder, text: $viewModel.code)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .code)
                            .onChange(of: viewModel.code) { _, code in
                                let digits = String(
                                    code.filter(\.isNumber).prefix(EvaluationEmailVerificationViewModel.codeLength)
                                )
                                if digits != code {
                                    viewModel.code = digits
                                }
                            }
                        remainingTime(viewModel.remainingCodeTime(at: context.date))
                    }
                    .fieldStyle(isFocused: focusedField == .code)

                    if isExpired {
                        Label(EvaluationsStrings.verifyCodeExpired, systemImage: "exclamationmark.circle")
                            .foregroundStyle(.red)
                    } else if let recipient = viewModel.codeRecipient {
                        Text(EvaluationsStrings.verifyCodeSent(recipient))
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.footnote)
            }
        }
    }

    private func remainingTime(_ remaining: TimeInterval) -> some View {
        let text = Duration.seconds(remaining.rounded(.up)).formatted(.time(pattern: .minuteSecond))
        return Text(text)
            .font(.subheadline.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(remaining > 0 ? EvaluationDesignColor.accent : .secondary)
            .accessibilityLabel(EvaluationsStrings.verifyCodeRemainingAccessibility(text))
    }

    // MARK: Submit

    private var submitButton: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Button {
                focusedField = nil
                errorAlertHandler.withAlert {
                    try await viewModel.verify()
                }
            } label: {
                Group {
                    if viewModel.isVerifying {
                        ProgressView()
                    } else {
                        Text(EvaluationsStrings.verifySubmit)
                    }
                }
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 32)
            }
            .prominentButtonStyle()
            .controlSize(.large)
            .tint(EvaluationDesignColor.accent)
            .disabled(!viewModel.canVerify(at: context.date))
        }
    }

    // MARK: Guide

    private var emailInUseGuide: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(EvaluationsStrings.verifyAlreadyUsedTitle)
                .font(.footnote.weight(.semibold))
            Text(EvaluationsStrings.verifyAlreadyUsedDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EvaluationDesignColor.sectionSeparator, in: .rect(cornerRadius: 12, style: .continuous))
    }

    private func fieldGroup(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.callout.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

extension View {
    /// Matches the review editor in the write form: a filled rounded field outlined in the accent color while focused.
    fileprivate func fieldStyle(isFocused: Bool) -> some View {
        font(.body)
            .padding(.horizontal, 14)
            .frame(minHeight: 48)
            .background(
                Color(uiColor: .secondarySystemBackground),
                in: .rect(cornerRadius: 12, style: .continuous)
            )
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(EvaluationDesignColor.accent, lineWidth: 1.5)
                }
            }
            .animation(.smooth(duration: 0.2), value: isFocused)
    }

    @ViewBuilder
    fileprivate func prominentButtonStyle() -> some View {
        if #available(iOS 26, *) {
            buttonStyle(.glassProminent)
        } else {
            buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
        }
    }
}

#Preview("Form") {
    EvaluationEmailVerificationScene(viewModel: EvaluationEmailVerificationViewModel(), onClose: {})
}
