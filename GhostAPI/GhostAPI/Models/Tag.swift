//
//  Tag.swift
//  GhostAPI
//
//  Created by Ilya Puchka on 30.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import SwiftNetworking

public struct Tag: JSONArrayConvertible {
    
    public typealias Id = Int
    private(set) public var id: Tag.Id!
    private(set) public var uuid: NSUUID!
    public let name: String
    public let slug: String!
    
    public init(name: String) {
        self.name = name
        self.slug = nil
        self.id = nil
        self.uuid = nil
    }
    
    public static let jsonArrayRootKey = "tags"
}

public typealias Tags = JSONArrayOf<Tag>

//MARK: - JSONDecodable

extension Tag {
    
    struct Keys {
        static private let id = "id"
        static private let uuid = "uuid"
        static private let name = "name"
        static private let slug = "slug"
    }
    
    public init?(jsonDictionary: JSONDictionary?) {
        guard let jsonDictionary = jsonDictionary,
            id = jsonDictionary[Keys.id].int,
            uuid = jsonDictionary[Keys.uuid].string,
            name = jsonDictionary[Keys.name].string,
            slug = jsonDictionary[Keys.slug].string else {
                return nil
        }
        self.name = name
        self.slug = slug
        self.id = id
        self.uuid = NSUUID(UUIDString: uuid)
    }
}

//MARK: - JSONEncodable

extension Tag {
    
    public var jsonDictionary: JSONDictionary {
        return [Keys.name: name]
    }
    
}