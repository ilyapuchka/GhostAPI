//
//  Pagination.swift
//  GhostAPI
//
//  Created by Ilya Puchka on 28.10.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import SwiftNetworking

public struct GhostAPIPagination: PaginationMetadata {
    public var page: Int
    public var limit: Int
    public var pages: Int
    public var total: Int
    
    public init(page: Int, limit: Int, pages: Int) {
        self.init(page: page, limit: limit, pages: pages, total: 0)
    }
    
    public init(page: Int, limit: Int, pages: Int, total: Int) {
        self.page = page
        self.limit = limit
        self.pages = pages
        self.total = total
    }
}

extension GhostAPIPagination {
    
    enum Keys: String {
        case page, limit, pages, total
    }

    public init?(jsonDictionary: JSONDictionary?) {
        guard let
            json = JSONObject(jsonDictionary),
            page = json[Keys.page.rawValue] as? Int,
            limit = json[Keys.limit.rawValue] as? Int,
            pages = json[Keys.pages.rawValue] as? Int,
            total = json[Keys.total.rawValue] as? Int
        else
        {
            return nil
        }
        
        self.init(page: page, limit: limit, pages: pages, total: total)
    }

}

public struct PostsPagination: AnyPagination {
    
    public var items: [Post]
    public var metadata: GhostAPIPagination?
    
    public init(items: [Post] = [], metadata: GhostAPIPagination? = nil) {
        self.items = items
        self.metadata = metadata
    }
    
    public init(metadata: GhostAPIPagination?) {
        self.init(items: [], metadata: metadata)
    }

    public static func paginationKey() -> String {
        return "meta.pagination"
    }
    public static func itemsKey() -> String {
        return "posts"
    }

}

public struct TagsPagination: AnyPagination {
    
    public var items: [Tag]
    public var metadata: GhostAPIPagination?
    
    public init(items: [Tag] = [], metadata: GhostAPIPagination? = nil) {
        self.items = items
        self.metadata = metadata
    }
    
    public init(metadata: GhostAPIPagination?) {
        self.init(items: [], metadata: metadata)
    }
    
    public static func paginationKey() -> String {
        return "meta.pagination"
    }
    public static func itemsKey() -> String {
        return "tags"
    }
    
}

//This does not work probably due to rdar://23339313
//PostsPagination and TagsPagination is a workaround
//extension AnyPagination where Self.PaginationMetadataType == GhostAPIPagination, Self.Element == Post {
//    static func paginationKey() -> String {
//        return "posts"
//    }
//    static func itemsKey() -> String {
//        return "meta"
//    }
//}
//
//extension AnyPagination where Self.PaginationMetadataType == GhostAPIPagination, Self.Element == Tag {
//    static func paginationKey() -> String {
//        return "tags"
//    }
//    static func itemsKey() -> String {
//        return "meta"
//    }
//}


