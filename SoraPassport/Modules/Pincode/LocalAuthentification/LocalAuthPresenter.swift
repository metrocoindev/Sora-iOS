/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache 2.0
*/

import Foundation

class LocalAuthPresenter: PinSetupPresenterProtocol {
    weak var view: PinSetupViewProtocol?
    var wireframe: PinSetupWireframeProtocol!
    var interactor: LocalAuthInteractorInputProtocol!

    func start() {
        view?.didChangeAccessoryState(enabled: interactor.allowManualBiometryAuth)
        interactor.startAuth()
    }

    func activateBiometricAuth() {
        interactor.startAuth()
    }

    func submit(pin: String) {
        interactor.process(pin: pin)
    }
}

extension LocalAuthPresenter: LocalAuthInteractorOutputProtocol {

    func didEnterWrongPincode() {
        DispatchQueue.main.async { [weak self] in
            self?.view?.didReceiveWrongPincode()
        }
    }

    func didChangeState(from state: LocalAuthInteractor.LocalAuthState) {}

    func didCompleteAuth() {
        DispatchQueue.main.async { [weak self] in
            self?.wireframe.showAuthVerification(from: self?.view)
        }
    }

    func didUnexpectedFail() {
        DispatchQueue.main.async { [weak self] in
            self?.wireframe.showSignup(from: self?.view)
        }
    }
}
