// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import MLKit
/**
 This structure holds the display parameters for the overlay to be drawon on a detected object.
 */
struct ObjectOverlay {
  let name: String
  let borderRect: CGRect
  let nameStringSize: CGSize
  let color: UIColor
  let font: UIFont
}

/**
 This UIView draws overlay on a detected object.
 */
class OverlayView: UIView {

  var objectOverlays: [ObjectOverlay] = []
  private let cornerRadius: CGFloat = 10.0
  private let stringBgAlpha: CGFloat
    = 0.7
  private let lineWidth: CGFloat = 3
  private let stringFontColor = UIColor.white
  private let stringHorizontalSpacing: CGFloat = 13.0
  private let stringVerticalSpacing: CGFloat = 7.0

  override func draw(_ rect: CGRect) {

    // Drawing code
    for objectOverlay in objectOverlays {

      drawBorders(of: objectOverlay)
      drawBackground(of: objectOverlay)
      drawName(of: objectOverlay)
    }
  }

  /**
   This method draws the borders of the detected objects.
   */
  func drawBorders(of objectOverlay: ObjectOverlay) {

    let path = UIBezierPath(rect: objectOverlay.borderRect)
    path.lineWidth = lineWidth
    objectOverlay.color.setStroke()

    path.stroke()
  }

  /**
   This method draws the background of the string.
   */
  func drawBackground(of objectOverlay: ObjectOverlay) {

    let stringBgRect = CGRect(x: objectOverlay.borderRect.origin.x, y: objectOverlay.borderRect.origin.y , width: 2 * stringHorizontalSpacing + objectOverlay.nameStringSize.width, height: 2 * stringVerticalSpacing + objectOverlay.nameStringSize.height
    )

    let stringBgPath = UIBezierPath(rect: stringBgRect)
    objectOverlay.color.withAlphaComponent(stringBgAlpha).setFill()
    stringBgPath.fill()
  }

  /**
   This method draws the name of object overlay.
   */
  func drawName(of objectOverlay: ObjectOverlay) {

    // Draws the string.
    let stringRect = CGRect(x: objectOverlay.borderRect.origin.x + stringHorizontalSpacing, y: objectOverlay.borderRect.origin.y + stringVerticalSpacing, width: objectOverlay.nameStringSize.width, height: objectOverlay.nameStringSize.height)

    let attributedString = NSAttributedString(string: objectOverlay.name, attributes: [NSAttributedString.Key.foregroundColor : stringFontColor, NSAttributedString.Key.font : objectOverlay.font])
    attributedString.draw(in: stringRect)
  }
    /**
     This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames
     */
    func drawRects(for detectedObjects: [Object], imageSize: CGSize) {

        objectOverlays = []
        setNeedsDisplay()
        
        let edgeOffset: CGFloat = 2.0
        var objectOverlays: [ObjectOverlay] = []

        for object in detectedObjects {
            var convertedRect = object.frame.applying(
                CGAffineTransform(
                    scaleX: bounds.size.width / imageSize.width,
                    y: bounds.size.height / imageSize.height))

            if convertedRect.origin.x < 0 {
              convertedRect.origin.x = edgeOffset
            }

            if convertedRect.origin.y < 0 {
              convertedRect.origin.y = edgeOffset
            }

            if convertedRect.maxY > bounds.maxY {
              convertedRect.size.height =
                bounds.maxY - convertedRect.origin.y - edgeOffset
            }

            if convertedRect.maxX > bounds.maxX {
              convertedRect.size.width =
                bounds.maxX - convertedRect.origin.x - edgeOffset
            }

            let labelString = object.labels.first?.text ?? ""

            let size = labelString.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)])
            let objectOverlay = ObjectOverlay(
                name: object.labels.first!.text, borderRect: convertedRect, nameStringSize: size,
                color: UIColor.red,
                font: UIFont.systemFont(ofSize: 14.0, weight: .medium))

            objectOverlays.append(objectOverlay)
        }
        self.objectOverlays = objectOverlays
        setNeedsDisplay()
    }

}
