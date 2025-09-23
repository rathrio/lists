//
//  ContentView.swift
//  lists
//
//  Created by Rathesan Iyadurai on 23.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService.shared

    var body: some View {
        Group {
            if authService.isAuthenticated {
                ListsView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authService.checkAuthenticationStatus()
        }
    }
}

#Preview {
    ContentView()
}
