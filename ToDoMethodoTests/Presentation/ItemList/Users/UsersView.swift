//
//  UsersView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 03/07/2025.
//

import SwiftUI
import SwiftData

struct UsersView: View {
    @Query(sort: \User.name, order: .forward) private var users: [User]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(users) { user in
                    Text(user.name)
                }
            }
            .navigationTitle(Text("Users"))
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        AddUserView()
                    }
                    label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    UsersView()
}
