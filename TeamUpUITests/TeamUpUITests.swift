//
//  TeamUpUITests.swift
//  TeamUpUITests
//
//  Created by Noé Duran on 1/27/22.
//

import XCTest

class TeamUpUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateEvent() throws {
        app.buttons["Create Player"].tap()
        XCTAssertTrue(app.buttons["Dismiss"].exists)
        
        let eventNameTextField = app.textFields["Event Name"]
        eventNameTextField.tap()
        eventNameTextField.typeText("In-Houses")
        
        let eventLocationTextField = app.textFields["Event Location"]
        eventLocationTextField.tap()
        eventLocationTextField.typeText("Online")
        
        let eventDescriptionTextEditor = app.textViews.firstMatch
        eventDescriptionTextEditor.tap()
        eventDescriptionTextEditor.typeText("This is my description!")
        
        let createEventButton = app.buttons["Create Event"]
        createEventButton.tap()
        
        XCTAssertTrue(app.tables.cells.firstMatch.label.contains("In-Houses"))
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
