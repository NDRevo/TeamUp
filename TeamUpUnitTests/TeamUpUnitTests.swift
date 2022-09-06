//
//  TeamUpUnitTests.swift
//  TeamUpUnitTests
//
//  Created by Noe  Duran on 6/30/22.
//

import XCTest
@testable import TeamUp

final class TeamUpUnitTests: XCTestCase {
    
    let cloudKitManager = CloudKitManager.shared

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchPublishedEvents() async throws {
        //let events = try await cloudKitManager.getEvents(thatArePublished: true, withSpecificOwner: false)
        //XCTAssert(!events.isEmpty)
    }
    
    func testFetchSearchPlayers() throws {
        //New Tests
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
