//
//  ScannerView.swift
//  DocReader
//
//  Created by Michael A on 2018-02-16.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage
import GLKit
import OpenGLES
import CoreMedia


class VNRectangleFeature: CIFeature {
    open var topLeft = CGPoint.zero
    open var topRight = CGPoint.zero
    open var bottomRight = CGPoint.zero
    open var bottomLeft = CGPoint.zero
    
    class func setValue(topLeft:CGPoint, topRight:CGPoint, bottomLeft:CGPoint, bottomRight:CGPoint) -> VNRectangleFeature {
        let obj:VNRectangleFeature = VNRectangleFeature()
        obj.topLeft = topLeft
        obj.topRight = topRight
        obj.bottomLeft = bottomLeft
        obj.bottomRight = bottomLeft
        return obj
    }
}

class ScannerView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    // MARK: UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var context: EAGLContext?
    var coreImageContext: CIContext?
    var glkView: GLKView?
    
    var _intrinsicContentSize:CGSize = CGSize(width: 0, height: 0)
    override var intrinsicContentSize: CGSize {
        get {
            //...
            return _intrinsicContentSize
        }
        set {
            _intrinsicContentSize = newValue
        }
    }
    
    // My added stuff
    func createGLKView() {
        if (context != nil) {
            return
        }
        context = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let view = GLKView(frame: bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.context = context!
        view.contentScaleFactor = 1.0
        view.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        insertSubview(view, at: 0)
        glkView = view
        coreImageContext = CIContext(eaglContext: context!, options: [kCIContextWorkingColorSpace: NSNull(), kCIContextUseSoftwareRenderer: (false)])
    }
    
    func filteredImageUsingEnhanceFilter(on image: CIImage) -> CIImage {
        return (CIFilter(name: "CIColorControls", withInputParameters: [kCIInputImageKey:image, "inputBrightness": NSNumber(value: 0.0), "inputContrast":NSNumber(value: 1.14), "inputSaturation": NSNumber(value: 0.0)])?.outputImage)!
    }
    
    func filteredImageUsingContrastFilter(on image: CIImage) -> CIImage {
        return CIFilter(name: "CIColorControls", withInputParameters: ["inputContrast": (1.1), kCIInputImageKey: image])!.outputImage!
    }
    
    func _biggestRectangle(inRectangles rectangles: [Any]) -> CIRectangleFeature? {
        if !(rectangles.count > 0) {
            return nil
        }
        var halfPerimiterValue: Float = 0
        var biggestRectangle: CIRectangleFeature = rectangles.first as! CIRectangleFeature
        for rect: CIRectangleFeature in rectangles as! [CIRectangleFeature] {
            let p1: CGPoint = rect.topLeft
            let p2: CGPoint = rect.topRight
            let width: CGFloat = CGFloat(hypotf(Float(p1.x) - Float(p2.x), Float(p1.y) - Float(p2.y)))
            let p3: CGPoint = rect.topLeft
            let p4: CGPoint = rect.bottomLeft
            let height: CGFloat = CGFloat(hypotf(Float(p3.x) - Float(p4.x), Float(p3.y) - Float(p4.y)))
            let currentHalfPerimiterValue: CGFloat = height + width
            if halfPerimiterValue < Float(currentHalfPerimiterValue) {
                halfPerimiterValue = Float(currentHalfPerimiterValue)
                biggestRectangle = rect
            }
        }
        return biggestRectangle
    }
    
    func biggestRectangle(inRectangles rectangles: [Any]) -> VNRectangleFeature? {
        let rectangleFeature: CIRectangleFeature? = _biggestRectangle(inRectangles: rectangles)
        if rectangleFeature == nil {
            return nil
        }
        // Credit: http://stackoverflow.com/a/20399468/1091044
        //         http://stackoverflow.com/questions/42474408/
        let points = [
            rectangleFeature?.topLeft,
            rectangleFeature?.topRight,
            rectangleFeature?.bottomLeft,
            rectangleFeature?.bottomRight
        ]
        
        var minimum = points[0]
        var maximum = points[0]
        for point in points {
            let minx = min((minimum?.x)!, (point?.x)!)
            let miny = min((minimum?.y)!, (point?.y)!)
            let maxx = max((maximum?.x)!, (point?.x)!)
            let maxy = max((maximum?.y)!, (point?.y)!)
            minimum?.x = minx
            minimum?.y = miny
            maximum?.x = maxx
            maximum?.y = maxy
        }
        let center = CGPoint(x: ((minimum?.x)! + (maximum?.x)!) / 2, y: ((minimum?.y)! + (maximum?.y)!) / 2)
        let angle = { (point: CGPoint) -> CGFloat in
            let theta = atan2(point.y - center.y, point.x - center.x)
            return fmod(.pi * 3.0 / 4.0 + theta, 2 * .pi)
        }
        let sortedPoints = points.sorted{angle($0!) < angle($1!)}
        let rectangleFeatureMutable = VNRectangleFeature()
        rectangleFeatureMutable.topLeft = sortedPoints[3]!
        rectangleFeatureMutable.topRight = sortedPoints[2]!
        rectangleFeatureMutable.bottomRight = sortedPoints[1]!
        rectangleFeatureMutable.bottomLeft = sortedPoints[0]!
        return rectangleFeatureMutable
    }
    
    func highAccuracyRectangleDetector() -> CIDetector? {
        var detector: CIDetector? = nil
        detector = CIDetector.init(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        return detector!
    }
    
    func drawHighlightOverlay(forPoints image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: CGFloat(1), green: CGFloat(0), blue: CGFloat(0), alpha: CGFloat(0.6)))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent", parameters: ["inputExtent": CIVector(cgRect: image.extent), "inputTopLeft": CIVector(cgPoint: topLeft), "inputTopRight": CIVector(cgPoint:topRight), "inputBottomLeft": CIVector(cgPoint:bottomLeft), "inputBottomRight": CIVector(cgPoint:bottomRight)]) 
        return overlay.composited(over: image)
    }
    
    func cropRect(forPreviewImage image: CIImage) -> CGRect {
        var cropWidth: CGFloat = image.extent.size.width
        var cropHeight: CGFloat = image.extent.size.height
        if image.extent.size.width > image.extent.size.height {
            cropWidth = image.extent.size.width
            cropHeight = cropWidth * bounds.size.height / bounds.size.width
        }
        else if image.extent.size.width < image.extent.size.height {
            cropHeight = image.extent.size.height
            cropWidth = cropHeight * bounds.size.width / bounds.size.height
        }
        return image.extent.insetBy(dx: CGFloat((image.extent.size.width - cropWidth) / 2), dy: CGFloat((image.extent.size.height - cropHeight) / 2))
    }
    
    func rectangleDetectionConfidenceHighEnough(confidence:Float) -> Bool {
        return (confidence > 1.0)
    }
    
    func correctPerspective(for image: CIImage, withFeatures rectangleFeature: VNRectangleFeature) -> CIImage {
        var rectangleCoordinates = [String: Any]()
        rectangleCoordinates["inputTopLeft"] = CIVector(cgPoint: rectangleFeature.topLeft)
        rectangleCoordinates["inputTopRight"] = CIVector(cgPoint: rectangleFeature.topRight)
        rectangleCoordinates["inputBottomLeft"] = CIVector(cgPoint: rectangleFeature.bottomLeft)
        rectangleCoordinates["inputBottomRight"] = CIVector(cgPoint: rectangleFeature.bottomRight)
        return image.applyingFilter("CIPerspectiveCorrection", parameters: rectangleCoordinates)
    }
}
