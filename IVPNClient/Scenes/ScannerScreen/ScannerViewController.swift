//
//  ScannerViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 27/03/2020.
//  Copyright © 2020 IVPN. All rights reserved.
//

import AVFoundation
import UIKit

protocol ScannerViewControllerDelegate: class {
    func qrCodeFound(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var scannerView: ScannerView!
    
    // MARK: - Properties -
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ScannerViewControllerDelegate?
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        initCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
        
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    // MARK: - Orientation -
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Private methods -
    
    private func initCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
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
        scannerView.qrView.layer.addSublayer(previewLayer)
    }
    
    private func startCaptureSession() {
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    private func stopCaptureSession() {
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func found(code: String) {
        delegate?.qrCodeFound(code: code)
    }
    
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate -
    
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
    
}
