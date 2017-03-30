//
//  ViewController.swift
//  sampleOpenCVRTFacialRecognition
//
//  Created by Muneharu Onoue on 2017/03/29.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var imageView: UIImageView!

    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard initCamera() else { return }
        mySession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // カメラの準備処理
    func initCamera() -> Bool {
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // 解像度の指定.
        mySession.sessionPreset = AVCaptureSessionPresetMedium
        
        
        myDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        guard myDevice != nil else { return false }
        
        // バックカメラからVideoInputを取得.
        guard let myInput = try? AVCaptureDeviceInput(device: myDevice) else { return false }
        
        // セッションに追加.
        guard mySession.canAddInput(myInput) else { return false }
        mySession.addInput(myInput)
        
        // 出力先を設定
        myOutput = AVCaptureVideoDataOutput()
        myOutput.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as NSString: Int(kCVPixelFormatType_32BGRA) ]
        
        // FPSを設定
        guard let _ = try? myDevice.lockForConfiguration() else { return false }
        myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
        myDevice.unlockForConfiguration()
        
        // デリゲートを設定
//        let queue = DispatchQueue(label: "myqueue", attributes: .concurrent)
        let queue = DispatchQueue.global()
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        // 遅れてきたフレームは無視する
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        // セッションに追加.
        guard mySession.canAddOutput(myOutput) else { return false }
        mySession.addOutput(myOutput)
        
        // カメラの向きを合わせる
        for connection in myOutput.connections {
            guard let conn = connection as? AVCaptureConnection else { continue }
            guard conn.isVideoOrientationSupported else { continue }
            conn.videoOrientation = .portrait
        }
        
        return true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // uiimageへ変換
        let image = CameraUtil.imageFromSampleBuffer(sampleBuffer: sampleBuffer)
        // 顔認識
        let faceImage = OpenCVHelper.detect(image, cascade: "haarcascade_frontalface_alt.xml")
        DispatchQueue.main.async {
            // 表示
            self.imageView.image = faceImage
        }
    }

}

