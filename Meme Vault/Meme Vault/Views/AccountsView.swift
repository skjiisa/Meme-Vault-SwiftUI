//
//  AccountsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 11/19/20.
//

import SwiftUI

struct AccountsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Account.username, ascending: true)], animation: .spring())
    var accounts: FetchedResults<Account>

    @EnvironmentObject var providerController: ProviderController

    @State private var selectedAccount: Account?
    @State private var newAccount: Account?

    var body: some View {
        Form {
            Section {
                ForEach(accounts) { account in
                    AccountCell(account: account)
                }
                .onDelete { indexSet in
                    providerController.delete(accounts: indexSet.map { accounts[$0] }, context: moc)
                }
            }

            Section {
                Button() {
                    self.newAccount = providerController.createAccount(context: moc)
                } label: {
                    HStack {
                        Spacer()
                        Text("New Account")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Accounts")
        .sheet(item: $newAccount) { newAccount in
            NavigationView {
                LoginView(account: newAccount)
                    .environment(\.managedObjectContext, moc)
                    .environmentObject(providerController)
            }
        }
    }
}

fileprivate struct AccountCell: View {
    @ObservedObject var account: Account
    
    var body: some View {
        NavigationLink(destination: LoginView(account: account)) {
            TextWithCaption(text: account.username ?? "", caption: account.baseURL)
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountsView()
        }
    }
}
