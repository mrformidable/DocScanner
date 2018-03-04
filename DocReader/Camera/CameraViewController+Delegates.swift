//
//  CameraViewController+Delegates.swift
//  DocReader
//
//  Created by Michael A on 2018-02-17.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if isForceStop {
            return
        }
        if isStopped || isCapturing || !CMSampleBufferIsValid(sampleBuffer) {
            return
        }
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)!
        var image = CIImage(cvPixelBuffer: pixelBuffer!)
        image = scannerView.filteredImageUsingContrastFilter(on: image)
        if isEnableBorderDetection {
            if borderDetectFrame {
                borderDetectLastRectangleFeature = scannerView.biggestRectangle(inRectangles: (scannerView.highAccuracyRectangleDetector()?.features(in: image))!)
                borderDetectFrame = false
            }
            if (borderDetectLastRectangleFeature?.bottomLeft != nil) {
                imageDedectionConfidence += 0.5
                image = scannerView.drawHighlightOverlay(forPoints: image, topLeft: (borderDetectLastRectangleFeature?.topLeft)!, topRight: (borderDetectLastRectangleFeature?.topRight)!, bottomLeft: (borderDetectLastRectangleFeature?.bottomLeft)!, bottomRight: (borderDetectLastRectangleFeature?.bottomRight)!)
            }
            else {
                imageDedectionConfidence = 0.0
            }
        }
        if ((self.scannerView.context != nil) && (self.scannerView.coreImageContext != nil))
        {
            if(scannerView.context != EAGLContext.current())
            {
                EAGLContext.setCurrent(scannerView.context)
            }
            scannerView.glkView?.bindDrawable()
            DispatchQueue.main.sync { [weak self] in
                self?.scannerView.coreImageContext?.draw(image, in: scannerView.bounds, from: scannerView.cropRect(forPreviewImage: image))
            }
            
            scannerView.glkView?.display()
            
            if(scannerView.intrinsicContentSize.width != image.extent.size.width) {
                scannerView.intrinsicContentSize = image.extent.size;
                DispatchQueue.main.async { [weak self] in
                    self?.scannerView.invalidateIntrinsicContentSize()
                }
            }
            image = CIImage();
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let photoData = photo.fileDataRepresentation() {
            processImageFromCapture(imageData: photoData, completionHandler: { (images) in
                let dateSince1970 = Double(Date().timeIntervalSince1970)
                let date = Date(timeIntervalSince1970: dateSince1970)
                if self.isMultiPageEnabled {
                    let scannedDoc = ScannedDoc(image: images.first!, date: date)
                    self.scannedDocs.append(scannedDoc)
                    //self.multiPagesButton.setTitle("\(self.scannedDocs.count) Pages", for: .normal)
                    if scannedDocs.count > 1 {
                      self.performSegue(withIdentifier: SegueIdentifiers.editController.rawValue, sender: self)
                    }
    
                } else {
                    let scannedDoc = ScannedDoc(image: images.last!, date: date)
                    self.scannedDocs.append(scannedDoc)
                    self.performSegue(withIdentifier: SegueIdentifiers.editController.rawValue, sender: self)
                }
            })
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async { [weak self] in
            self?.scannerView.videoPreviewLayer.opacity = 0
            UIView.animate(withDuration: 0.25) {
                self?.scannerView.videoPreviewLayer.opacity = 1
            }
        }
    }
}

// ImageProcessing
extension CameraViewController {
    func processImageFromCapture(imageData: Data, completionHandler: ([CGImage]) -> ()) {
        var photos = [CGImage]()
        autoreleasepool {
            var enhancedImage = CIImage(data: imageData, options: [kCIImageColorSpace: NSNull()])
            enhancedImage = scannerView.filteredImageUsingContrastFilter(on: enhancedImage!)
            if (isEnableBorderDetection) && scannerView.rectangleDetectionConfidenceHighEnough(confidence: Float(self.imageDedectionConfidence)) {
                let rectangleFeature = scannerView.biggestRectangle(inRectangles: (scannerView.highAccuracyRectangleDetector()?.features(in: enhancedImage!))!)
                if rectangleFeature != nil {
                    enhancedImage = scannerView.correctPerspective(for: enhancedImage!, withFeatures: rectangleFeature!)
                }
            }
            let transform = CIFilter(name: "CIAffineTransform")
            transform?.setValue(enhancedImage, forKey: kCIInputImageKey)
            let rotation = NSValue(cgAffineTransform: CGAffineTransform(rotationAngle: -90 * (.pi / 180)))
            transform?.setValue(rotation, forKey: "inputTransform")
            enhancedImage = transform?.outputImage
            if !(enhancedImage != nil) || (enhancedImage?.extent.isEmpty)! {
                return
            }
            var ctx: CIContext? = nil
            if ctx == nil {
                ctx = CIContext(options: [kCIContextWorkingColorSpace: NSNull()])
            }
            
            var bounds: CGSize = (enhancedImage?.extent.size)!
            bounds = CGSize(width: (bounds.width / 4) * 4, height: (bounds.height / 4) * 4)
            let extent = CGRect(x: CGFloat((enhancedImage?.extent.origin.x)!), y: CGFloat((enhancedImage?.extent.origin.y)!), width: CGFloat(bounds.width), height: CGFloat(bounds.height))
            let bytesPerPixel: Int = 8
            let rowBytes: uint = uint(Float(bytesPerPixel) * Float(bounds.width))
            let totalBytes: uint = uint(Float(rowBytes) * Float(bounds.height))
            let byteBuffer = malloc(Int(totalBytes))
            let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
            ctx?.render(enhancedImage!, toBitmap: byteBuffer!, rowBytes: Int(rowBytes), bounds: extent, format: kCIFormatRGBA8, colorSpace: colorSpace)
            let bitmapContext = CGContext(data: byteBuffer, width: Int(bounds.width), height: Int(bounds.height), bitsPerComponent: bytesPerPixel, bytesPerRow: Int(rowBytes), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
            let imgRef: CGImage? = bitmapContext?.makeImage()
            free(byteBuffer)
            if let imgRef = imgRef {
                photos.append(imgRef)
            }
            completionHandler(photos)
            self.imageDedectionConfidence = 0.0
        }
    }
}














