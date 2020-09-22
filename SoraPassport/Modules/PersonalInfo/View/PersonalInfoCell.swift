/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache 2.0
*/

import UIKit
import SoraUI
import SoraFoundation

protocol PersonalInfoCellDelegate: class {
    func didSelectNext(on cell: PersonalInfoCell)
    func didChangeValue(in cell: PersonalInfoCell)
}

@IBDesignable
final class PersonalInfoCell: UITableViewCell {
    @IBOutlet private(set) var titleLabel: UILabel!
    @IBOutlet private(set) var textField: UITextField!
    @IBOutlet private(set) var borderView: BorderedContainerView!

    @IBInspectable
    var normalColor: UIColor = .black {
        didSet {
            updateErrorState()
        }
    }

    @IBInspectable
    var errorColor: UIColor = .red {
        didSet {
            updateErrorState()
        }
    }

    @IBInspectable
    var disabledAlpha: CGFloat = 0.5 {
        didSet {
            updateEnabledState()
        }
    }

    var isError: Bool = false {
        didSet {
            updateErrorState()
        }
    }

    weak var delegate: PersonalInfoCellDelegate?

    var model: InputViewModelProtocol?

    func bind(model: InputViewModelProtocol) {
        self.model = model

        titleLabel.text = model.title
        textField.text = model.inputHandler.value

        textField.autocapitalizationType = model.autocapitalization

        updateEnabledState()
    }

    private func updateErrorState() {
        if titleLabel != nil {
            titleLabel.textColor = !isError ? normalColor : errorColor
        }
    }

    private func updateEnabledState() {
        guard let model = model else {
            return
        }

        if model.inputHandler.enabled {
            textField.alpha = 1.0
            titleLabel.alpha = 1.0
            textField.isEnabled = true
        } else {
            textField.alpha = disabledAlpha
            titleLabel.alpha = disabledAlpha
            textField.isEnabled = false
        }
    }

    @IBAction private func actionTextFieldChange(sender: UITextField) {
        if sender.text != model?.inputHandler.value {
            sender.text = model?.inputHandler.value
        }

        if let delegate = delegate {
            delegate.didChangeValue(in: self)
        }
    }
}

extension PersonalInfoCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isError = false
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let model = model else {
            return false
        }

        let shouldApply = model.inputHandler.didReceiveReplacement(string, for: range)

        if !shouldApply, textField.text != model.inputHandler.value {
            textField.text = model.inputHandler.value
        }

        return shouldApply
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            delegate.didSelectNext(on: self)
            return false
        } else {
            return true
        }
    }
}
