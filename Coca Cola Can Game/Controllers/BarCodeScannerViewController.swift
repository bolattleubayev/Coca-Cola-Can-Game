//
//  BarCodeScannerViewController.swift
//
//  Created by macbook on 5/8/20.
//  Copyright © 2020 assylkhantleubayev. All rights reserved.
//

import UIKit
import AVFoundation

class BarCodeScannerViewController: UIViewController {
    
    var scannedNumber: Int = 0
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Constants.modifyNavigationController(navigationController: navigationController)
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,
                                                        AVMetadataObject.ObjectType.upce,
                                                        AVMetadataObject.ObjectType.code39,
                                                        AVMetadataObject.ObjectType.code39Mod43,
                                                        AVMetadataObject.ObjectType.code93,
                                                        AVMetadataObject.ObjectType.code128,
                                                        AVMetadataObject.ObjectType.ean8,
                                                        AVMetadataObject.ObjectType.ean13,
                                                        AVMetadataObject.ObjectType.aztec,
                                                        AVMetadataObject.ObjectType.pdf417,
                                                        AVMetadataObject.ObjectType.itf14,
                                                        AVMetadataObject.ObjectType.interleaved2of5,
                                                        AVMetadataObject.ObjectType.dataMatrix]
            
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture
            captureSession.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubviewToFront(messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code
            barCodeFrameView = UIView()
            
            if let barCodeFrameView = barCodeFrameView {
                barCodeFrameView.layer.borderColor = UIColor.green.cgColor
                barCodeFrameView.layer.borderWidth = 2
                view.addSubview(barCodeFrameView)
                view.bringSubviewToFront(barCodeFrameView)
            }
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension BarCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if metadataObjects array is not nil and contains at least one object
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "Нет штрих кода"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        let objectTypes = [AVMetadataObject.ObjectType.qr,
                        AVMetadataObject.ObjectType.upce,
                        AVMetadataObject.ObjectType.code39,
                        AVMetadataObject.ObjectType.code39Mod43,
                        AVMetadataObject.ObjectType.code93,
                        AVMetadataObject.ObjectType.code128,
                        AVMetadataObject.ObjectType.ean8,
                        AVMetadataObject.ObjectType.ean13,
                        AVMetadataObject.ObjectType.aztec,
                        AVMetadataObject.ObjectType.pdf417,
                        AVMetadataObject.ObjectType.itf14,
                        AVMetadataObject.ObjectType.interleaved2of5,
                        AVMetadataObject.ObjectType.dataMatrix]
        
        if objectTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                
                if let integerCode = Int(metadataObj.stringValue!) {
                    scannedNumber = integerCode
                }
            }
        }
    }
    
}

