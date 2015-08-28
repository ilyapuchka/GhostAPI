//
//  GhostAPI.swift
//  Ghost
//
//  Created by Ilya Puchka on 16.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import NetworkAPI

//MARK: Auth

public enum AuthEndpoint: Endpoint {
    case Token
    
    public var path: String {
        get {
            switch self {
            case .Token: return "authentication/token/"
            }
        }
    }
    
    public var signed: Bool {
        return false
    }
    
    public var method: HTTPMethod {
        get {
            switch self {
            case .Token: return .POST
            }
        }
    }
}

extension APIClient  {

    public func login(emailCredentials: EmailCredentials, completion: (APIResponseOf<AccessToken>) -> ()) throws -> APIRequestTask {
        let headers = [HTTPHeader.ContentType(HTTPContentType.form), HTTPHeader.Accept([HTTPContentType.JSON])]
        let apiRequest = try APIRequestFor<AccessToken>(endpoint: AuthEndpoint.Token, baseURL: baseURL, input: emailCredentials, headers: headers)
        return request(apiRequest, completion: completion)
    }
    
}

//MARK: - APIClientAccessTokenRefresh

extension APIClient: APIClientAccessTokenRefresh {
    
    public func apiClient(client: APIClient, requestToRefreshToken token: AccessToken) -> APIRequestFor<AccessToken> {
        let credentials = RefreshTokenCredentials(refreshToken: token.refresh)
        let refreshTokenRequest = try! APIRequestFor<AccessToken>(endpoint: AuthEndpoint.Token, baseURL: client.baseURL, input: credentials)
        return refreshTokenRequest
    }
}

//MARK: Posts

public enum PostsEndpoint: Endpoint {
    
    case GetPosts
    case GetPost(Post.Id)
    case AddPost
    case UpdatePost(Post.Id)
    case DeletePost(Post.Id)
    
    public var path: String {
        switch self {
        case .GetPosts: return "posts/"
        case .AddPost: return "posts/"
        case .GetPost(let id): return "posts/\(id)/"
        case .UpdatePost(let id): return "posts/\(id)/"
        case .DeletePost(let id): return "posts/\(id)/"
        }
    }
    
    public var signed: Bool {
        return true
    }
    
    public var method: HTTPMethod {
        switch self {
        case .GetPosts, .GetPost: return .GET
        case .AddPost: return .POST
        case .UpdatePost: return .PUT
        case .DeletePost: return .DELETE
        }
    }
}

public struct PostsRequestOptions {
    
    public enum StatusFilter: String {
        case All = "all", Published = "published", Draft = "draft"
    }
    
    public enum StaticFilter: String {
        case All = "all", Static = "true", NotStatic = "false"
    }
    
    public let pagination: PaginationOf<Post>?
    public let status: StatusFilter
    public let includeStatic: StaticFilter
    
    public init(status: StatusFilter = .All, includeStatic: StaticFilter = .All, pagination: PaginationOf<Post>? = nil) {
        self.pagination = pagination
        self.status = status
        self.includeStatic = includeStatic
    }
    
    var query: APIRequestQuery {
        var query = [
            "status": status.rawValue,
            "staticPages": includeStatic.rawValue,
            "include": "tags"
        ]
        if let pagination = pagination {
            query["page"] = "\(pagination.page)"
            query["limit"] = pagination.limit > 0 ? "\(pagination.limit)": "all"
        }
        return query
    }
    
}

extension APIClient {

    public func posts(options: PostsRequestOptions = PostsRequestOptions(pagination: PaginationOf<Post>(page: 1, limit: 15)), completion: APIResponseOf<PaginationOf<Post>> -> Void) -> APIRequestTask {
        let apiRequest = APIRequestFor<PaginationOf<Post>>(endpoint: PostsEndpoint.GetPosts, baseURL: baseURL, query: options.query)
        return request(apiRequest, completion: completion)
    }
    
    public func postWithId(id: Post.Id, options: PostsRequestOptions = PostsRequestOptions(), completion: APIResponseOf<Posts> -> Void) -> APIRequestTask {
        let apiRequest = APIRequestFor<Posts>(endpoint: PostsEndpoint.GetPost(id), baseURL: baseURL, query: options.query)
        return request(apiRequest, completion: completion)
    }
    
    public func addPost(post: Post, completion: APIResponseOf<Posts> -> Void) throws -> APIRequestTask {
        let apiRequest = try APIRequestFor<Posts>(endpoint: PostsEndpoint.AddPost, baseURL: baseURL, input: Posts([post]), query: PostsRequestOptions().query)
        return request(apiRequest, completion: completion)
    }
    
    public func deletePost(post: Post, completion: APIResponseOf<Posts> -> Void) -> APIRequestTask {
        let apiRequest = APIRequestFor<Posts>(endpoint: PostsEndpoint.DeletePost(post.id!), baseURL: baseURL, query: PostsRequestOptions().query)
        return request(apiRequest, completion: completion)
    }
    
    public func updatePost(post: Post, completion: APIResponseOf<Posts> -> Void) throws -> APIRequestTask {
        let apiRequest = try APIRequestFor<Posts>(endpoint: PostsEndpoint.UpdatePost(post.id!), baseURL: baseURL, input: Posts([post]), query: PostsRequestOptions().query)
        return request(apiRequest, completion: completion)

    }
}

//MARK: Tags

public enum TagsEndpoint: Endpoint {
    case GetTags
    
    public var path: String {
        return "tags/"
    }
    
    public var signed: Bool {
        return true
    }
    
    public var method: HTTPMethod {
        return .GET
    }
}

extension APIClient {
    
    public func tags(completion: APIResponseOf<Tags> -> Void) -> APIRequestTask {
        let apiRequest = APIRequestFor<Tags>(endpoint: TagsEndpoint.GetTags, baseURL: baseURL)
        return request(apiRequest, completion: completion)
    }
    
}

//MARK: Upload

extension APIClient {
    
}

