//
//  WebSocket+Response.swift
//  GetStreamChat
//
//  Created by Alexey Bukhtin on 23/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

extension WebSocket {
    enum Connection: Equatable {
        case notConnected
        case connecting
        case connected(_ connectionId: String, User)
        case disconnected(Error)
        
        var isConnected: Bool {
            if case .connected(let connectionId, _) = self {
                return !connectionId.isEmpty
            }
            
            return false
        }
        
        static func == (lhs: Connection, rhs: Connection) -> Bool {
            switch (lhs, rhs) {
            case (.notConnected, .notConnected),
                 (.connecting, .connecting),
                 (.disconnected, .disconnected):
                return true
            case let (.connected(connectionId1, user1), .connected(connectionId2, user2)):
                return connectionId1 == connectionId2 && user1 == user2
            default:
                return false
            }
        }
    }
}

extension WebSocket {
    struct Response: Decodable {
        private enum CodingKeys: String, CodingKey {
            case cid = "cid"
            case created = "created_at"
        }
        
        private static let channelInfoSeparator: Character = ":"
        
        let channelId: String?
        let channelType: ChannelType
        let event: Event
        let created: Date
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let cid = try container.decodeIfPresent(String.self, forKey: .cid)
            
            if let cid = cid, cid.contains(Response.channelInfoSeparator) {
                let channelPair = cid.split(separator: Response.channelInfoSeparator)
                channelId = String(channelPair[1])
                channelType = ChannelType(rawValue: String(channelPair[0])) ?? .unknown
            } else {
                channelId = nil
                channelType = .unknown
            }
            
            event = try Event(from: decoder)
            created = try container.decode(Date.self, forKey: .created)
        }
    }
}
