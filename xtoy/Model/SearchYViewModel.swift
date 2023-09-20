//
//  SearchYView.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 14/9/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

class SearchYViewModel: ObservableObject {
    @ObservedObject private var cvm = ChatViewModel()
    @Published var y: ChatUser?
    @Published var errorMessage = ""
    @Published var errorBottomSheet = false
    
    func searchYEmail(email: String) {
        Firestore.firestore().collection("users")
            .whereField("xEmail", isEqualTo: email)
            .getDocuments { snapshot, err in
                if err != nil {
                    self.errorMessage = "Error"
                    self.y = nil
                    self.errorBottomSheet = true
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.errorMessage = "User not found"
                    self.y = nil
                    self.errorBottomSheet = true
                    return
                }
                
                if let document = documents.first?.data() {
                    self.y = ChatUser(data: document)
                }
            }
    }
    
    func pairWithY() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let queriedUser = y else {
            return
        }
        
        let batch = Firestore.firestore().batch()
        
        let xRef = Firestore.firestore().collection("users").document(currentUserUID)
        batch.updateData([
            "pair": "1",
            "yId": queriedUser.xId,
            "yName": queriedUser.xName,
            "yEmail": queriedUser.xEmail,
            "yProfileImageUrl": queriedUser.xProfileImageUrl
        ], forDocument: xRef)
        
        let yRef = Firestore.firestore().collection("users").document(queriedUser.xId)
        batch.updateData([
            "pair": "1",
            "yId": cvm.chatUser?.xId ?? "",
            "yName": cvm.chatUser?.xName ?? "",
            "yEmail": cvm.chatUser?.xEmail ?? "",
            "yProfileImageUrl": cvm.chatUser?.xProfileImageUrl ?? ""
        ], forDocument: yRef)
        
        batch.commit { error in
            
        }
    }
}
