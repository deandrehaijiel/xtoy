//
//  LandingView.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 5/9/23.
//

import SwiftUI

struct LandingView: View {
    var body: some View {
        NavigationStack{
            VStack{
                Lottie(lottieFile: "LandingLottie").frame(width: 300, height: 300)
                
                Text("X to Y")
                    .font(.largeTitle)
                    .fontWeight(.black)
                
                Text("A messaging app designed exclusively\nfor you (X) and your significant other (Y).")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10.0)
                
                NavigationLink(destination: ChatView()) {
                    HStack{
                        Text("Start Chatting")
                            .font(.headline)
                        
                        Image(systemName: "ellipsis.message")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .foregroundColor(.black)
                    .background(Color(red: 255/255, green: 191/255, blue: 11/255))
                    .cornerRadius(15)
                    .padding(.top, 30)
                }
            }
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
