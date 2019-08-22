import Foundation
import Capacitor
import AVFoundation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */

enum BarcodeReaderError:String {
    case AccessDenied = "AccessDenied"
    case NoOpened = "NoOpened"
}

var scanner: ScannerViewController?;
var scannerView: UIView?;

@objc(BarcodeReaderPlugin)
public class BarcodeReaderPlugin: CAPPlugin {
    
    @objc func open(_ call: CAPPluginCall) {
        if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.openScanner(call)
                    }
                }
                else {
                    call.error(BarcodeReaderError.AccessDenied.rawValue)
                    return
                }
            })
        }
        else {
            DispatchQueue.main.async {
                self.openScanner(call)
            }
        }
    }
    
    @objc func close(_ call: CAPPluginCall) {
        if scannerView != nil {
            DispatchQueue.main.async {
                self.close()
                call.success([
                    "action":"closed"
                    ])
            }
        }
        else {
            call.error(BarcodeReaderError.NoOpened.rawValue)
        }
    }
    
    func openScanner(_ call: CAPPluginCall) {
        scanner = ScannerViewController();
        scannerView = scanner?.view;
        scanner!.onFound = { (code: String?) -> Void in
            DispatchQueue.main.async {
                call.success([
                    "action":"found",
                    "value": code!
                    ])
                self.close()
            }
        }
        scanner!.onStopped = {
            DispatchQueue.main.async {
                self.close()
                call.success([
                    "action":"closed"
                    ])
            }
        }
        UIView.transition(with: self.bridge.viewController.view!, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.bridge.viewController.view!.addSubview(scannerView!)
        }, completion: nil)
    }
    
    func close() {
        if scannerView != nil {
            UIView.transition(with: self.bridge.viewController.view!, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                scannerView?.removeFromSuperview()
            }, completion: nil)
            scannerView = nil
        }
    }
}
