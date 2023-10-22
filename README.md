### Used Model

- MobileNetV2.mlmodel
- image size should be 224 × 224 


### Code

```swift
extension UIImage {
    
    func resizeTo(size :CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func toBuffer() -> CVPixelBuffer? {
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
}

```


```swift

    private func performImageClassification() {
        let currentImageName = self.photos[self.currentIndex]
        
        // 1. Get Image
        guard
            let img = UIImage(named: currentImageName)
        else { return }
        
        // 2. Resize Image to 224x224
        // It's just requirements from MobileNetV2.mlmodel
        let resizedImage = img.resizeTo(size: CGSize(width: 224, height: 224))
        
        // 3. Make it buffer
        guard let buffer = resizedImage.toBuffer() else {
            return
        }

        guard let output = try? MobileNetV2.init(configuration:  MLModelConfiguration()).prediction(image: buffer) else {
            return
        }
        self.label = output.classLabel
    }

    private func performImageClassification() {
        let currentImageName = self.photos[self.currentIndex]
        
        // 1. Get Image
        guard
            let img = UIImage(named: currentImageName)
        else { return }
        
        // 2. Resize Image to 224x224
        // It's just requirements from MobileNetV2.mlmodel
        let resizedImage = img.resizeTo(size: CGSize(width: 224, height: 224))
        
        // 3. Make it buffer
        guard let buffer = resizedImage.toBuffer() else {
            return
        }

        guard let output = try? MobileNetV2.init(configuration:  MLModelConfiguration()).prediction(image: buffer) else {
            return
        }
        let results = output.classLabelProbs.sorted(by: { $0.1 > $1.1 })
        /*
         "Banana": 10.4%
         ...
         */
        let result = results.map { (key, value) in
            return "\(key) = \(value * 100)"
        }.joined(separator: "\n")
//        self.label = output.classLabel
        self.label = result
    }

```
