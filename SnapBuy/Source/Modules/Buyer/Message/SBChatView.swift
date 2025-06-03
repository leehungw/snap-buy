import SwiftUI
import Combine

struct SBChatView: View {
    let user: User
    @State private var inputText: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
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
                    if isLoading && messages.isEmpty {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
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
        .onAppear {
            setupMessageUpdates()
        }
        .onDisappear {
            ChatRepository.shared.stopRealtimeUpdates()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Chat Logic
    private func setupMessageUpdates() {
        isLoading = true
        
        // Initial fetch
        ChatRepository.shared.fetchChatMessages(chatRoomId: user.id.uuidString) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if let newMessages = response.data {
                        messages = newMessages
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
        
        // Start real-time updates with SignalR
        guard let currentUserId = UserRepository.shared.currentUser?.id else { return }
        ChatRepository.shared.startRealtimeUpdates(selectedChatId: user.id.uuidString, userId: currentUserId)
    }
    
    private func fetchLatestMessages() {
        ChatRepository.shared.fetchChatMessages(chatRoomId: user.id.uuidString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let newMessages = response.data {
                        messages = newMessages
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    // MARK: - Send Logic
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard let currentUserId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not logged in"
            showError = true
            return
        }
        
        let request = SendTextRequest(
            userSendId: currentUserId,
            userReceiveId: user.id.uuidString,
            message: trimmed
        )
        
        ChatRepository.shared.sendText(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response.data {
                        messages.append(message)
                        inputText = ""
                    } else if let error = response.error {
                        errorMessage = error.message
                        showError = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func sendImage(_ imageData: Data) {
        guard let currentUserId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not logged in"
            showError = true
            return
        }
        
        let request = SendImageRequest(
            userSendId: currentUserId,
            userReceiveId: user.id.uuidString,
            imageData: imageData
        )
        
        ChatRepository.shared.sendImage(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response.data {
                        messages.append(message)
                    } else if let error = response.error {
                        errorMessage = error.message
                        showError = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func sendVideo(_ videoData: Data) {
        guard let currentUserId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not logged in"
            showError = true
            return
        }
        
        let request = SendVideoRequest(
            userSendId: currentUserId,
            userReceiveId: user.id.uuidString,
            videoData: videoData
        )
        
        ChatRepository.shared.sendVideo(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response.data {
                        messages.append(message)
                    } else if let error = response.error {
                        errorMessage = error.message
                        showError = true
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                AsyncImage(url: URL(string: message.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.isUser { Spacer() }
                    
                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                        switch message.type {
                        case .text:
                            Text(message.message)
                                .padding()
                                .background(message.isUser ? Color.main : Color(.systemGray5))
                                .foregroundColor(message.isUser ? .white : .black)
                                .cornerRadius(15)
                            
                        case .image:
                            if let mediaUrl = message.mediaLink, let url = URL(string: mediaUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(maxWidth: 200, maxHeight: 200)
                                .cornerRadius(15)
                            }
                            
                        case .video:
                            if let mediaUrl = message.mediaLink {
                                VideoPlayer(url: mediaUrl)
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .cornerRadius(15)
                            }
                        }
                        
                        Text(message.timeString)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    if !message.isUser { Spacer() }
                }
            }
            
            if message.isUser {
                AsyncImage(url: URL(string: message.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
}

struct VideoPlayer: View {
    let url: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
            Image(systemName: "play.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
        .onTapGesture {
            // Handle video playback
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    SBMessageView()
}
