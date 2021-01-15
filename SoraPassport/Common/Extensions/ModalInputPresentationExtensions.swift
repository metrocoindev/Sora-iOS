/**
* Copyright Soramitsu Co., Ltd. All Rights Reserved.
* SPDX-License-Identifier: Apache 2.0
*/

import SoraUI

extension ModalSheetPresentationHeaderStyle {

    static var modalHeaderStyle: ModalSheetPresentationHeaderStyle {
        let indicatorColor = UIColor(white: 208.0 / 255.0, alpha: 1.0)
        return ModalSheetPresentationHeaderStyle(preferredHeight: 20.0,
                                                 backgroundColor: .white,
                                                 cornerRadius: 10.0,
                                                 indicatorVerticalOffset: 3.0,
                                                 indicatorSize: CGSize(width: 35, height: 5.0),
                                                 indicatorColor: indicatorColor)
    }
}

extension ModalSheetPresentationConfiguration {
    static var sora: ModalSheetPresentationConfiguration {
        let appearanceAnimator = BlockViewAnimator(duration: 0.25,
                                                   delay: 0.0,
                                                   options: [.curveEaseOut])
        let dismissalAnimator = BlockViewAnimator(duration: 0.25,
                                                  delay: 0.0,
                                                  options: [.curveLinear])

        let style = ModalSheetPresentationStyle(backdropColor: UIColor.black.withAlphaComponent(0.19),
                                                headerStyle: ModalSheetPresentationHeaderStyle.modalHeaderStyle)

        return ModalSheetPresentationConfiguration(contentAppearanceAnimator: appearanceAnimator,
                                                                contentDissmisalAnimator: dismissalAnimator,
                                                                style: style,
                                                                extendUnderSafeArea: true,
                                                                dismissFinishSpeedFactor: 0.6,
                                                                dismissCancelSpeedFactor: 0.6)
    }
}
