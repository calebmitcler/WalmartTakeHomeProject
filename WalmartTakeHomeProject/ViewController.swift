//
//  ViewController.swift
//  WalmartTakeHome
//
//  Created by Caleb Mitcler on 1/26/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var previewView: PreviewView!
    private lazy var cameraFeedManager = CameraFeedManager(previewView: previewView)
    private var modelManager: ModelManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraFeedManager.delegate = self
        if let path = Bundle.main.path(forResource: "cereal_model", ofType: "tflite") {
            self.modelManager = ModelManager(modelPath: path)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
    
}

extension ViewController: CameraFeedManagerDelegate {
    func didOutput(pixelBuffer: CVPixelBuffer) {
        modelManager?.scanPixelBufferForObjects(pixelBuffer: pixelBuffer, completion: { detectedObjects in
            let imageSize = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer)).size
            self.overlayView.drawRects(for: detectedObjects, imageSize: pixelBuffer.getSize())
        })
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alert = UIAlertController(title: "Camera Permission", message: "This app requires camera permission. Please go to settings to give permission.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func presentVideoConfigurationErrorAlert() {
        let alert = UIAlertController(title: "Camera Config Error", message: "There was an issue starting the camera.", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            alert.dismiss(animated: true, completion: {
                self.cameraFeedManager.checkCameraConfigurationAndStartSession()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func sessionRunTimeErrorOccurred() {
        let alert = UIAlertController(title: "Session Error", message: "There was an error with the camera session.", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            alert.dismiss(animated: true, completion: {
                self.cameraFeedManager.checkCameraConfigurationAndStartSession()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        self.cameraFeedManager.stopSession()
    }
    
    func sessionInterruptionEnded() {
        self.cameraFeedManager.checkCameraConfigurationAndStartSession()
    }
}
extension CVPixelBuffer {
    func getSize() -> CGSize {
        return CGSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
    }
}

