//
//  ChatView.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 14/9/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var chatUser: ChatUser?
    @Published var chatMessages = [ChatMessage]()
    @Published var chatText = ""
    @Published var count = 0
    @Published var errorMessage = ""
    @Published var errorBottomSheet = false
    @Published var isUserCurrentlyLoggedOut = false
    private var hasFetchedMessages = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Could not find Firebase User ID"
            return
        }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, err in
            if err != nil {
                self.errorMessage = "Failed to fetch current user"
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            self.chatUser = .init(data: data)
            
            if !self.hasFetchedMessages && self.chatUser?.pair != "" {
                self.fetchMessages()
                self.hasFetchedMessages = true
            }
        }
    }
    
    private func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        guard let toId = chatUser?.yId else { return }
        
        Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, err in
                if err != nil {
                    self.errorMessage = "Failed to load messages"
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func send() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        
        guard let toId = chatUser?.yId else { return }
        
        let xDocument = Firestore.firestore()
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId": fromId, "toId": toId, "message": chatText, "timestamp": Timestamp()] as [String : Any]
        
        xDocument.setData(messageData) { err in
            if err != nil {
                self.errorMessage = "Failed to send message"
            }
            
            self.count += 1
        }
        
        let yDocument = Firestore.firestore()
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        yDocument.setData(messageData) { err in
            if err != nil {
                self.errorMessage = "Failed to receive message"
            }
        }
        
        self.chatText = ""
    }
    
    func signOut() {
        isUserCurrentlyLoggedOut = true
        try? Auth.auth().signOut()
    }
}
