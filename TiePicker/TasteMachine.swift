//
//  TasteMachine.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-10-03.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import UIKit

let keyShirtColor = "shirtColor"
let keyJacketColor = "jacketColor"
let keyTieColor = "tieColor"

extension UIColor {
    func isSimilarTo(color:UIColor) -> Bool {
        let tolerance:CGFloat = 0.3
        
        let r1 = self.ciColor.red
        let g1 = self.ciColor.green
        let b1 = self.ciColor.blue
        
        let r2 = color.ciColor.red
        let g2 = color.ciColor.green
        let b2 = color.ciColor.blue
        
        return fabs(r1 - r2) < tolerance && fabs(g1 - g2) < tolerance && fabs(b1 - b2) < tolerance
    }
}

class TasteMachine {

    var shirtColor:UIColor?
    var jacketColor:UIColor?
    var tieColor:UIColor?
    
    init(input:[String:AnyObject]) {
        transformInput(input: input)
    }

    private func transformInput(input:[String:AnyObject]) {
        shirtColor = input[keyShirtColor] as? UIColor
        jacketColor = input[keyJacketColor] as? UIColor
        tieColor = input[keyTieColor] as? UIColor
    }

    public func pickTieColor() -> UIColor? {
        
        if shirtColor != nil && jacketColor != nil {
            if shirtColor!.isSimilarTo(color: UIColor.white) && jacketColor!.isSimilarTo(color: UIColor.black) {
                return UIColor.black
            }
            
            if shirtColor!.isSimilarTo(color: UIColor.white) && jacketColor!.isSimilarTo(color: UIColor.blue) {
                return UIColor.darkGray
            }
        }
        
        return nil
    }
    
  
}
