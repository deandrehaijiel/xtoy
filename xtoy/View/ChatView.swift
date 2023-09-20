//
//  ChatView.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 5/9/23.
//

import SwiftUI
import Firebase

struct ChatView: View {
    @ObservedObject private var cvm = ChatViewModel()
    @ObservedObject private var syvm = SearchYViewModel()
    @State private var logOutOptions = false
    @State private var searchY = ""
    @State private var toChat = false
    
    var body: some View {
        NavigationStack{
            if (cvm.chatUser?.pair == "" && toChat == false)  {
                VStack{
                    HStack(alignment: .center, spacing: 12) {
                        AsyncImage(url: URL(string: cvm.chatUser?.xProfileImageUrl ?? "")) {
                            returnedImage in
                            returnedImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                    .stroke(Color(red: 255/255, green: 191/255, blue: 11/255), lineWidth: 2.0)
                                )
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            let name = cvm.chatUser?.xName ?? ""
                            Text(name)
                                .font(.system(size: 24, weight: .heavy))
                            HStack {
                                Circle()
                                    .foregroundColor(.green)
                                    .frame(width: 14, height: 14)
                                Text("online")
                                    .font(.system(size: 12, weight: .heavy))
                                    .foregroundColor(Color(.gray))
                            }
                        }
                        Spacer()
                        Button {
                            logOutOptions.toggle()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(.label))
                        }
                    }
                    HStack{
                        Text("Search for Y")
                            .font(.largeTitle)
                            .fontWeight(.black)
                        Spacer()
                    }
                    TextField("Enter Y's Email", text: $searchY, onCommit: {
                        syvm.searchYEmail(email: searchY)
                    })
                    .padding(.all)
                    .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                    .overlay(RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(Color(red: 255/255, green: 191/255, blue: 11/255), style: StrokeStyle(lineWidth: 5.0)))
                    .textInputAutocapitalization(.none)
                    .keyboardType(.namePhonePad)
                    
                    if let yUser = syvm.y {
                        VStack(alignment: .center,spacing: 12) {
                            AsyncImage(url: URL(string: yUser.xProfileImageUrl)) {
                                returnedImage in
                                returnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .clipped()
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(red: 255/255, green: 191/255, blue: 11/255), lineWidth: 5.0))
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 128, height: 128)
                            }
                            .padding(.top, 30.0)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                let name = yUser.xName
                                Text(name)
                                let email = yUser.xEmail
                                Text(email)
                            }
                            .padding(.top, 20.0)
                            .font(.system(size: 24, weight: .heavy))
                        }
                    }
                    
                    Spacer()
                        .actionSheet(isPresented: $logOutOptions) {
                            .init(title: Text("Log Out"), message: Text("Are you sure you want to logout?"), buttons: [
                                .destructive(Text("Log Out"), action: {
                                    cvm.signOut()
                                    searchY = ""
                                    cvm.chatUser = nil
                                    syvm.y = nil
                                }),
                                .cancel()
                            ])
                        }
                }
                .overlay(
                    Button {
                        if syvm.y != nil {
                            syvm.pairWithY()
                            toChat = true
                            cvm.fetchCurrentUser()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Pair with Y")
                                .font(.headline)
                            Image(systemName: "plus.message.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .background(Color(red: 255/255, green: 191/255, blue: 11/255))
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .shadow(radius: 15)
                    }
                    ,alignment: .bottom)
                .padding(.horizontal)
                .navigationBarHidden(true)
                .sheet(isPresented: $syvm.errorBottomSheet) {
                    HStack{
                        Text(syvm.errorMessage)
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
            
            else if (cvm.chatUser?.pair == "1" || toChat == true) {
                VStack{
                    HStack(alignment: .center, spacing: 12) {
                        if let yProfileImageURLString = cvm.chatUser?.yProfileImageUrl, let yProfileImageURL = URL(string: yProfileImageURLString) {
                            AsyncImage(url: yProfileImageURL) { returnedImage in
                                returnedImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(50)
                                    .overlay(RoundedRectangle(cornerRadius: 64)
                                        .stroke(Color(red: 255/255, green: 191/255, blue: 11/255), lineWidth: 2.0)
                                    )
                                    .shadow(radius: 5)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            }
                        } 
                        VStack(alignment: .leading, spacing: 6) {
                            if let yName = cvm.chatUser?.yName {
                                Text(yName)
                                    .font(.system(size: 24, weight: .heavy))
                            }
                        }
                        Spacer()
                        Button {
                            logOutOptions.toggle()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(.label))
                        }
                        .actionSheet(isPresented: $logOutOptions) {
                            .init(title: Text("Log Out"), message: Text("Are you sure you want to logout?"), buttons: [
                                .destructive(Text("Log Out"), action: {
                                    cvm.signOut()
                                    searchY = ""
                                    cvm.chatUser = nil
                                    syvm.y = nil
                                }),
                                .cancel()
                            ])
                        }
                    }
                    .padding(.horizontal)
                    
                    if(cvm.isUserCurrentlyLoggedOut == false) {
                        ScrollView{
                            ScrollViewReader { scrollViewProxy in
                                VStack{
                                    ForEach(cvm.chatMessages) { message in
                                        VStack {
                                            if(message.fromId == Auth.auth().currentUser?.uid) {
                                                HStack {
                                                    Spacer()
                                                    HStack {
                                                        Text(message.message)
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding()
                                                    .background(Color(red: 255/255, green: 191/255, blue: 11/255))
                                                    .cornerRadius(8)
                                                }
                                            } else {
                                                HStack {
                                                    HStack {
                                                        Text(message.message)
                                                            .foregroundColor(.black)
                                                    }
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(8)
                                                    Spacer()
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                    }
                                    HStack{ Spacer() }
                                        .id("Empty")
                                }
                                .onReceive(cvm.$count) { _ in
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .background(Color(.init(white: 0.95, alpha: 1)))
                    } else {
                        Spacer()
                    }
                    HStack(spacing: 16) {
                        ZStack(alignment: .leading) {
                            Text("Message")
                                .foregroundColor(Color(.gray))
                                .font(.system(size: 17))
                                .padding(.leading, 5)
                                .padding(.top, -4)
                            Spacer()
                            TextEditor(text: $cvm.chatText)
                                .opacity(cvm.chatText.isEmpty ? 0.5 : 1)
                                .accentColor(Color(red: 255/255, green: 191/255, blue: 11/255))
                        }
                        .frame(height: 40)
                        Button {
                            cvm.send()
                        } label: {
                            Image(systemName: "paperplane")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(.label))
                        }
                    }
                    .background(Color.white.ignoresSafeArea())
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .onAppear() {
                    cvm.chatText = ""
                }
                .sheet(isPresented: $cvm.errorBottomSheet) {
                    HStack{
                        Text(cvm.errorMessage)
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
            
            else {
                Spacer()
            }
            
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $cvm.isUserCurrentlyLoggedOut) {
            AccountView(completedLogin: {
                cvm.isUserCurrentlyLoggedOut = false
                cvm.fetchCurrentUser()
            })
        }
        .onAppear() {
            searchY = ""
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
