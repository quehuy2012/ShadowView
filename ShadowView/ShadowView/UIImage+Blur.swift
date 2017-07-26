//
//  UIImage+Blur.swift
//  ShadowView
//
//  Created by Pierre Perrin on 25/07/2017.
//  Copyright © 2017 Pierreperrin. All rights reserved.
//

import UIKit

extension UIImage{
    
    /** Apply Gaussian Blur to UIImage
     
        - Parameter blurRadius: the input blurRadius CGFloat
        - Returns: output UIImage
    */
    private func bluredImage(blurRadius:CGFloat) -> UIImage? {
        
       return UIImageEffects.imageByApplyingBlur(to: self, withRadius: blurRadius, tintColor: nil, saturationDeltaFactor: 1, maskImage: nil)
    }
    
    /// Apply Gaussian Blur to a ciimage, and return a UIImage
    ///
    /// - Parameter ciimage: the imput CIImage
    /// - Returns: output UIImage
    func applyBlur(blurRadius:CGFloat,fastProcessing:Bool=true) -> UIImage? {
        
        guard !fastProcessing,let ciimage = self.ciImage,
        let filter = CIFilter(name: "CIGaussianBlur")else{
            return self.bluredImage(blurRadius: blurRadius)
        }
    
        filter.setValue(ciimage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKeyPath: kCIInputRadiusKey)
        
        // Due to a iOS 8 bug, we need to bridging CIContext from OC to avoid crashing
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES3)
            ??  EAGLContext(api: EAGLRenderingAPI.openGLES2)
            ??  EAGLContext(api: EAGLRenderingAPI.openGLES1)
        
        let context = eaglContext == nil ?
            CIContext.init(options: nil)
            : CIContext.init(eaglContext: eaglContext!)
        
        if let output = filter.outputImage, let cgimage = context.createCGImage(output, from: ciimage.extent) {
            return UIImage(cgImage: cgimage)
        }
        
        return self.bluredImage(blurRadius: blurRadius)
    }
    
    /// Resize the image to a centain percentage
    ///
    /// - Parameter percentage: Percentage value
    /// - Returns: UIImage(Optional)
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = size.scaled(by: percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


extension CGSize {
    
    /// Generates a new size that is this size scaled by a cerntain percentage
    ///
    /// - Parameter percentage: the percentage to scale to
    /// - Returns: a new CGSize instance by scaling self by the given percentage
    func scaled(by percentage: CGFloat) -> CGSize {
        return CGSize(width: width * percentage, height: height * percentage)
    }
    
}
