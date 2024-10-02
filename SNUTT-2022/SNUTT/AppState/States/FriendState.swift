import Foundation

@MainActor
class FriendState {
    @Published var pendingFriendRequestToken: String?
}
