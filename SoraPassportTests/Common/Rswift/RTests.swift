/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

import XCTest
@testable import SoraPassport

class RTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllReferenceValid() {
        XCTAssertNoThrow(try R.validate())
    }
}
