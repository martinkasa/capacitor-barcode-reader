import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onFound : ((String?) -> Void)?
    var onStopped : (() -> Void)?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let closeButton = UIButton(frame: CGRect(x: self.view.frame.size.width/2-50, y: self.view.frame.size.height - 100, width: 100, height: 50))
        closeButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        closeButton.setTitle("Close", for: .normal)
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        captureSession.startRunning()
    }
    
    @objc func stopButtonAction(sender: UIButton!) {
        stop()
        if onStopped != nil {
            onStopped!()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        stop()
        if onFound != nil {
            onFound!(code)
        }
    }
    
    func stop() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = self.view.bounds
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewLayer?.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }
}
