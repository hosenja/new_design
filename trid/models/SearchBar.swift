//
//  SearchBar.swift
//  Snapgroup
//
//  Created by snapmac on 10/03/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import Foundation
class TintTextField: UITextField {
    
    var tintedClearImage: UIImage?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)?
        setupTintColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTintColor()
    }
    
    func setupTintColor() {
        clearButtonMode = UITextFieldViewMode.WhileEditing
        borderStyle = UITextField.BorderStyle.RoundedRect
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 1.5
        backgroundColor = UIColor.clearColor
        textColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews as! [UIView] {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.imageForState(.Highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(uiImage, tintColor)
                    }
                    button.setImage(tintedClearImage, forState: .Normal)
                    button.setImage(tintedClearImage, forState: .Highlighted)
                }
            }
        }
    }
}


func tintImage(image: UIImage, color: UIColor) -> UIImage {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Normal, alpha: 1.0)
    
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextSetBlendMode(context, CGBlendMode.SourceIn)
    CGContextSetAlpha(context, 1.0)
    
    let rect = CGRectMake(
        CGPointZero.x,
        CGPointZero.y,
        image.size.width,
        image.size.height)
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage
}
