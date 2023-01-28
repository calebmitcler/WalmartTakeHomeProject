//
//  ModelManager.swift
//  WalmartTakeHome
//
//  Created by Caleb Mitcler on 1/27/23.
//

import Foundation
import MLKit
/*
 Configure the tf lite model, owns the reference to objectDetector
 */
class ModelManager {
    private var detector: ObjectDetector?
    
    convenience init(modelPath: String) {
        self.init()
        let localModel = LocalModel(path: modelPath)
        let options = CustomObjectDetectorOptions(localModel: localModel)
        options.detectorMode = .singleImage
        options.shouldEnableClassification = true
        options.shouldEnableMultipleObjects = true
        options.classificationConfidenceThreshold = NSNumber(value: 0.5)
        options.maxPerObjectLabelCount = 3
        detector = ObjectDetector.objectDetector(options: options)
    }
    
    public func scanPixelBufferForObjects(pixelBuffer: CVPixelBuffer, completion: @escaping ([Object]) -> Void) {
        if let mlImage = MLImage(pixelBuffer: pixelBuffer) {
            detector!.process(mlImage) { objects, error in
                if let objs = objects, objs.count > 0 {
                    var detectedObjects: [Object] = []
                    objs.forEach { obj in
                        obj.labels.forEach { label in
                            if label.text != "Entity" {
                                detectedObjects.append(obj)
                            }
                        }
                    }
                    completion(detectedObjects)
                }
            }
        }
    }
}

