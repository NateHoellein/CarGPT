//
//  ChatView.swift
//  CarGPT
//
//  Created by nate on 10/27/24.
//

import SwiftUI

struct ChatView: View {
    
    var client = GPTClient(model: .gpt4Turbo,
                           context: .makeContext(
                            "Your name is Ray and you are a car mechanic and classic car restorer.",
                            "Greet people the first time with your name",
                            "You can only answer questions on how to repair automobiles and how to restore them from piles of rust",
                            "Only answer questions about cars or old cars, not motorcycles, boats, or planes.  Response with the senders name if you don't know the answer.  I'm here to help you with your classic cars.",
                            "If they ask 3 times about anything else, tell them to \"Shove off\""
                           ))
    
    @State var messages: [GPTMessage] = [
        GPTMessage(role: .assistant, content: "Hello there! Ask me anything about 🚗 🚙")
    ]
    
    @State var inputText: String = ""
    @State var isLoading = false
    @State var textEditorHeight: CGFloat = 36
    
    var body: some View {
        NavigationView {
            VStack {
                messagesScrollView
                inputMessageView
            }
        }
    }
    
    var messagesScrollView: some View {
        ScrollViewReader { scrollView in
            VStack {
                ScrollView {
                    VStack {
                        ForEach(messages, id: \.self) { message in
                            if message.role == .user {
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }.id("ChatScrollView")
                    .padding()
                }
                .onChange(of: messages) { _,_ in
                    withAnimation {
                        scrollView.scrollTo("ChatScrollView", anchor: .center)
                    }
                }
            }
        }
    }
    
    var inputMessageView: some View {
        HStack {
            TextField("Type here...", text: $inputText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            Button(action: sendMessage) {
                Text("Submit")
            }
            .padding()
            .disabled(inputText.isEmpty || isLoading)
            .keyboardShortcut(.defaultAction)
        }
    }
    
    private func sendMessage() {
        isLoading = true
        Task {
            let message = GPTMessage(role: .user, content: inputText)
            messages.append(message)
            inputText.removeAll()
            do {
                let response = try await client.sendChats(messages)
                isLoading = false
                
                guard let reply = response.choices.first?.message else {
                    print(
                        "NO choices.message in response: \(response)"
                    )
                    return }
                messages.append(reply)
            } catch {
                isLoading = false
                print("Error sending message: \(error)")
            }
        }
    }
}
