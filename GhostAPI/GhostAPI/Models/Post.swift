//
//  Post.swift
//  GhostAPI
//
//  Created by Ilya Puchka on 16.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import SwiftNetworking

//MARK: Posts

public struct Post: JSONArrayConvertible {
    
    public typealias Id = Int
    private(set) public var id: Post.Id!
    public var title: String
    public var markdown: String
    public var tags: [Tag]
    
    public init(title: String, markdown: String, tags: [Tag] = []) {
        self.title = title
        self.markdown = markdown
        self.tags = tags
    }
    
    public static let itemsKey: String? = "posts"
}

//MARK: JSONDecodable
extension Post {

    enum Keys: String {
        case id, title, markdown, tags
    }

    public init?(jsonDictionary: JSONDictionary?) {
        guard let
            json = JSONObject(jsonDictionary),
            id = json[Keys.id.rawValue] as? Int,
            title = json[Keys.title.rawValue] as? String,
            markdown = json[Keys.markdown.rawValue] as? String
        else {
            return nil
        }
        let tags = json[Keys.tags.rawValue] as? [Tag] ?? []
        self.init(title: title, markdown: markdown, tags: tags)
        self.id = id
    }
    
}

//MARK: JSONEncodable

extension Post {
    
    public var jsonDictionary: JSONDictionary {
        get {
            return [
                Keys.title.rawValue: title,
                Keys.markdown.rawValue: markdown,
                Keys.tags.rawValue: tags.map({$0.jsonDictionary})
            ]
        }
    }
}


