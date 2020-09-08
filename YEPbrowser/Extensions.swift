//
//  Extensions.swift
//  YEPbrowser
//
//  Created by Yogesh Padekar on 07/09/20.
//  Copyright © 2020 Yogesh. All rights reserved.
//

import UIKit

extension UIView {
    func screenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
