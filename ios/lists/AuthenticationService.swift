//
//  AuthenticationService.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import Foundation
import Combine

// MARK: - Auth Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}

struct AuthError: Error, LocalizedError {
    let message: String

    var errorDescription: String? {
        return message
    }
}

// MARK: - Authentication Service
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var isAuthenticated = false
    @Published var isLoading = false

    private let baseURL = "http://localhost:3000"
    private let session = URLSession.shared
    private let keychainManager = KeychainManager.shared

    private init() {
        checkAuthenticationStatus()
    }

    // MARK: - Check Authentication Status
    func checkAuthenticationStatus() {
        isAuthenticated = keychainManager.hasToken()
    }

    // MARK: - Login
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/mobile/sign_in") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        let loginRequest = LoginRequest(email: email, password: password)

        guard let requestData = try? JSONEncoder().encode(loginRequest) else {
            return Fail(error: AuthError(message: "Failed to encode request"))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        isLoading = true

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AuthError(message: "Invalid response")
                }

                if httpResponse.statusCode == 401 {
                    throw AuthError(message: "Invalid credentials")
                } else if httpResponse.statusCode != 200 {
                    throw AuthError(message: "Login failed")
                }

                return data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .tryMap { [weak self] loginResponse -> Void in
                guard let self = self else { throw AuthError(message: "Service unavailable") }

                // Save token to keychain
                guard self.keychainManager.saveToken(loginResponse.token) else {
                    throw AuthError(message: "Failed to save authentication token")
                }

                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isLoading = false
                }

                return ()
            }
            .catch { [weak self] error -> AnyPublisher<Void, Error> in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Logout
    func logout() -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/mobile/sign_out") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authorization header if we have a token
        if let token = keychainManager.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] _, response -> Void in
                guard let self = self else { return }

                // Always clear local token regardless of server response
                _ = self.keychainManager.deleteToken()

                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }

                return ()
            }
            .catch { [weak self] error -> AnyPublisher<Void, Error> in
                // Even if logout request fails, clear local token
                _ = self?.keychainManager.deleteToken()
                DispatchQueue.main.async {
                    self?.isAuthenticated = false
                }
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Get Authorization Header
    func getAuthorizationHeader() -> String? {
        guard let token = keychainManager.getToken() else { return nil }
        return "Bearer \(token)"
    }
}