import UIKit
import SoraUI

protocol SecuredPresentable: class {
    func securePresentingView(animated: Bool)
    func unsecurePresentingView()
}

private struct SecuredPresentableConstants {
    static var securityViewKey = "co.jp.sora.secure.view"
}

private let securePresentation = UUID().uuidString

extension SecuredPresentable {
    private var securityView: UIView? {
        get {
            return objc_getAssociatedObject(securePresentation,
                                            &SecuredPresentableConstants.securityViewKey)
                as? UIView
        }

        set {
            objc_setAssociatedObject(securePresentation,
                                     &SecuredPresentableConstants.securityViewKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
        }
    }

    private var presentationView: UIView? {
        return UIApplication.shared.keyWindow
    }
}

extension SecuredPresentable {
    func securePresentingView(animated: Bool) {
        guard securityView == nil, let presentationView = presentationView else {
            return
        }

        var blurStyle: UIBlurEffect.Style = .light

        if #available(iOS 10.0, *) {
            blurStyle = .regular
        }

        let blurView = UIVisualEffectView()
        blurView.effect = UIBlurEffect(style: blurStyle)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        presentationView.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: presentationView.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: presentationView.widthAnchor),
            blurView.centerXAnchor.constraint(equalTo: presentationView.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: presentationView.centerYAnchor)
            ])

        self.securityView = blurView

        if animated {
            let transitionAnimator = TransitionAnimator(type: .reveal)
            transitionAnimator.animate(view: blurView, completionBlock: nil)
        }
    }

    func unsecurePresentingView() {
        securityView?.removeFromSuperview()
        securityView = nil
    }
}
