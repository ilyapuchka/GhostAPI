//
//  APICredentials.swift
//  Ghost
//
//  Created by Ilya Puchka on 16.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import Foundation
import NetworkAPI

extension String {
    var queryDictionary: JSONDictionary {
        get {
            var queryDict = JSONDictionary()
            let queryPairs = self.componentsSeparatedByString("&")
            for pair in queryPairs {
                if let range = pair.rangeOfString("=") {
                    let key = pair.substringToIndex(range.startIndex)
                    let value = pair.substringFromIndex(advance(range.startIndex, 1))
                    queryDict[key] = value
                }
            }
            return queryDict
        }
    }
}

public struct EmailCredentials: APIRequestDataEncodable {
    public let username: String
    public let password: String
    let grant_type = "password"
    let clientId = "ghost-admin"

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct RefreshTokenCredentials: JSONEncodable, APIRequestDataEncodable {
    
    let refreshToken: String
    let grant_type = "refresh_token"
    let clientId = "ghost-admin"
    
    init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
}

//MARK: - JSONEncodable

extension RefreshTokenCredentials {
    
    struct Keys {
        static let refreshToken = "refresh_token"
        static let grantType = "grant_type"
        static let clientId = "client_id"
    }

    public var jsonDictionary: JSONDictionary {
        get {
            return [
                Keys.refreshToken: refreshToken,
                Keys.grantType: grant_type,
                Keys.clientId: clientId
            ]
        }
    }
}


//MARK: - APIRequestDataEncodable
extension EmailCredentials {
    
    public func encodeForAPIRequestData() throws -> NSData {
        guard username.characters.count > 0 else {
            throw NSError.errorWithUnderlyingError(NSError(code: .InvalidUserName), code: .InvalidCredentials)
        }

        guard password.characters.count > 0 else {
            throw NSError.errorWithUnderlyingError(NSError(code: .InvalidPassword), code: .InvalidCredentials)
        }

        guard let encoded = encodeForQuery(), data = encoded.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw NSError(code: .BadRequest)
        }
        
        return data
    }
}

extension RefreshTokenCredentials {
    public func encodeForAPIRequestData() throws -> NSData {
        return try encodeJSON()
    }
}

//MARK: - APIRequestQueryEncodable

extension EmailCredentials {
    
    struct Keys {
        static let username = "username"
        static let password = "password"
        static let grantType = "grant_type"
        static let clientId = "client_id"
    }
    
    public func encodeForQuery() -> String? {
        let query: APIRequestQuery = [
            Keys.username: username,
            Keys.password: password,
            Keys.grantType: grant_type,
            Keys.clientId: clientId
        ]
        return percentEncodedQueryString(query)
    }
}


