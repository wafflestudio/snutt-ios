import APIClientInterface
import Foundation

public struct User: Sendable, Codable, Hashable {
    public let id: String
    /// Can be `nil` if the user is very old.
    public let localID: String?
    public let email: String?
    public let nickname: Nickname
    public let notificationCheckedAt: Date
    public let registeredAt: Date

    public init(
        id: String,
        localID: String?,
        email: String?,
        nickname: Nickname,
        notificationCheckedAt: Date,
        registeredAt: Date
    ) {
        self.id = id
        self.localID = localID
        self.email = email
        self.nickname = nickname
        self.notificationCheckedAt = notificationCheckedAt
        self.registeredAt = registeredAt
    }

    public init(dto: Components.Schemas.UserDto) {
        self.init(
            id: dto.id,
            localID: dto.localId,
            email: dto.email,
            nickname: .init(nickname: dto.nickname.nickname, tag: dto.nickname.tag),
            notificationCheckedAt: dto.notificationCheckedAt,
            registeredAt: dto.regDate
        )
    }

}

public struct Nickname: Sendable, Codable, Hashable, CustomStringConvertible {
    public let nickname: String
    public let tag: String

    public init(nickname: String, tag: String) {
        self.nickname = nickname
        self.tag = tag
    }

    public var description: String {
        "\(nickname)#\(tag)"
    }
}
