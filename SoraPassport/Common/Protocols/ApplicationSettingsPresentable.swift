import UIKit

protocol ApplicationSettingsPresentable {
    func askOpenApplicationSettins(with message: String,
                                   title: String?,
                                   from view: ControllerBackedProtocol?,
                                   locale: Locale?)
}

extension ApplicationSettingsPresentable {
    func askOpenApplicationSettins(with message: String,
                                   title: String?,
                                   from view: ControllerBackedProtocol?,
                                   locale: Locale?) {
        var currentController = view?.controller

        if currentController == nil {
            currentController = UIApplication.shared.delegate?.window??.rootViewController
        }

        guard let controller = currentController else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let closeTitle = R.string.localizable.notNow(preferredLanguages: locale?.rLanguages)
        let closeAction = UIAlertAction(title: closeTitle, style: .cancel, handler: nil)

        let settingsTitle = R.string.localizable.goSettings(preferredLanguages: locale?.rLanguages)
        let settingsAction = UIAlertAction(title: settingsTitle, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }

        alert.addAction(closeAction)
        alert.addAction(settingsAction)

        controller.present(alert, animated: true, completion: nil)
    }
}
