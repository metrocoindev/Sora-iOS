/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

import XCTest
@testable import SoraPassport
import SoraKeystore
import SoraCrypto
import RobinHood

private typealias ModificationBlock = (DecentralizedDocumentObject) -> DecentralizedDocumentObject
private typealias ExpectationBlock = (DecentralizedDocumentObject, OperationResult<String>) -> Bool

class IdentityVerifyOperationTests: XCTestCase {
    private let keystore = Keychain()
    private let settings = SettingsManager.shared

    override func setUp() {
        try? keystore.deleteAll()
        settings.removeAll()
    }

    override func tearDown() {
        try? keystore.deleteAll()
        settings.removeAll()
    }

    func testSuccessfullVerification() {
        let modificationBlock: ModificationBlock  = { ddo in
            return ddo
        }

        let expectationBlock: ExpectationBlock = { (ddo, result) in
            guard case .success(let publicKeyId) = result else {
                return false
            }

            guard let publicKey = ddo.publicKey.first else {
                return false
            }

            return publicKeyId == publicKey.pubKeyId
        }

        performVerificationTest(ddoModification: modificationBlock, expectedBlock: expectationBlock)
    }

    func testVerificationFailed() {
        let modification: ModificationBlock = { ddo in
            var modifiedDDO = ddo
            modifiedDDO.decentralizedId = Constants.dummyDid
            return modifiedDDO
        }

        let expectation: ExpectationBlock = { (_, result) in
            switch result {
            case .error(let error):
                if let identityError = error as? IdentityVerifyOperationError {
                    return identityError == .signatureInvalid
                } else {
                    return false
                }
            default:
                return false
            }
        }

        performVerificationTest(ddoModification: modification, expectedBlock: expectation)
    }

    // MARK: Private

    private func performVerificationTest(ddoModification: @escaping ModificationBlock,
                                         expectedBlock: ExpectationBlock) {
        // given

        var optionalDocumentObject: DecentralizedDocumentObject?
        let creationOperation = IdentityOperationFactory.createNewIdentityOperation()

        creationOperation.completionBlock = {}

        let verificationOperation = IdentityOperationFactory.createVerificationOperation()
        verificationOperation.configurationBlock = {
            guard let result = creationOperation.result else {
                verificationOperation.cancel()

                XCTFail()
                return
            }

            switch result {
            case .success(let document):
                let modifiedDocument = ddoModification(document)
                optionalDocumentObject = modifiedDocument
                verificationOperation.decentralizedDocument = modifiedDocument
            case .error(let error):
                verificationOperation.result = .error(error)
            }
        }

        verificationOperation.addDependency(creationOperation)

        let expectation = XCTestExpectation()

        verificationOperation.completionBlock = {
            expectation.fulfill()
        }

        // when

        OperationManager.shared.enqueue(operations: [creationOperation, verificationOperation], in: .normal)
        wait(for: [expectation], timeout: Constants.expectationDuration)

        guard let result = verificationOperation.result else {
            XCTFail("Verification result is missing")
            return
        }

        guard let ddo = optionalDocumentObject else {
            XCTFail("Decentralized Document Object is missing")
            return
        }

        XCTAssertTrue(expectedBlock(ddo, result))
    }
}
