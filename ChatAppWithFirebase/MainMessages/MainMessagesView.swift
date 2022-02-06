//
//  MainMessagesView.swift
//  ChatAppWithFirebase
//
//  Created by Sivaram Yadav on 2/6/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatUser {
    let userId: String
    let email: String
    let profileImageUrl: String
}

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        self.errorMessage = "Fetching user"
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        self.errorMessage = "user id available"

        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error Fetch User: \(error.localizedDescription)"
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "User data not found"
                    debugPrint("User data not found")
                    return
                }
                
                self.errorMessage = "User Data: \(data)"
                
                let userId = data["userId"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImageUrl = data["profileImageUrl"] as? String ?? ""
                
                self.chatUser = ChatUser(
                    userId: userId,
                    email: email,
                    profileImageUrl: profileImageUrl
                )
                
                self.errorMessage = "User Data: \(String(describing: self.chatUser))"

            }
    }
}

struct MainMessagesView: View {
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    @State private var shouldShowLogoutOptions: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                //Text("User Data: \(vm.errorMessage)")
                customNavBar
                messagesView.ignoresSafeArea()
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .cornerRadius(32)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color(.label), lineWidth: 1.0)
                )
            
//            Image(systemName: "person.fill")
//                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                HStack(spacing: 4) {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button(action: {
                shouldShowLogoutOptions.toggle()
            }, label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            })
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogoutOptions, content: {
            ActionSheet(
                title   : Text("Settings"),
                message : Text("What do you want to do?"),
                buttons : [
                    ActionSheet.Button.destructive(Text("Sign Out"), action: {
                        debugPrint("Handle Sign Out.")
                    }),
                    ActionSheet.Button.cancel()
                ]
            )
        })
    }
        
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1.0)
                            )
                        VStack(alignment: .leading) {
                            Text("User Name")
                                .font(.system(size: 16, weight: .bold))
                           Text("Message to user")
                                .font(.system(size: 14))
                            .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
               }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 50)
    }
    
    private var newMessageButton: some View {
        Text("+ New Message")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color.white)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(20)
            .padding(.horizontal)
            .shadow(radius: 15)
    }

}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainMessagesView()
                .preferredColorScheme(.dark)
            
            MainMessagesView()

        }
    }
}
