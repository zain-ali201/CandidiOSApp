//
//  TakePhotoViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import EzPopup
import AVFoundation

class TakePhotoViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: .video) else{
            print("unable to access back camera")
            return
        }
        
        do{
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput){
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    func setupLivePreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    @IBAction func shutterButtonClicked(_ sender: UIButton) {
        if videoPreviewLayer == nil{
            let takenPhoto = UIImage(named: "template")
            let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPhotoViewController") as! ConfirmPhotoViewController
            contentVC.takenPhoto = takenPhoto
            //contentVC.delegate = self
            let width = self.view.frame.width - 60
            let height = width * 1.4
            let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
            popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            popupVC.backgroundAlpha = 0.65
            popupVC.canTapOutsideToDismiss = true
            self.present(popupVC, animated: false, completion: nil)
            return
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func libraryButtonClicked(_ sender: UIButton) {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .photoLibrary
        pickerVC.mediaTypes = ["public.image"]
        pickerVC.delegate = self
        pickerVC.modalPresentationStyle = .fullScreen
        self.present(pickerVC, animated: true, completion: nil)
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CameraRollViewController") as! CameraRollViewController
//        vc.delegate = self
//        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("closeButtonClicked"), object: nil)
    }
}

extension TakePhotoViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else{
            return
        }
        
        let image = UIImage(data: imageData)
        let takenPhoto = image
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPhotoViewController") as! ConfirmPhotoViewController
        contentVC.takenPhoto = takenPhoto
        //contentVC.delegate = self
        let width = self.view.frame.width - 60
        let height = width * 1.4
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
}

//extension TakePhotoViewController: ConfirmPhotoViewControllerDelegate{
//    func deleted() {
//
//    }
//
//    func publish(image: UIImage) {
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as! UsersViewController
//        vc.takenPhoto = image
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    func saved() {
//        self.view.makeToast("Saved to your photo library")
//    }
//}

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        
        
        picker.dismiss(animated: true) {
            let takenPhoto = image
            let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPhotoViewController") as! ConfirmPhotoViewController
            contentVC.takenPhoto = takenPhoto
            //contentVC.delegate = self
            let width = self.view.frame.width - 60
            let height = width * 1.4
            let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
            popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            popupVC.backgroundAlpha = 0.65
            popupVC.canTapOutsideToDismiss = true
            self.present(popupVC, animated: false, completion: nil)
        }
    }
}

extension TakePhotoViewController: CameraRollViewControllerDelegate{
    func imagePicked(image: UIImage) {
        
    }
}
