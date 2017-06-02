//
//  UIImageExtension.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-10-15.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import Foundation
import UIKit

extension CIImage {
    
}
extension UIImage {
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let cImg = self.ciImage!
        let context = CIContext(options: nil)
        let rect = CGRect(x: pos.x, y: pos.y, width: 1 , height: 1)
        let cgImage = context.createCGImage(cImg, from: rect)!
        
        let pixelData = cgImage.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
     func extractDominantColor() -> UIColor {
        
        let sourceImage:CIImage = CIImage(image: self)!
        let rect = CGRect(x: 0, y: 0, width: self.size.width * 2 / 3, height: self.size.height * 2 / 3)
        let vector = CIVector(cgRect: rect)
        let filter = CIFilter(name: "CIAreaAverage")!
        filter.setValue(sourceImage , forKey: kCIInputImageKey)
        filter.setValue(vector , forKey: kCIInputExtentKey)
        
        let processImage = filter.outputImage
        let result = UIImage(ciImage: processImage!).getPixelColor(pos: CGPoint(x: 0, y: 0))
        
        return result;
    }

}
