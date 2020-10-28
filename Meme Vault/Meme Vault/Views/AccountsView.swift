//
//  AccountsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/28/20.
//

import SwiftUI

struct AccountsView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)])
    var accounts: FetchedResults<Account>
    
    var body: some View {
        List {
            ForEach(accounts) { account in
                Text(account.username ?? "Account")
            }
        }
        .navigationTitle("Accounts")
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountsView()
        }
    }
}
