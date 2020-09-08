//
//  SharedTextField.swift
//  YEPbrowser
//
//  Created by Yogesh Padekar on 06/09/20.
//  Copyright © 2020 Yogesh. All rights reserved.
//

import UIKit

@IBDesignable
class SharedTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset / 3)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.rightViewRect(forBounds: bounds)
		rect.origin.x -= 7
		return rect
	}
	
}
