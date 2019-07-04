/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache-2.0
*/

import Foundation
import FireMock

enum SmsCodeVerificationMock: FireMockProtocol {
    case success

    var afterTime: TimeInterval {
        return 1.0
    }

    var statusCode: Int {
        return 200
    }

    func mockFile() -> String {
        return R.file.successResultJson.fullName
    }
}

extension SmsCodeVerificationMock {
    static func register(mock: SmsCodeVerificationMock, projectUnit: ServiceUnit) {
        guard let service = projectUnit.service(for: ProjectServiceType.smsVerify.rawValue) else {
            Logger.shared.warning("Can't find sms code verification service endpoint to mock")
            return
        }

        guard let url = URL(string: service.serviceEndpoint) else {
            Logger.shared.warning("Can't create sms code verification regex")
            return
        }

        FireMock.register(mock: mock, forURL: url, httpMethod: .post)
    }
}
