//
//  ViewController.swift
//  MLCore
//
//  Created by Dynamite Games #1 on 22/5/20.
//  Copyright © 2020 Dynamite Games #1. All rights reserved.
//

import UIKit
import AVKit//libraries needed for starting up the camera. Affoudation also works
import Vision//alternative to coreML if you only want visual ml like camrea inputs, or similar
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let captureSession = AVCaptureSession()//Tell the iPhone that capture is about to begin
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)else{
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)else{
            print("Some error has occured")
            return
        }
        
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        
        view.layer.addSublayer(previewLayer)
        
        //Access the camera's data as Image
        outputTeller.layer.zPosition = .greatestFiniteMagnitude
        confidense.layer.zPosition = .greatestFiniteMagnitude
        
        let dataOutput = AVCaptureVideoDataOutput()//You would use avcapturephotooutput if you wanted to capture a photo
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "customQueue"))
        captureSession.addOutput(dataOutput)
        
        //VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }
    
    @IBOutlet var outputTeller: UILabel!
    @IBOutlet var confidense: UILabel!
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {//dont use the did drop option, as that may cause error
        //print("frame captured \(sampleBuffer)",Date())
        guard let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)else{
            print("error")
            return}
        guard let model = try? VNCoreMLModel(for: Resnet50().model)else{
            print("error error")
            return
        }//Gp to developer.apple.com.machinelearning
        let request = VNCoreMLRequest(model: model) { (completedRequest, err) in
            //if err != nil{print(err)}
            
            
            //print("Something something")
            
            guard let results = completedRequest.results as? [VNClassificationObservation] else {return}
            
            guard let firstObservation = results.first else {return}
            
            //print(firstObservation.identifier,firstObservation.confidence)
            DispatchQueue.main.async {
                self.outputTeller.text = "\(firstObservation.identifier)"//  \(firstObservation.confidence)"
                self.confidense.text = "\(firstObservation.confidence)"
                
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }


}

