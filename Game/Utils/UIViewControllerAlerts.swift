//
//  CustomAlert.swift
//  Game
//
//  Created by + on 2/22/1446 AH.
//

import UIKit

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Info",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))

        present(alert, animated: true, completion: nil)
    }
}
