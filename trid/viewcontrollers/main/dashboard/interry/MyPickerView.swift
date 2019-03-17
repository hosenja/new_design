//
//  MyPickerView.swift
//  Snapgroup
//
//  Created by snapmac on 14/01/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import Foundation
class MyPickerView: UIPickerView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.borderWidth = 0 // Main view rounded border
        
        // Component borders
        self.subviews.forEach {
            $0.layer.borderWidth = 0
            $0.isHidden = $0.frame.height <= 1.0
        }
    }
    override func rowSize(forComponent component: Int) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
}
