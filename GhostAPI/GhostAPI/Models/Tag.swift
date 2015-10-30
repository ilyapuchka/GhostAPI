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
    
    enum Keys: String {
        case id, uuid, name, slug
    }
    
    public init?(jsonDictionary: JSONDictionary?) {
        guard let
            json = JSONObject(jsonDictionary),
            id = json[Keys.id.rawValue] as? Tag.Id,
            uuid = json[Keys.uuid.rawValue] as? String,
            name = json[Keys.name.rawValue] as? String,
            slug = json[Keys.slug.rawValue] as? String
        else {
            return nil
        }
        self.init(id: id, uuid: NSUUID(UUIDString: uuid), name: name, slug: slug)
    }
}

//MARK: - JSONEncodable

extension Tag {
    
    public var jsonDictionary: JSONDictionary {
        return [Keys.name.rawValue: name]
    }
    
}