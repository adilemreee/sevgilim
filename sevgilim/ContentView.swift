//
//  ContentView.swift
//  sevgilim
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        SplashScreenWrapper {
            Group {
                if authService.isAuthenticated {
                    if authService.currentUser?.relationshipId != nil {
                        MainTabView()
                    } else {
                        PartnerSetupView()
                    }
                } else {
                    LoginView()
                }
            }
        }
    }
}
