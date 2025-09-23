//
//  LoginView.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            Color.themeDarkBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App Icon/Logo
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.system(size: 80))
                        .foregroundColor(.themeRed)

                    Text("Lists")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.themeForeground)
                }

                // Login Form
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.themeForeground)

                            TextField("Enter your email", text: $email)
                                .textFieldStyle(LoginTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.themeForeground)

                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(LoginTextFieldStyle())
                        }
                    }

                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Login Button
                    Button(action: handleLogin) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }

                            Text(authService.isLoading ? "Signing In..." : "Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(loginButtonColor)
                        )
                    }
                    .disabled(authService.isLoading || !isFormValid)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    private var loginButtonColor: Color {
        if authService.isLoading || !isFormValid {
            return .gray
        }
        return .themeRed
    }

    // MARK: - Actions
    private func handleLogin() {
        errorMessage = ""

        authService.login(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Custom Text Field Style
struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.themeLightBackground)
            )
            .foregroundColor(.themeForeground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.themePlaceholder.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}