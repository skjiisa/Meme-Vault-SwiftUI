//
//  LoginView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var providerController: ProviderController
    
    @ObservedObject var account: Account
    
    @State private var url: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var nextcloud = true
    @State private var textFieldsInit = false
    
    @State private var loggingIn = false
    @State private var alert: AlertRepresentation?
    
    var body: some View {
        Form {
            Section(header: Text("WebDAV Server URL"), footer: Text("Server must support SSL (HTTPS).")) {
                TextField("https://nextcloud.example.com/", text: $url)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Toggle(isOn: $nextcloud) {
                    TextWithCaption(text: "Nextcloud", caption: "Automatically adds DAV extension to URL")
                }
            }
            
            Section(header: Text("Account")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password, onCommit: login)
                .disabled(loggingIn)
            }
            
            HStack {
                Button("Login", action: login)
                .disabled(loggingIn)
                
                if loggingIn {
                    Spacer()
                    ProgressView()
                }
            }
        }
        .navigationTitle("Account")
        .alert(item: $alert) { alert in
            alert.alert
        }
        .onAppear {
            if !textFieldsInit {
                url = account.baseURL ?? ""
                username = account.username ?? ""
                textFieldsInit = true
            }
        }
    }
    
    private func login() {
        guard !loggingIn else { return }
        loggingIn = true
        account.username = username
        
        if nextcloud {
            account.baseURL = url
            providerController.setNextcloudURL(account: account)
        } else {
            account.baseURL = providerController.https(url)
        }
        
        // Test credentials by listing files in root directory
        providerController.webdav.listFiles(atPath: "/", account: account, password: password) { _, error in
            loggingIn = false
            
            switch error {
            case .invalidCredentials, .unauthorized:
                alert = .init(title: "Login failed", message: "Invalid credentials")
            case .nsError(let nsError):
                alert = .init(title: "Login failed", message: "\(nsError)")
            case .insufficientStorage, .none:
                alert = .init(title: "Login successful")
                // Save password
                try? moc.save()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
//            LoginView(account: <#T##Account#>)
        }
    }
}
