//
//  ApesterDemoUITests.swift
//  ApesterDemoUITests
//
//  Created by Arkadi Yoskovitz on 12/14/22.
//

import XCTest

class ApesterDemoUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // func testExample() throws {
    //     // UI tests must launch the application that they test.
    //     let app = XCUIApplication()
    //     app.launch()
    //
    //     // Use XCTAssert and related functions to verify your tests produce the correct results.
    // }
    //
    // func testLaunchPerformance() throws {
    //     if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //         // This measures how long it takes to launch your application.
    //         measure(metrics: [XCTApplicationLaunchMetric()]) {
    //             XCUIApplication().launch()
    //         }
    //     }
    // }
    
    private func helper_setupEnviorment(enviorment: String) -> XCUIApplication {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        app.staticTexts["clear input"].tap()
        
        // Enviorment screen
        app.buttons[enviorment].tap()
        
        return app
    }
    private func helper_waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval) {
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                
                self.record(XCTIssue(type: XCTIssue.IssueType.unmatchedExpectedFailure, compactDescription: message))
            }
        }
    }
    private func helper_dismissKeyboardIfPresent() {
        let app = XCUIApplication()
        
        let keyboard = app.keyboards.element(boundBy: 0)
        
        if keyboard.exists {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if keyboard.buttons["Hide keyboard"].exists {
                    keyboard.buttons["Hide keyboard"].tap()
                }
            } else {
                if keyboard.buttons["Dismiss"].exists {
                    keyboard.buttons["Dismiss"].tap()
                }
                if keyboard.buttons["return"].exists {
                    keyboard.buttons["return"].tap()
                }
            }
        }
    }
    
    // func testExample_DevelopmentChannel() throws {
    //     // try helper_runTest(in: "Development", with: "610a3f7dabe1d5003c662f3b")
    // }
    //
    // func testExample_ProductionChannel_amittest () throws {
    //     // try helper_runTest(in: "Production", with: "6159893c3f92d5000dea19cc")
    // }
    func testExample_ProductionChannel_kickertest() throws {
        
        try helper_runTest(in: "Production", with: "61ee7fd7a33874001368f396")
    }
    
    
    func helper_runTest(in environment: String, with token: String) throws {
        
        // launch & Enviorment screen
        let app = helper_setupEnviorment(enviorment: environment)
        let textfieldchannelTextField = app.textFields["textFieldChannel"]
        textfieldchannelTextField.tap()
        
        // TODO: - input channel string -
        textfieldchannelTextField.typeText(token)
        helper_dismissKeyboardIfPresent()
        
        let activateButton = app.buttons.element(matching: .button, identifier: "buttonActivation")
        activateButton.tap()
        
        let wishListLabel = app.staticTexts["Apester units ready"]
        helper_waitForElementToAppear(wishListLabel, timeout: 5)
        sleep(20)
        app.staticTexts["Activate feed"].tap()
        sleep(2)
        let emojislistCollectionView = app.collectionViews.element(boundBy:0)
        // Sample usage:
        if let cell = ApesterDemoUITestsWebHelper().scroll(emojislistCollectionView, toFindCellWithId: "FeedApesterCell") {
            cell.tap()
        } else {
            XCTFail("Unable to find the cell :(")
        }
        sleep(20)
    }
}

class ApesterDemoUITestsWebHelper
{
    // Thanks to @MonsieurDart for the idea :)
    func scroll(_ collectionView: XCUIElement, toFindCellWithId identifier: String) -> XCUIElement?
    {
        guard collectionView.elementType == .collectionView else {
            fatalError("XCUIElement is not a collectionView.")
        }
        
        var reachedTheEnd = false
        var allVisibleElements = [String]()
        
        while !reachedTheEnd {
            
            let cell = collectionView.cells[identifier]
            
            // Did we find our cell ?
            if cell.exists {
                return cell
            }
            
            // If not: we store the list of all the elements we've got in the CollectionView
            let allElements = collectionView.cells.allElementsBoundByIndex.map({ $0.identifier })
            
            // Did we read then end of the CollectionView ?
            // i.e: do we have the same elements visible than before scrolling ?
            reachedTheEnd = (allElements == allVisibleElements)
            allVisibleElements = allElements
            
            // Then, we do a scroll up on the scrollview
            let startCoordinate = collectionView.coordinate(withNormalizedOffset: .init(dx: 0.99, dy: 0.9))
            startCoordinate.press(
                forDuration: 0.01,
                thenDragTo: collectionView.coordinate(withNormalizedOffset: .init(dx: 0.99, dy: 0.1))
            )
        }
        return nil
    }
    
    
    // After this, you may want to scroll to top ...
    func statusBarScrollToTop() {
        //let statusBar = XCUIApplication().statusBars.element
        //statusBar.doubleTap()
        let statusBar = XCUIApplication(bundleIdentifier: "com.apple.springboard").statusBars.element(boundBy: 1)
        statusBar.tap()
    }
    
    private func wait(forElement element: XCUIElement, exists: Bool, timeout: TimeInterval) {
        let predicate = NSPredicate(format: "exists == %@", NSNumber(value: exists))
        let e = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [ e ], timeout: timeout)
        XCTAssert(result == .completed)
    }
    
    func wait(forWebViewElement element: XCUIElementTypeQueryProvider, timeout: TimeInterval = 20) {
        
        // xcode has bug, so we cannot directly access webViews XCUIElements
        // as a workaround we can check debugDesciption and parse it, that works
        let predicate = NSPredicate { obj, _ in
            guard let el = obj as? XCUIElement else {
                return false
            }
            // If element has firstMatch, than there will be description of that at the end
            // If no match - it will be ended with "FirstMatch\n"
            return !el.firstMatch.debugDescription.hasSuffix("First Match\n")
        }
        
        // we need to take .firstMatch, because we parse description for that
        let e = XCTNSPredicateExpectation(predicate: predicate, object: element.firstMatch)
        let result = XCTWaiter().wait(for: [ e ], timeout: timeout)
        XCTAssert(result == .completed)
    }
    
    func wait(forElement element: XCUIElement, timeout: TimeInterval = 20) {
        wait(forElement: element, exists: true, timeout: timeout)
    }
    
    func wait(elementToHide element: XCUIElement, timeout: TimeInterval = 20) {
        wait(forElement: element, exists: false, timeout: timeout)
    }
    
    func wait(seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
    
    private func coordinate(forWebViewElement element: XCUIElement) -> XCUICoordinate? {
        // parse description to find its frame
        let descr = element.firstMatch.debugDescription
        guard let rangeOpen = descr.range(of: "{{", options: [.backwards]),
              let rangeClose = descr.range(of: "}}", options: [.backwards]) else {
            return nil
        }
        
        let frameStr = String(descr[rangeOpen.lowerBound ..< rangeClose.upperBound])
        let rect = NSCoder.cgRect(for: frameStr)
        
        // tap on the center
        let center = CGVector(dx: rect.midX, dy: rect.midY)
        let coordinate = XCUIApplication().coordinate(withNormalizedOffset: .zero).withOffset(center)
        return coordinate
    }
    
    func tap(onWebViewElement element: XCUIElement) {
        // xcode has bug, so we cannot directly access webViews XCUIElements
        // as workaround we can check debugDesciption, find frame and tap by coordinate
        // wait for element to appear before tap
        wait(forWebViewElement: element)
        
        let coord = coordinate(forWebViewElement: element)
        coord?.tap()
    }
    
    func exists(webViewElement element: XCUIElement) -> Bool {
        return coordinate(forWebViewElement: element) != nil
    }
    
    func typeText(_ text: String, toWebViewField element: XCUIElement) {
        // xcode has bug, so we cannot directly access webViews XCUIElements
        // as workaround we can check debugDesciption, find frame, tap by coordinate,
        // and then paste text there
        
        // wait for element to appear before tap
        wait(forWebViewElement: element)
        
        guard let coordBeforeTap = coordinate(forWebViewElement: element) else {
            XCTFail("no element \(element)")
            return
        }
        // "typeText" doesn't work, so we paste text
        // first tap to activate field
        UIPasteboard.general.string = text
        coordBeforeTap.tap()
        // wait for keyboard to appear
        wait(forWebViewElement: XCUIApplication().keyboards.firstMatch)
        // after tap coordinate can change
        guard let coordAfterTap = coordinate(forWebViewElement: element) else {
            XCTFail("no element \(element)")
            return
        }
        // tap one more time for "paste" menu
        coordAfterTap.press(forDuration: 1)
        wait(forElement: XCUIApplication().menuItems["Paste"])
        
        if XCUIApplication().menuItems["Select All"].exists {
            // if there was a text - remove it, by pressing Select All and Cut
            XCUIApplication().menuItems["Select All"].tap()
            XCUIApplication().menuItems["Cut"].tap()
            // close keyboard
            XCUIApplication().toolbars.buttons["Done"].tap()
            // call this method one more time
            typeText(text, toWebViewField: element)
            return
        }
        
        XCUIApplication().menuItems["Paste"].tap()
        // close keyboard
        XCUIApplication().toolbars.buttons["Done"].tap()
    }
}
