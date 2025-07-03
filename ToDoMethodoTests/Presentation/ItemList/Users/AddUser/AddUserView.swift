//
//  AddUserView.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 03/07/2025.
//

import SwiftUI
import SwiftData

struct AddUserView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss: DismissAction
    @State var draftName: String = ""
    @State var draftMail: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Name")) {
                TextField("Type a name", text: $draftName)
            }
            
            Section(header: Text("Email")) {
                TextField("Type a email", text: $draftMail)
            }
        }
        .navigationTitle(Text("New User"))
        .toolbar {
            ToolbarItem {
                Button(action: saveUser) {
                    Text("Save")
                }
            }
        }
    }
    
    private func saveUser() {
        let newUser = User(id: UUID(), name: draftName.trimmingCharacters(in: .whitespacesAndNewlines), email: draftMail.trimmingCharacters(in: .whitespacesAndNewlines), createdAt: Date())
        modelContext.insert(newUser)
        dismiss()
    }
}

#Preview {
    AddUserView()
}
