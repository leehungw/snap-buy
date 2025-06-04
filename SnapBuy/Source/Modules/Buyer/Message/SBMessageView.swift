import SwiftUI
import Combine

// MARK: - Header Component
struct MessageHeaderView: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text(R.string.localizable.message)
                .font(R.font.outfitRegular.font(size: 16))
                .padding(.trailing,10)
            Spacer()
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Search Component
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search messages...", text: $searchText)
                .foregroundColor(.black)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
    }
}

// MARK: - Chat Avatar Component
struct ChatAvatarView: View {
    let avatarUrl: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: avatarUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Color.gray.opacity(0.3)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .background(Circle().stroke(Color.main, lineWidth: 5))
    }
}

// MARK: - Recent Activity Item Component
struct RecentActivityItemView: View {
    let room: ChatRoom
    
    var body: some View {
        NavigationLink(destination: SBChatView(chatRoom: room)) {
            VStack(alignment: .center, spacing: 10) {
                ChatAvatarView(avatarUrl: room.avatar, size: 70)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                Text(room.name)
                    .font(R.font.outfitSemiBold.font(size: 16))
            }
        }
    }
}

// MARK: - Recent Activities Component
struct RecentActivityView: View {
    let chatRooms: [ChatRoom]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(R.string.localizable.activities)
                .font(R.font.outfitBold.font(size: 20))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(chatRooms.prefix(5)) { room in
                        RecentActivityItemView(room: room)
                    }
                }
            }
        }
    }
}

// MARK: - Chat Room Row Component
struct ChatRoomRowView: View {
    let room: ChatRoom
    
    private var lastMessageDisplay: String {
        if let lastMessage = room.lastMessage {
            if lastMessage.contains("https://") && lastMessage.contains(".jpg") {
                return "[Image]"
            } else if lastMessage.contains("https://") && lastMessage.contains(".mp3") {
                return "[Video]"
            } else {
                return lastMessage
            }
        }
        return ""
    }
    
    private var timeAgoText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(room.lastMessageTime) {
            // If today, show time
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: room.lastMessageTime)
        } else if calendar.isDateInYesterday(room.lastMessageTime) {
            // If yesterday, show "Yesterday"
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: room.lastMessageTime, to: now).day, daysAgo < 7 {
            // If within a week, show day name
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            return dayFormatter.string(from: room.lastMessageTime)
        } else {
            // Otherwise show relative time
            return formatter.localizedString(for: room.lastMessageTime, relativeTo: now)
        }
    }
    
    var body: some View {
        NavigationLink(destination: SBChatView(chatRoom: room)) {
            HStack(alignment: .top) {
                ChatAvatarView(avatarUrl: room.avatar, size: 70)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .lineLimit(1)
                    
                        Text(lastMessageDisplay)
                            .font(R.font.outfitRegular.font(size: 13))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timeAgoText)
                        .font(R.font.outfitRegular.font(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
            }
            .contentShape(Rectangle())
        }
    }
}

// MARK: - Chat List Component
struct ChatListView: View {
    let chatRooms: [ChatRoom]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(R.string.localizable.messages)
                .font(R.font.outfitBold.font(size: 20))
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(chatRooms) { room in
                        ChatRoomRowView(room: room)
                    }
                }
            }
        }
    }
}

// MARK: - Loading View Component
struct LoadingView: View {
    var body: some View {
        Spacer()
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity)
        Spacer()
    }
}

// MARK: - Error View Component
struct ErrorView: View {
    let message: String
    
    var body: some View {
        Spacer()
        Text(message)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
        Spacer()
    }
}

// MARK: - Main View
struct SBMessageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var chatRooms: [ChatRoom] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    
    private var currentUserId: String {
        UserRepository.shared.currentUser?.id ?? ""
    }
    
    private var filteredChatRooms: [ChatRoom] {
        if searchText.isEmpty {
            return chatRooms
        }
        return chatRooms.filter { room in
            room.name.localizedCaseInsensitiveContains(searchText) ||
            (room.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        SBBaseView {
            VStack(spacing: 30) {
                MessageHeaderView(dismiss: dismiss)
                SearchBarView(searchText: $searchText)
                
                Group {
                    if isLoading {
                        LoadingView()
                    } else if let error = errorMessage {
                        ErrorView(message: error)
                    } else if filteredChatRooms.isEmpty {
                        if searchText.isEmpty {
                            ErrorView(message: "No messages found")
                        } else {
                            ErrorView(message: "No results found for '\(searchText)'")
                        }
                    } else {
                        RecentActivityView(chatRooms: filteredChatRooms)
                        ChatListView(chatRooms: filteredChatRooms)
                    }
                }
            }
            .padding(.horizontal, 30)
            .foregroundColor(.black)
        }
        .onAppear {
            setupChatUpdates()
        }
        .onDisappear {
//            ChatRepository.shared.stopRealtimeUpdates()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func setupChatUpdates() {
        guard !currentUserId.isEmpty else {
            errorMessage = "Please log in to view messages"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        ChatRepository.shared.fetchChatRooms(userId: currentUserId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    if let rooms = response.data {
                        chatRooms = rooms
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

#Preview {
    SBMessageView()
}
