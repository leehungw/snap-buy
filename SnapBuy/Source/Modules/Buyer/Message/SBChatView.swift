import SwiftUI
import Combine
import PhotosUI

struct SBChatView: View {
    let chatRoom: ChatRoom
    @State private var inputText: String = ""
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    // SignalR service
    private let signalRService = SignalRService()
    
    // Timer for polling messages
    @State private var messageTimer: Timer?
    
    // Media picker states
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploadingMedia = false
    
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
                Text(chatRoom.name)
                    .font(R.font.outfitRegular.font(size: 16))
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
            
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: chatRoom.avatar)) { image in
                    image
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.main, lineWidth: 3))
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.main, lineWidth: 3))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(chatRoom.name)
                        .font(R.font.outfitSemiBold.font(size: 16))
                    Text("Online")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                Spacer()
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
                    // Image picker button
                    PhotosPicker(selection: $selectedItem,
                               matching: .images,
                               photoLibrary: .shared()) {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    
                    // Video picker button
                    PhotosPicker(selection: $selectedItem,
                               matching: .videos,
                               photoLibrary: .shared()) {
                        Image(systemName: "video")
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Type message...", text: $inputText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                if isUploadingMedia {
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
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
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupSignalR()
            fetchMessages()
            startMessagePolling()
        }
        .onDisappear {
            stopMessagePolling()
            signalRService.connection?.stop()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .onChange(of: selectedItem) { item in
            if let item = item {
                handleMediaSelection(item)
            }
        }
    }
    
    // MARK: - Media Handling
    private func handleMediaSelection(_ item: PhotosPickerItem) {
        isUploadingMedia = true
        
        // First determine if it's an image or video
        if item.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) {
            handleImageUpload(item)
        } else if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
            handleVideoUpload(item)
        } else {
            isUploadingMedia = false
            errorMessage = "Unsupported media type"
            showError = true
        }
    }
    
    private func handleImageUpload(_ item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    ImgurService.shared.uploadImage(uiImage) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let imageUrl):
                                self.sendImageMessage(mediaLink: imageUrl)
                            case .failure(let error):
                                self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                                self.showError = true
                            }
                            self.isUploadingMedia = false
                            self.selectedItem = nil
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to process image"
                        self.showError = true
                        self.isUploadingMedia = false
                        self.selectedItem = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                    self.showError = true
                    self.isUploadingMedia = false
                    self.selectedItem = nil
                }
            }
        }
    }
    
    private func sendImageMessage(mediaLink: String) {
        guard let currentUserId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not logged in"
            showError = true
            return
        }
        
        // Create the request with the correct format
        let request = [
            "userSendId": currentUserId,
            "userReceiveId": chatRoom.userId,
            "mediaLink": mediaLink
        ]
        
        // Convert request to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: request) else {
            errorMessage = "Failed to create request"
            showError = true
            return
        }
        
        // Make the API call
        SBAPIService.shared.performRequest(
            endpoint: "chat/api/chats/sendImage",
            method: "POST",
            body: jsonData,
            headers: ["Content-Type": "application/json"]
        ) { (result: Result<SendMessageResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response.data {
                        self.messages.append(message)
                    } else if let error = response.error {
                        self.errorMessage = error.message
                        self.showError = true
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    private func handleVideoUpload(_ item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    // For now, we'll use the same ImgurService for videos
                    // In a production app, you might want to use a different service for videos
                    let request = SendVideoRequest(
                        userSendId: UserRepository.shared.currentUser?.id ?? "",
                        userReceiveId: chatRoom.userId,
                        videoData: data
                    )
                    
                    ChatRepository.shared.sendVideo(request: request) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                if let message = response.data {
                                    self.messages.append(message)
                                } else if let error = response.error {
                                    self.errorMessage = error.message
                                    self.showError = true
                                }
                            case .failure(let error):
                                self.errorMessage = "Failed to upload video: \(error.localizedDescription)"
                                self.showError = true
                            }
                            self.isUploadingMedia = false
                            self.selectedItem = nil
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to process video"
                        self.showError = true
                        self.isUploadingMedia = false
                        self.selectedItem = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load video: \(error.localizedDescription)"
                    self.showError = true
                    self.isUploadingMedia = false
                    self.selectedItem = nil
                }
            }
        }
    }
    
    // MARK: - Chat Logic
    private func startMessagePolling() {
        // Poll for new messages every 5 seconds
        messageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            fetchMessages()
        }
    }
    
    private func stopMessagePolling() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    private func fetchMessages() {
        isLoading = messages.isEmpty
        
        ChatRepository.shared.fetchChatMessages(chatRoomId: chatRoom.chatRoomId) { result in
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
    }
    
    // MARK: - SignalR Setup
    private func setupSignalR() {
        signalRService.startSignalR()
        
        signalRService.connection?.on(method: "NewMessage", callback: { (user: String, message: String) in
            DispatchQueue.main.async {
                if user != UserRepository.shared.currentUser?.id {
                    let newMessage = ChatMessage(
                        id: Int.random(in: 1...Int.max),
                        userSendId: user,
                        avatar: nil,
                        message: message,
                        mediaLink: nil,
                        sendDate: Date(),
                        type: .text
                    )
                    self.messages.append(newMessage)
                }
            }
        })
    }

    // Update sendMessage function
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard let currentUserId = UserRepository.shared.currentUser?.id else {
            errorMessage = "User not logged in"
            showError = true
            return
        }
        
        // Gửi tin nhắn qua SignalR
        signalRService.connection?.invoke(method: "SendMessage", currentUserId, trimmed) { error in
            if let error = error {
                print("Error sending message via SignalR: \(error)")
            }
        }
        
        // Gửi tin nhắn qua REST API
        let request = SendTextRequest(
            userSendId: currentUserId,
            userReceiveId: chatRoom.userId,
            message: trimmed
        )
        
        ChatRepository.shared.sendText(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let message = response.data {
                        self.messages.append(message)
                        self.inputText = ""
                    } else if let error = response.error {
                        self.errorMessage = error.message
                        self.showError = true
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
}

// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: ChatMessage
    @State private var isImageExpanded = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                MessageAvatar(avatarURL: message.avatar)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.isUser { Spacer() }
                    
                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                        switch message.type {
                        case .text:
                            if let textMessage = message.message {
                                Text(textMessage)
                                    .foregroundColor(message.isUser ? .white : .black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(message.isUser ? Color.main : Color(.systemGray6))
                                    .clipShape(BubbleShape(isUser: message.isUser))
                            }
                        
                        case .image:
                            if let mediaUrl = message.mediaLink {  // Use mediaLink for images
                                AsyncImage(url: URL(string: mediaUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 200, height: 200)
                                            .background(Color.gray.opacity(0.1))
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: isImageExpanded ? .infinity : 200,
                                                   maxHeight: isImageExpanded ? .infinity : 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(radius: 3)
                                            .onTapGesture {
                                                withAnimation {
                                                    isImageExpanded.toggle()
                                                }
                                            }
                                    case .failure(_):
                                        VStack {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.gray)
                                            Text("Image not available")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(width: 200, height: 200)
                                        .background(Color.gray.opacity(0.1))
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .background(message.isUser ? Color.main.opacity(0.1) : Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        
                        case .video:
                            if let mediaUrl = message.mediaLink {
                                VideoThumbnail(url: mediaUrl)
                            }
                        }
                        
                        if !isImageExpanded {
                            Text(formatDate(message.sendDate))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: isImageExpanded ? .infinity : nil)
                    
                    if !message.isUser { Spacer() }
                }
            }
            
            if message.isUser {
                MessageAvatar(avatarURL: message.avatar)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday " + DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Message Avatar Component
struct MessageAvatar: View {
    let avatarURL: String?
    
    var body: some View {
        if let urlString = avatarURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Video Thumbnail Component
struct VideoThumbnail: View {
    let url: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .frame(width: 200, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
        }
        .onTapGesture {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Chat Bubble Shape
struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius: CGFloat = 20
        let tailSize: CGFloat = 10
        
        var path = Path()
        
        if isUser {
            // Top left corner
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: 180),
                       endAngle: Angle(degrees: 270),
                       clockwise: false)
            
            // Top edge and top right corner
            path.addLine(to: CGPoint(x: width - radius, y: rect.minY))
            path.addArc(center: CGPoint(x: width - radius, y: rect.minY + radius),
                       radius: radius,
                       startAngle: Angle(degrees: 270),
                       endAngle: Angle(degrees: 0),
                       clockwise: false)
            
            // Right edge and tail
            path.addLine(to: CGPoint(x: width, y: height - radius - tailSize))
            path.addCurve(to: CGPoint(x: width - tailSize, y: height),
                         control1: CGPoint(x: width, y: height - tailSize),
                         control2: CGPoint(x: width - tailSize, y: height))
            
            // Bottom edge
            path.addLine(to: CGPoint(x: radius, y: height))
            
            // Bottom left corner
            path.addArc(center: CGPoint(x: radius, y: height - radius),
                       radius: radius,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 180),
                       clockwise: false)
        } else {
            // Top right corner
            path.move(to: CGPoint(x: width, y: radius))
            path.addArc(center: CGPoint(x: width - radius, y: radius),
                       radius: radius,
                       startAngle: Angle(degrees: 0),
                       endAngle: Angle(degrees: 270),
                       clockwise: true)
            
            // Top edge and top left corner
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(center: CGPoint(x: radius, y: radius),
                       radius: radius,
                       startAngle: Angle(degrees: 270),
                       endAngle: Angle(degrees: 180),
                       clockwise: true)
            
            // Left edge and tail
            path.addLine(to: CGPoint(x: 0, y: height - radius - tailSize))
            path.addCurve(to: CGPoint(x: tailSize, y: height),
                         control1: CGPoint(x: 0, y: height - tailSize),
                         control2: CGPoint(x: tailSize, y: height))
            
            // Bottom edge
            path.addLine(to: CGPoint(x: width - radius, y: height))
            
            // Bottom right corner
            path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                       radius: radius,
                       startAngle: Angle(degrees: 90),
                       endAngle: Angle(degrees: 0),
                       clockwise: true)
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    SBMessageView()
}

