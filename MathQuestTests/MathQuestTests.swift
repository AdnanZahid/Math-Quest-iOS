//
//  MathQuestTests.swift
//  MathQuestTests
//
//  Created by Adnan Zahid on 2/10/15.
//  Copyright (c) 2015 Adnan Zahid. All rights reserved.
//

import SpriteKit
import XCTest

@testable import MathQuest

@MainActor
final class MathQuestTests: XCTestCase {

    func testGameViewControllerLoadsHomeScene() throws {
        let controller = GameViewController()
        controller.loadViewIfNeeded()

        let skView = try XCTUnwrap(controller.view as? SKView)
        XCTAssertTrue(skView.scene is Home)
        XCTAssertEqual(skView.scene?.scaleMode, .aspectFill)
    }

    func testPerformanceExample() {
        measure {
            _ = GameViewController()
        }
    }
}
