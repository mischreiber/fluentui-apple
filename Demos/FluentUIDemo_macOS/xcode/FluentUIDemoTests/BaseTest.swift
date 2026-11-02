//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

@MainActor
class BaseTest: XCTestCase {
	let app = XCUIApplication()
	// must be overridden
	var controlName: String { "Base" }

	override func setUp() async throws {
		try await super.setUp()
		continueAfterFailure = false
		app.launch()
		app.staticTexts[controlName].click()
	}
}
