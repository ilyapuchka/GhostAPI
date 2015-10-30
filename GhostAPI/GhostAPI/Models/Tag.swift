//
//  Tag.swift
//  GhostAPI
//
//  Created by Ilya Puchka on 30.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import SwiftNetworking

public struct Tag: JSONConvertible {
    
    public typealias Id = Int
    private(set) public var id: Tag.Id!
    private(set) public var uuid: NSUUID!
    public let name: String
    public let slug: String!
    
    init(id: Tag.Id? = nil, uuid: NSUUID? = nil, name: String, slug: String? = nil) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.slug = slug
    }
    
    public init(name: String) {
        self.init(id: nil, uuid: nil, name: name, slug: nil)
    }
}

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