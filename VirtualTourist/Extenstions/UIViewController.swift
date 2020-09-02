//
//  UIViewController.swift
//  VirtualTourist
//
//  Created by imac on 9/2/20.
//  Copyright © 2020 Abrar. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
