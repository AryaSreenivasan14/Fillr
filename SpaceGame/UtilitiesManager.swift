//
//  UtilitiesManager.swift
//  SpaceGame
//
//  Created by Arya Sreenivasan on 6/4/21.
//

import UIKit
//========================================================
// ASView: Created to customize UI elements
//========================================================
@IBDesignable
class ASView: UIView {
    
    override open func draw(_ rect: CGRect) {
        setCornerRadius()
        setAsCircle()
        setBorderWidth()
        setBorderColor()
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0.0 {
        didSet {
            setCornerRadius()
        }
    }
    
    @IBInspectable
    var isCircle: Bool = false {
        didSet {
            setAsCircle()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) {
        didSet {
            setBorderColor()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0.0{
        didSet {
            setBorderWidth()
        }
    }
    
    private func setCornerRadius() {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    private func setAsCircle() {
        if (isCircle) {
            self.layer.cornerRadius = self.frame.size.height/2.0
        }
        self.clipsToBounds = true
    }
    
    private func setBorderColor() {
        self.layer.borderColor = borderColor.cgColor
    }
    
    private func setBorderWidth() {
        self.layer.borderWidth = borderWidth
    }
}
