//
//  AccountView.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 5/9/23.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct AccountView: View {
    let completedLogin: () -> ()
    
    @State private var isLoginMode = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var rePassword = ""
    @State private var loginStatusMessage = ""
    @State private var errorBottomSheet = false
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var pair = ""
    
    private func handleAction() {
        if isLoginMode {
            userLogin()
        } else {
            if !isValidEmail(email) {
                loginStatusMessage = "Invalid email address"
                errorBottomSheet = true
            } else if email.isEmpty {
                loginStatusMessage = "Email cannot be empty"
                errorBottomSheet = true
            } else if password.isEmpty || rePassword.isEmpty {
                loginStatusMessage = "Passwords cannot be empty"
                errorBottomSheet = true
            } else if password.count <= 6  || rePassword.count <= 6  {
                loginStatusMessage = "Passwords cannot be less than 6 characters"
                errorBottomSheet = true
            } else if password != rePassword {
                loginStatusMessage = "Passwords do not match"
                errorBottomSheet = true
                return
            } else {
                createNewAccount()
            }
        }
    }
    
    private func userLogin() {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, err in
            if err != nil {
                loginStatusMessage = "Login failed. Please try again."
                errorBottomSheet = true
                return
            }
            completedLogin()
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func createNewAccount() {
        if image == nil {
            loginStatusMessage = "Profile picture cannot be empty"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {
            result, err in
            if err != nil {
                loginStatusMessage = "Failed to create account"
                errorBottomSheet = true
                return
            }
            persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) {
            metadata, err in
            if err != nil {
                loginStatusMessage = "Failed to upload image to Storage"
                return
            }
            
            ref.downloadURL { url, err in
                if err != nil {
                    loginStatusMessage = "Failed to retrieve image URL"
                    return
                }
                
                guard let url = url else { return }
                storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["xId": uid, "xName": name, "xEmail": email, "xProfileImageUrl": imageProfileUrl.absoluteString, "pair": pair]
        Firestore.firestore().collection("users")
            .document(uid).setData(userData) { err in
                if err != nil {
                    loginStatusMessage = "Failed to store user data"
                    return
                }
                completedLogin()
            }
    }
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    if !isLoginMode{
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            VStack{
                                if let image = image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(red: 255/255, green: 191/255, blue: 11/255), lineWidth: 5.0))
                        }
                    }
                    
                    if !isLoginMode{
                        TextField("Enter Name", text: $name)
                            .padding(.all)
                            .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                            .overlay(RoundedRectangle(cornerRadius: 10.0)
                                .strokeBorder(Color(red: 255/255, green: 191/255, blue: 11/255), style: StrokeStyle(lineWidth: 5.0)))
                            .padding()
                            .textInputAutocapitalization(.none)
                            .keyboardType(.namePhonePad)
                    }
                    
                    TextField("Enter Email", text: $email)
                        .padding(.all)
                        .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                        .overlay(RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(Color(red: 255/255, green: 191/255, blue: 11/255), style: StrokeStyle(lineWidth: 5.0)))
                        .padding()
                        .textInputAutocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Enter Password", text: $password)
                        .padding(.all)
                        .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                        .overlay(RoundedRectangle(cornerRadius: 10.0)
                            .strokeBorder(Color(red: 255/255, green: 191/255, blue: 11/255), style: StrokeStyle(lineWidth: 5.0)))
                        .padding()
                        .textInputAutocapitalization(.none)
                    
                    if !isLoginMode{
                        SecureField("Re-Enter Password", text: $rePassword)
                            .padding(.all)
                            .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                            .overlay(RoundedRectangle(cornerRadius: 10.0)
                                .strokeBorder(Color(red: 255/255, green: 191/255, blue: 11/255), style: StrokeStyle(lineWidth: 5.0)))
                            .padding()
                            .textInputAutocapitalization(.none)
                    }
                    
                    Text(isLoginMode ? "Don't Have an Account?" : "Already Have an Account?")
                        .font(.footnote)
                    
                    Button{
                        isLoginMode.toggle()
                        name = ""
                        email = ""
                        password = ""
                        rePassword = ""
                    } label: {
                        Text(isLoginMode ? "Sign Up Now" : "Login Here").font(.footnote).underline().foregroundColor(.black)
                    }
                    
                    Button{
                        handleAction()
                    } label: {
                        HStack{
                            Text(isLoginMode ? "Login" : "Create Account")
                                .font(.headline)
                            
                            Image(systemName: isLoginMode ? "arrowshape.zigzag.forward" : "person.fill.badge.plus")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color(red: 255/255, green: 191/255, blue: 11/255))
                        .cornerRadius(15)
                    }
                    .padding(.top, 10.0)
                    
                    if !loginStatusMessage.isEmpty{
                        
                    }
                }
                .sheet(isPresented: $errorBottomSheet) {
                    HStack{
                        Text(loginStatusMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding(.all)
                    .presentationDetents([.height(50)])
                }
            }
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
        .navigationBarHidden(true)
        .onAppear() {
            name = ""
            email = ""
            password = ""
            rePassword = ""
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(completedLogin: {
            
        })
    }
}
