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
    
    public static let jsonArrayRootKey = "posts"
}

public typealias Posts = JSONArrayOf<Post>


//MARK: JSONDecodable
extension Post {
    public init?(jsonDictionary: JSONDictionary?) {
        guard let
            jsonDictionary = jsonDictionary,
            id = jsonDictionary[Keys.id].int,
            title = jsonDictionary[Keys.title].string,
            markdown = jsonDictionary[Keys.markdown].string,
            tags = jsonDictionary[Keys.tags].array?.flatMap({Tag(jsonDictionary: $0)}) else {
                return nil
        }
        self.init(title: title, markdown: markdown, tags: tags)
        self.id = id
    }
    
}

//MARK: JSONEncodable

extension Post {
    
    struct Keys {
        static private let id = "id"
        static private let title = "title"
        static private let markdown = "markdown"
        static private let tags = "tags"
    }
    
    public var jsonDictionary: JSONDictionary {
        get {
            return [Keys.title: title, Keys.markdown: markdown, Keys.tags: tags.map({$0.jsonDictionary})]
        }
    }
}


