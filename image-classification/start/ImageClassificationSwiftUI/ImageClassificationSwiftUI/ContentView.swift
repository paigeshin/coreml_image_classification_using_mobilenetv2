//
//  ContentView.swift
//  ImageClassificationSwiftUI
//
//  Created by Mohammad Azam on 2/3/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    let photos = ["banana","tiger","bottle"]
    @State private var currentIndex: Int = 0
    @State private var label = ""
    
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
    
    var body: some View {
        VStack {
            Image(self.photos[currentIndex])
            .resizable()
                .frame(width: 200, height: 200)
            HStack {
                Button("Previous") {
                    
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .frame(width: 100)
                
                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 100)
                .background(Color.gray)
                .cornerRadius(10)
            
                
                
            }.padding()
            
            
            Button("Classify") {
                // classify the image here
                self.performImageClassification()
            }.padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            
            Text(self.label)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
