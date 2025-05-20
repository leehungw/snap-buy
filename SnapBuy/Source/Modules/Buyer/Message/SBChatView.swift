import SwiftUI

struct SBChatView: View {
    let user: User
    @State private var inputText: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = sampleChatMessages
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Message")
                    .font(R.font.outfitRegular.font(size: 16))
                    .padding(.trailing, 10)
                Spacer()
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
            
            HStack(spacing: 16) {
                Image(user.imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.main, lineWidth: 3))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(R.font.outfitSemiBold.font(size: 16))
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                Spacer()
                HStack(spacing: 16) {
                    Image(systemName: "video")
                    Image(systemName: "phone")
                }
                .foregroundColor(.black)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            
            Divider()
            
            // MARK: - Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .background(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .onChange(of: messages) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // MARK: - Input Bar
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    TextField("Type message...", text: $inputText)
                        .textFieldStyle(PlainTextFieldStyle())
                    Image(systemName: "paperclip")
                    Image(systemName: "mic")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray, lineWidth: 1)
                )
                Button {
                    sendMessage()
                } label: {
                    Circle()
                        .fill(Color.main)
                        .frame(width: 50, height: 50)
                        .overlay(Image(systemName: "paperplane.fill").foregroundColor(.white))
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Send Logic
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newMessage = ChatMessage(
            text: trimmed,
            time: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short),
            isUser: true
        )
        messages.append(newMessage)
        inputText = ""
    }
}
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isUser { Spacer() }
                Text(message.text)
                    .padding()
                    .background(message.isUser ? Color.main : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .black)
                    .cornerRadius(15)
                if !message.isUser { Spacer() }
            }
            Text(message.time)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}
#Preview {
    SBMessageView()
}
