//
//  LoginView.swift
//  ChatAppWithFirebase
//
//  Created by Sivaram Yadav on 2/5/22.
//

import SwiftUI

struct LoginView: View {
    
    let didCompletedSignInProcess: (() -> Void)
    
    @State private var isLogInMode  : Bool    = false
    @State private var email        : String  = ""
    @State private var password     : String  = ""
    
    @State private var loginStatusMessage: String  = ""
    @State private var shouldShowImagePicker: Bool  = false
    @State private var image: UIImage?

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Picker(selection: $isLogInMode, label: Text("Picker"), content: {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLogInMode {
                        Button(action: {
                            shouldShowImagePicker.toggle()
                        }, label: {
                            
                            VStack {
                                if let img = image {
                                    Image(uiImage: img)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                               }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 64)
                                    .strokeBorder(Color.black, lineWidth: 3)
                            )
                        })
                    }
            
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)

                    Button(action: {
                        handleAction()
                    }, label: {
                        Text(isLogInMode ? "Log In" : "Create Account")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.cornerRadius(5))
                        
                    })
                    .padding(.vertical)
                    
                    Text(loginStatusMessage)
                        .foregroundColor(.red)
                    
                }
                .padding()
            }
            .navigationTitle(isLogInMode ? "Log In" : "Create Account")
            .background(
                Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea()
            )

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
        }
        
    }
    
    private func handleAction() {
        
        if isLogInMode {
            debugPrint("Log In")
            loginUser()
        } else {
            debugPrint("Registration")
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
                self.loginStatusMessage = "Error: \(error.localizedDescription)"
                return
            }
            debugPrint("Success: ", result?.user.uid ?? "")
            self.loginStatusMessage = "Success: \(result?.user.uid ?? "")"
            self.didCompletedSignInProcess()
        }
    }
        
    private func createNewAccount() {
        
        if self.image == nil  {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
                self.loginStatusMessage = "Error: \(error.localizedDescription)"
                return
            }
            debugPrint("Success: ", result?.user.uid ?? "")
            self.loginStatusMessage = "Success: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        //let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        guard let imgData = image?.jpegData(compressionQuality: 0.5) else {
            return
        }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        
        ref.putData(imgData, metadata: nil) { (metaData, error) in
            
            if let err = error {
                self.loginStatusMessage = "Failed image to store: \(err.localizedDescription)"
                return
            }
            
            ref.downloadURL { (url, error) in
                if let err = error {
                    self.loginStatusMessage = "Failed to retrive url: \(err.localizedDescription)"
                    return
                }
                
                self.loginStatusMessage = "Success image store: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.storeUserInformation(profileImageUrl: url)
            }
            
        }
    }
    
    private func storeUserInformation(profileImageUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }

        let userData =
            [
                "email"             : self.email,
                "userId"            : uid,
                "profileImageUrl"   : profileImageUrl.absoluteString
            ]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let err = error {
                    self.loginStatusMessage = "Failed at DB: \(err.localizedDescription)"
                    return
                }
                
                self.loginStatusMessage = "Success at DB"
                self.didCompletedSignInProcess()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompletedSignInProcess: {
            
        })
    }
}
