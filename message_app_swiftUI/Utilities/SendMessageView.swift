//
//  SendMessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI

struct SendMessageView: View {
    @Binding var lastMessage: String
    var sendMessageAction: () -> Void
    var plusButtonAction: () -> Void
    var cameraButtonAction: () -> Void
    var micButtonAction: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: plusButtonAction) {
                    Image(systemName: "plus")
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .padding(.top)
                }
                
                TextField("", text: $lastMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                    .padding(.top)
                
                if lastMessage.isEmpty {
                    Button(action: cameraButtonAction) {
                        Image(systemName: "camera")
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                            .padding(.top)
                    }
                    
                    Button(action: micButtonAction) {
                        Image(systemName: "mic")
                            .frame(width: 30, height: 30)
                            .foregroundColor(isPressed ? .red : .black)
                            .padding(.top)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !isPressed {
                                            isPressed = true
                                            print("Mikrofona basılı tutmaya başlandı.")
                                            micButtonAction()
                                        }
                                    }
                                    .onEnded { _ in
                                        if isPressed {
                                            isPressed = false
                                            print("Mikrofondan el çekildi.")
                                            micButtonAction()
                                        }
                                    }
                            )
                    }
                } else {
                    Button(action: sendMessageAction) {
                        Text("send")
                            .frame(width: 70, height: 30)
                            .foregroundColor(.black)
                            .padding(.top)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom)
            .background(Color.grayColor)
        }
    }
}
