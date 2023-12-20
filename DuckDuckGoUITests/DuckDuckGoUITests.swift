//
//  DuckDuckGoUITests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
// Automation of the manual smoke tests in https://app.asana.com/0/1202500774821704/1201879741377823/f

import XCTest

// swiftlint:disable all

final class DuckDuckGoUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
//    let app = XCUIApplication()
    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//        
//        app.launchEnvironment = [
//            "BASE_URL": "http://localhost:8080",
//            "BASE_PIXEL_URL": "http://localhost:8080",
//            "DAXDIALOGS": "false",
//            "ONBOARDING": "false",
//            // usually just has to match an existing variant to prevent one being allocated
//            "VARIANT": "sc"
//        ]
//    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        app.search(forText: "https://privacy-test-pages.site/privacy-protections/request-blocking/")
        
        app.webViews.webViews.webViews/*@START_MENU_TOKEN@*/.buttons["Start the test"]/*[[".otherElements[\"Request blocking test page\"].buttons[\"Start the test\"]",".buttons[\"Start the test\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
//        let webViewQury:XCUIElementQuery = app.descendants(matching: .webView)
//        let webView = webViewQury.element(boundBy: 0)
        
        let about = app.staticTexts["Request Blocking Test Page"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: about, handler: nil)

        waitForExpectations(timeout: 10, handler: nil)
    }
}

extension XCUIApplication {
    
    private struct Constants {
        static let defaultTimeout: Double = 30
    }
    
    func search(forText text: String) {
        let searchentrySearchField = searchFields.element
        XCTAssertTrue(searchentrySearchField.waitForExistence(timeout: Constants.defaultTimeout))
        searchentrySearchField.tap()
        searchentrySearchField.typeText("\(text)\r")
//        Snapshot.waitForLoadingIndicatorToDisappear(within: Constants.defaultTimeout)
    }
}

// swiftlint:enable all
