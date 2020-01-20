//
//  Shinkansen3DSeatBookingPrototypeUITests.swift
//  Shinkansen3DSeatBookingPrototypeUITests
//
//  Created by shawn on 2019/12/27.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import XCTest

class Shinkansen3DSeatBookingPrototypeUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    func testUI(){
        
        let app = XCUIApplication()
        app.textFields["IDNUMBER"].tap()
        app.textFields["EMAIL"].tap()
        app.secureTextFields["PASSWORD"].tap()
        app.buttons["LOGIN"].tap()
        app.buttons["BOOKING"].tap()
        
        let element5 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        let element3 = element5.children(matching: .other).element
        let element = element3.children(matching: .other).element(boundBy: 0)
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[" 臺北市"]/*[[".cells.staticTexts[\" 臺北市\"]",".staticTexts[\" 臺北市\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts[" 臺中市"]/*[[".cells.staticTexts[\" 臺中市\"]",".staticTexts[\" 臺中市\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let element2 = element3.children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element2.tap()
        //element2.tap()
        //app.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["28"]/*[[".cells.staticTexts[\"28\"]",".staticTexts[\"28\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        //app.buttons["SELECT"].tap()
        element3.children(matching: .other).element(boundBy: 2).children(matching: .other).element.tap()
        app.staticTexts["Afternoon"].tap()
        app.staticTexts["Evening"].tap()
        
        let element4 = element3.children(matching: .other).element(boundBy: 3).children(matching: .other).element
        element4.tap()
        
        let staticText = app.staticTexts["自強號"]
        staticText.tap()
        app.staticTexts["莒光號"].tap()
        element4.tap()
        //element4.tap()
        staticText.tap()
        app.buttons["Search for Tickets"].tap()
        tablesQuery2.children(matching: .cell).element(boundBy: 0).staticTexts["9:24 PM – 9:48 PM"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["殘障座"]/*[[".cells.staticTexts[\"殘障座\"]",".staticTexts[\"殘障座\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        
        
        
        element5.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.buttons["Please Select a Seat"].tap()

        let purchaseThisTicketButton = app.buttons["Purchase this Ticket"]
        purchaseThisTicketButton.tap()
        element5.tap()
        app.buttons["RECORD"].tap()
        
    }

                
        

        
        
        //        let app = XCUIApplication()
//        app.textFields["IDNUMBER"].tap()
//        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()
//        app.textFields["EMAIL"].tap()
//        app.secureTextFields["PASSWORD"].tap()
//        app.buttons["LOGIN"].tap()
//        //app.buttons["BOOKING"].tap()
//        XCUIApplication().buttons["BOOKING"].tap()

                
                
              

        
    }
    func test2(){
        


        
    }
    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
