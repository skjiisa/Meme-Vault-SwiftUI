//
//  LoginView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var providerController: ProviderController
    @EnvironmentObject var nextcloudController: NextcloudController
    
    @State private var url: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var nextcloud = true
    
    @State private var loggingIn = false
    @State private var alert: AlertRepresentation?
    
    @ObservedObject var account: Account
    
    init(account: Account) {
        _url = .init(wrappedValue: account.baseURL ?? "")
        _username = .init(wrappedValue: account.username ?? "")
        self.account = account
    }
    
    var body: some View {
        Form {
            Section(header: Text("WebDAV Server URL"), footer: Text("Server must support SSL (HTTPS).")) {
                TextField("https://nextcloud.example.com/", text: $url)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Toggle(isOn: $nextcloud) {
                    VStack(alignment: .leading) {
                        Text("Nextcloud")
                        Text("Automatically adds DAV extension to URL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Account")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password) {
                    login()
                }
                .disabled(loggingIn)
            }
            
            HStack {
                Button("Login") {
                    login()
                }
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
        .onDisappear {
            if !presentationMode.wrappedValue.isPresented,
               username.isEmpty,
               url.isEmpty {
                nextcloudController.delete(account: account, context: moc)
            }
        }
    }
    
    func login() {
        loggingIn = true
        /*
        var url = self.url
        if nextcloud {
            url = providerController.append(fileNamed: "remote.php/dav/files/\(username)/", to: url)
        }
        url = providerController.ssl(url)
        providerController.login(host: url, username: username, password: password)
        providerController.webdavProvider?.contentsOfDirectory(path: "/", completionHandler: { files, error in
            loggingIn = false
            if let error = error {
                let message = "\(error)"
                alert = AlertRepresentation(title: "Login Failed", message: message)
                return
            }

            alert = AlertRepresentation(title: "Login Successful")
            print(files)
        })
         */
        account.username = username
        account.baseURL = url
        nextcloudController.testLogin(account: account, password: password) { success, errorDescription in
            if success {
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                alert = AlertRepresentation(title: "Login Failed", message: errorDescription)
            }
            loggingIn = false
        }
    }
    
}
