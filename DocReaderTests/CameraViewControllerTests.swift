//
//  CameraViewControllerTests.swift
//  DocReaderTests
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import XCTest
@testable import DocReader

class CameraViewControllerTests: XCTestCase {
    
    var sut: CameraViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController")
        sut = viewController as! CameraViewController
        _ = sut.view
        
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_viewController_hasBackupBarButton_withSelfAsTarget() {
        let target = sut.navigationItem.rightBarButtonItem?.target
        XCTAssertEqual(target as? UIViewController, sut)
    }
    
}
