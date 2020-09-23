/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache 2.0
*/

import XCTest
@testable import SoraPassport
import SoraKeystore

class WalletTests: XCTestCase {
    private(set) var keystore = Keychain()
    private(set) var settings = SettingsManager.shared

    override func setUp() {
        try? keystore.deleteAll()
        settings.removeAll()
    }

    override func tearDown() {
        try? keystore.deleteAll()
        settings.removeAll()
    }

    func testViewFactory() {
        settings.decentralizedId = Constants.dummyDid
        settings.publicKeyId = Constants.dummyPubKeyId

        _ = createIdentity(with: keystore)

        let walletContext = WalletContextFactory.createContext()
        XCTAssertNotNil(walletContext)
        XCTAssertNoThrow(try walletContext?.createRootController())
    }
}
