//
//  FolderModelTests.swift
//  DocReaderTests
//
//  Created by Michael A on 2018-02-20.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import XCTest
@testable import DocReader

class FolderModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFolder_setsTitle_whenInitWithTitle() {
        let folder = MockFolderModel(name: "Folder 1")
        XCTAssertEqual(folder.name!, "Folder 1")
    }
    
    func testFolder_setsDate_whenInitWithDate() {
        let dateNow = Date().timeIntervalSinceNow
        let date = Date(timeIntervalSinceNow: dateNow)
        let folder = MockFolderModel(date: date)
        XCTAssertEqual(folder.date, date)
    }
 
    func testFolder_setsPasswordProtection_whenInit() {
        let folder = MockFolderModel(isPasswordProtected: true)
        XCTAssertEqual(folder.isPasswordProtected, true)
    }
    
}

extension FolderModelTests {
    
    struct MockFolderModel {
        var name: String?
        var date: Date?
        var isPasswordProtected: Bool?
        
        init(name: String? = nil, date: Date? = nil, isPasswordProtected: Bool? = nil) {
            self.name = name
            self.date = date
            self.isPasswordProtected = isPasswordProtected
        }
    }
}






