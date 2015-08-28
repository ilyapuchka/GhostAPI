//
//  PostsTests.swift
//  Ghost
//
//  Created by Ilya Puchka on 11.09.15.
//  Copyright © 2015 Ilya Puchka. All rights reserved.
//

import XCTest
import GhostAPI
import NetworkAPI

class PostsTests: GhostAPITests {

    override func setUp() {
        super.setUp()
        authorize(credentials)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testThatItCanGetPosts() {
        let expectation = expectationWithDescription("Fetched posts")
        self.api.posts { response -> Void in
            expectation.fulfill()
            guard let
                posts = response.result where
                posts.items.count > 0 &&
                posts.page == 1 &&
                posts.limit == 15 else {
                XCTAssert(false, "Should return posts")
                return
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func addPost(post: Post) -> Post! {
        var posts: Posts!
        let expectation = expectationWithDescription("Post added")
        XCTAssertNotThrows { () -> () in
            try api.addPost(post) { response -> Void in
                XCTAssertResponseError(response)
                posts = response.result
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        guard let addedPost = posts?.value.first else {
            XCTAssert(false, "Should return created post")
            return nil
        }
        return addedPost
    }
    
    func testThatItCanAddPost() {
        let post = Post(title: self.name, markdown: self.name, tags: [Tag(name: "test tag")])
        
        guard let addedPost = addPost(post) else {
            return
        }
        XCTAssertEqual(addedPost.title, post.title)
        XCTAssertEqual(addedPost.markdown, post.markdown)
    }
    
    func testThatItCanDeletePost() {
        let post = Post(title: self.name, markdown: self.name)
        
        guard let addedPost = addPost(post) else {
            return
        }
        
        let postDeleted = expectationWithDescription("Post deleted")
        api.deletePost(addedPost) { response -> Void in
            postDeleted.fulfill()
            XCTAssertResponseError(response)
            guard let _ = response.result else {
                XCTAssert(false, "Should return deleted posts")
                return;
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testThatItCanUpdatePost() {
        let post = Post(title: self.name, markdown: self.name)
        
        guard let addedPost = addPost(post) else {
            return
        }
        
        let postUpdated = expectationWithDescription("Post update")
        var updatedPosts: Posts!
        var updatedPost = addedPost
        updatedPost.title = "Updated \(updatedPost.title)"
        
        XCTAssertNotThrows { () -> () in
            try api.updatePost(updatedPost) { response -> Void in
                XCTAssertResponseError(response)
                updatedPosts = response.result
                postUpdated.fulfill()
            }
        }
        waitForExpectationsWithTimeout(5, handler: nil)
        guard let _ = updatedPosts, _ = updatedPosts.value.first else {
            XCTAssert(false, "Should return updated posts")
            return
        }
        
        XCTAssertEqual(updatedPosts.value.first!.title, updatedPost.title)
    }
    
    func testThatItReturnsErrorWhenItUpdatesNotExistingPost() {
        
    }
    
    func testThatItReturnsErrorWhenItDeletesNotExistingPost() {
        
    }

    func testThatItPaginatesPosts() {
        let expectation = expectationWithDescription("Fetched posts")
        var posts: PaginationOf<Post>!
        self.api.posts { response -> Void in
            posts = response.result
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
        
        let nextPageFetched = expectationWithDescription("Next page fetched")
        let nextPage = PaginationOf<Post>(page: 2, limit: 15)
        self.api.posts(PostsRequestOptions(pagination: nextPage)) {response in
            nextPageFetched.fulfill()
            guard let
                nextPosts = response.result where
                nextPosts.page == nextPage.page &&
                nextPosts.limit == nextPage.limit &&
                nextPosts.total == posts.total else {
                    XCTAssert(false)
                    return
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testThatItCanGetTags() {
        let expectation = expectationWithDescription("Fetched tags")
        self.api.tags{ response -> Void in
            expectation.fulfill()
            guard let tags = response.result where tags.value.count > 0 else {
                XCTAssert(false, "Should return tags")
                return
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}

