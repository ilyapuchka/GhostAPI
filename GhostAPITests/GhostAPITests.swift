//
//  GhostAPITests.swift
//  GhostAPITests
//
//  Created by Ilya Puchka on 17.08.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import XCTest
@testable import GhostAPI
import NetworkAPI

var accessToken: AccessToken!
let TokenSetNotificationName = "TokenSetNotification"

class FakeAPICredentialsStorage: APICredentialsStorage {
    
    private var realStorage: APICredentialsStorage
    init(realStorage: APICredentialsStorage) {
        self.realStorage = realStorage
    }
    
    var accessToken: AccessToken? {
        get {
            return realStorage.accessToken
        }
        set {
            realStorage.accessToken = newValue
            NSNotificationCenter.defaultCenter().postNotificationName(TokenSetNotificationName, object: nil)
        }
    }
}

func XCTAssertNil<T>(expression: Optional<T>, @autoclosure message: () -> String = "") {
    if expression != nil {
        XCTAssert(false, message())
    }
}

func XCTAssertNotNil<T>(expression: Optional<T>, @autoclosure message: () -> String = "") {
    if expression == nil {
        XCTAssert(false, message())
    }
}

func XCTAssertResponseError(response: APIResponse) {
    XCTAssertNil(response.error, message: "Should not return error: \(response.error!)")
}

func XCTAssertThrows<ExpectedError: protocol<ErrorType, Equatable>>(expectedError: ExpectedError, block: () throws -> ()) {
    do {
        try block()
        XCTAssert(false, "Expected to throw error: \(expectedError)")
    }
    catch let error as ExpectedError {
        if expectedError != error {
            XCTAssert(false, "Expected to throw error: \(expectedError), but thrown error: \(error)")
        }
    }
    catch {
        XCTAssert(false, "Expected to throw error: \(expectedError), but thrown error: \(error)")
    }
}

func XCTAssertNotThrows(block: () throws -> ()) {
    do {
        try block()
    }
    catch {
        XCTAssert(false, "Should not throw errors: \(error)")
    }
}

class GhostAPITests: XCTestCase {
    
    var api: APIClient!
    var credentialsStorage: APICredentialsStorage!
    let credentials = EmailCredentials(username: "test@puchka.me", password: "12345678")
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        credentialsStorage = FakeAPICredentialsStorage(realStorage: APICredentialsStorageInMemory());
        credentialsStorage.accessToken = accessToken
        
        let configuration = NetworkSessionImp.foregroundSessionConfiguration([HTTPHeader.Accept([HTTPContentType.JSON])])
        let requestProcessing = DefaultAPIRequestProcessing(defaultHeaders: JSONHeaders)
        let session = NetworkSessionImp(configuration: configuration, resultsQueue: dispatch_get_main_queue(), requestProcessing: requestProcessing, credentialsStorage: credentialsStorage)
        self.api = APIClient(baseURL: NSURL(string: "http://localhost:2368/ghost/api/v0.1/")!, session: session)
        self.api.accessTokenRefresh = self.api
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func authorize(credentials: EmailCredentials) {
        do {
            if accessToken == nil {
                let expectation = self.expectationWithDescription("Logged in")
                try self.api.login(credentials) { _ in
                    accessToken = self.credentialsStorage.accessToken
                    expectation.fulfill()
                }
                
                waitForExpectationsWithTimeout(5, handler: nil)
            }
        }
        catch {
            XCTAssert(false, "Should not throw errors")
        }
    }
    
    func testThatItCanLoginWithValidCredentials() {
        authorize(credentials)
        XCTAssert(accessToken != nil, "Should return access token")
    }
    
    func testThatItThrowsErrorOnLoginWithEmptyUserName() {
        let underlyingError = NSError(code: NetworkErrorCode.InvalidUserName)
        let expectedError = NSError(code: NetworkErrorCode.InvalidCredentials, userInfo: [NSUnderlyingErrorKey: underlyingError])
        XCTAssertThrows(expectedError) { () -> () in
            try self.api.login(EmailCredentials(username: "", password: "123")) {_ in}
        }
    }

    func testThatItThrowsErrorOnLoginWithEmptyPassword() {
        let underlyingError = NSError(code: NetworkErrorCode.InvalidPassword)
        let expectedError = NSError(code: NetworkErrorCode.InvalidCredentials, userInfo: [NSUnderlyingErrorKey: underlyingError])
        XCTAssertThrows(expectedError) { () -> () in
            try self.api.login(EmailCredentials(username: "123", password: "")) {_ in}
        }
    }

    func testThatItCanLoginAndRefreshToken() {
        authorize(credentials)
        let expiredToken = AccessToken(type: accessToken.type, token: accessToken.token, refresh: accessToken.refresh, expires: NSDate(timeIntervalSinceNow: 1))
        credentialsStorage.accessToken = expiredToken
        expectationForNotification(TokenSetNotificationName, object: nil, handler: nil)
        
        //make any signed request
        let expectation = expectationWithDescription("Request succeeded")
        self.api.posts{ response -> Void in
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(5, handler: nil)
        
        guard let accessToken = credentialsStorage.accessToken else {
            XCTAssert(false, "Should return access token")
            return
        }

        XCTAssertNotEqual(accessToken.token, expiredToken.token)
    }

}
