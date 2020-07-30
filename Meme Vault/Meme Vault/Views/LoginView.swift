//
//  LoginView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var providerController: ProviderController
    
    @State private var url: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var alert: AlertRepresentation?
    
    func login() {
        providerController.login(host: url, username: username, password: password)
        providerController.webdavProvider?.contentsOfDirectory(path: "/", completionHandler: { files, error in
            if let error = error {
                let message = "\(error)"
                alert = AlertRepresentation(title: "Login Failed", message: message)
                return
            }
            
            alert = AlertRepresentation(title: "Login Successful")
            print(files)
        })
    }
    
    var body: some View {
        Form {
            Section(header: Text("WebDAV Server URL")) {
                TextField("https://nextcloud.example.com/remote.php/webdav/", text: $url)
            }
            
            Section(header: Text("Account")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password) {
                    login()
                }
            }
        }
        .alert(item: $alert) { alert in
            alert.alert
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
