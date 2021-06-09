//
//  CamController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//

import UIKit
import AVFoundation
import SwiftyCam
import Photos
import EzPopup
import SVProgressHUD
import Pickle
import MobileCoreServices
import TLPhotoPicker

class CamController: SwiftyCamViewController {
    
    var isPushing = false
    var uploadingUser : User?
    @IBOutlet weak var captureButton    : SwiftyCamButton!
    @IBOutlet weak var galleryButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    @IBOutlet weak var closeButton      : UIButton!
    
    var selectedAssets = [PHAsset]()
    var photosArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEnabled = false
        shouldPrompToAppSettings = true
        cameraDelegate = self
        shouldUseDeviceOrientation = false
        allowAutoRotate = false
        flashMode = .off
        flashButton.setImage(UIImage(named: "flashOutline"), for: UIControl.State())
        captureButton.buttonEnabled = false
        captureButton.setImage(UIImage(named: "shutter"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedAssets.removeAll()
        self.photosArray.removeAll()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureButton.delegate = self
        
        
    }
    @IBAction func openGallery(_ sender: Any) {
        self.selectedAssets.removeAll()
//        let imagePicker = ImagePickerController()
//
//        imagePicker.settings.selection.max = 5
//        imagePicker.settings.theme.selectionStyle = .checked
//        imagePicker.settings.theme.backgroundColor = .black
//        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
//        imagePicker.settings.selection.unselectOnReachingMax = true
//        imagePicker.settings.theme.previewTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white]
//        imagePicker.settings.theme.previewSubtitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),NSAttributedString.Key.foregroundColor: UIColor.white]
//        imagePicker.settings.theme.albumTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.white]
//
//        let start = Date()
//        self.presentImagePicker(imagePicker, select: { (asset) in
//
//        }, deselect: { (asset) in
//            print("Deselected: \(asset)")
//        }, cancel: { (assets) in
//            print("Canceled with selections: \(assets)")
//        }, finish: { (assets) in
//            // User finished with these assets
//
//            self.selectedAssets = assets
//
//            self.convertAssetToImages()
//        }, completion: {
//            let finish = Date()
//            print(finish.timeIntervalSince(start))
//        })
//
//
        
//        let picker: ImagePickerController
//        picker = CarousellImagePickerController()
//        picker.delegate = self
//        present(picker, animated: true, completion: nil)
        
       
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            self?.showExceededMaximumAlert(vc: picker)
        }
        viewController.customDataSouces = CustomDataSources()
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideoRecording = false
        configure.numberOfColumn = 3
        configure.mediaType = .image
        configure.allowedLivePhotos = false
        configure.groupByFetch = .day
        viewController.configure = configure
        viewController.selectedAssets = []
        self.present(viewController, animated: true, completion: nil)
        
        
        
       /* let imagePicker = ImagePickerController(selectedAssets: self.selectedAssets)
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.max = 10
        self.presentImagePicker(imagePicker, select: { (asset) in
            //print("Selected: \(asset)")
        }, deselect: { (asset) in
            //print("Deselected: \(asset)")
        }, cancel: { (assets) in
            //print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            //print("Finished with selections: \(assets.count)")
            DispatchQueue.main.async {

            self.selectedAssets = assets
            self.convertAssetToImages()
            }

        })*/
    }
    func showExceededMaximumAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "", message: "Exceed Maximum Number Of Selection", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    func convertAssetToImages() -> Void {
        if selectedAssets.count != 0 {
            for i in 0..<selectedAssets.count {
                let imageFile = SKPHAssetToImageTool.PHAssetToImage(asset: self.selectedAssets[i])
                if imageFile != UIImage(){
                    self.photosArray.append(imageFile)
                }
                self.photosArray.removeDuplicates()
            }
            print(self.photosArray)
                self.openSelectedImages_Gallery(images: self.photosArray)
        }
    }
    
//    func getUIImage(asset: PHAsset) -> UIImage? {
//
//        var img: UIImage?
//        let manager = PHImageManager.default()
//        let options = PHImageRequestOptions()
//        options.version = .original
//        options.isSynchronous = true
//        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
//
//            if let data = data {
//                img = UIImage(data: data)
//            }
//        }
//        return img
//    }

    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        if isPushing{
            self.navigationController?.popViewController(animated: true)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("closeButtonClicked"), object: nil)
        }
    }
    
    func openSelectedImages_Gallery(images : [UIImage]){
        
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmPhotoViewController") as! ConfirmPhotoViewController
        contentVC.imageArray = images
        contentVC.delegate = self
        let width = self.view.frame.width - 60
        let height = width * 1.4
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: height)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        
//        if var topController = UIApplication.shared.windows.first!.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
            self.present(popupVC, animated: false, completion: nil)
//        }
        
//        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImageCollectionController") as? ImageCollectionController
//        vc?.imagesArray = images
//        vc?.uploadingUser = uploadingUser
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension CamController : TLPhotosPickerViewControllerDelegate{
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        var images = [UIImage]()
        for detail in withTLPHAssets{
            print(detail.fullResolutionImage)
            images.append(detail.fullResolutionImage!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // your code here
            self.openSelectedImages_Gallery(images: images)
        }
    }
}
extension CamController : ImagePickerControllerDelegate{
    func imagePickerController(_ picker: ImagePickerController, shouldLaunchCameraWithAuthorization status: AVAuthorizationStatus) -> Bool {
        return false
    }
    
    func imagePickerController(_ picker: ImagePickerController, didFinishPickingImageAssets assets: [PHAsset]) {
        debugPrint(assets)
        picker.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.selectedAssets = assets
                self.convertAssetToImages()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: ImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CamController : ConfirmPhotoViewControllerDelegate{
  
    
    func publish(images : [UIImage],index:Int) {
        if uploadingUser == nil{

        let vc = UIStoryboard.init(name: "Feature", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppUsersController") as? AppUsersController
        vc?.imageArray = images
        self.navigationController?.pushViewController(vc!, animated: true)
        }else{
            let myGroup = DispatchGroup()
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
            var lastImage = UIImage()
            for i in 0 ..< images.count{
                myGroup.enter()
                let image = images[i]
                let randomInt = Int.random(in: 1..<10)
                let nameAppend = "_\(randomInt)_\(i+1)"
                let imageName = "\(currentUser!.uid)\(Int(Date().timeIntervalSince1970))\(nameAppend).jpg"
                lastImage = image
                self.upload(image: image, imageName: imageName, selectedUser: uploadingUser!) { success in
                    print("Finished request \(i)")
                    myGroup.leave()
                }
            }
            
            myGroup.notify(queue: .main) {
                SVProgressHUD.dismiss()
                self.photosArray.removeAll()
                self.selectedAssets.removeAll()
                self.showAlert(image: lastImage)
                print("Finished all requests.")
            }
        }
    }
    func showAlert(image : UIImage){
        let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "SentDoneViewController") as! SentDoneViewController
        contentVC.delegate = self
        contentVC.fullname = uploadingUser?.fullname
        contentVC.takenPhoto = image
        let width = self.view.frame.width - 60
        let popupVC = PopupViewController(contentController: contentVC, popupWidth: width, popupHeight: 469)
        popupVC.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        popupVC.backgroundAlpha = 0.65
        popupVC.canTapOutsideToDismiss = true
        self.present(popupVC, animated: false, completion: nil)
    }
    func upload(image : UIImage,imageName : String,selectedUser : User, completion: @escaping(_ sucess: Bool) -> Void){
        APIManager.shared.uploadImage(image: image, imageName: imageName) { (success) in
            if success{
                APIManager.shared.submitRequest(owner_uid: self.uploadingUser?.uid ?? 0, imageURL: imageName, poster_uid: currentUser!.uid, isApproved: 0) { (success, fid, message) in
                    if success{
                        APIManager.shared.sendPushNotification(to: selectedUser.token, title: "Share", body: "\(currentUser!.fullname) uploaded to queue", badge_count: selectedUser.badge_count + 1)
                        APIManager.shared.updateBadgeCount(uid: selectedUser.uid, badge_count: selectedUser.badge_count + 1) { (success, message) in
                            
                        }
                    }
                    completion(success)
                }
            }else{
                self.view.makeToast("Something went wrong. Try again later.")
            }
        }
    }
    func deleted(images : [UIImage],index:Int) {
        self.photosArray.removeAll()
        self.selectedAssets.removeAll()
    }
    
    func saved(images : [UIImage],index:Int) {
        for image in images{
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        self.showToast(message: "Images saved to your photo library")
    }
}

extension CamController : SwiftyCamViewControllerDelegate,SentDoneViewControllerDelegate{
    func done() {
//        if isPushing{
//            for controller in self.navigationController!.viewControllers as Array {
//                if controller.isKind(of: ViewController.self) {
//                    self.navigationController!.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        }else{
//
//        }
    }
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
    }
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        self.openSelectedImages_Gallery(images: [photo])
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        focusAnimationAt(point)
    }
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }
    
}


extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

class SKPHAssetToImageTool: NSObject {
    @objc class func PHAssetToImage(asset:PHAsset) -> UIImage{
        var image = UIImage()
        
        // Create a new default type of image manager imageManager
        let imageManager = PHImageManager.default()
        
                 // Create a new PHImageRequestOptions object
        let imageRequestOption = PHImageRequestOptions()
        
                 // Is PHImageRequestOptions valid
        imageRequestOption.isSynchronous = true
        
                 // The compression mode of the thumbnail is set to none
        imageRequestOption.resizeMode = .none
        
                 // The quality of the thumbnail is high quality, no matter how much time it takes to load
        imageRequestOption.deliveryMode = .highQualityFormat
        
                 // Take out the picture according to the rules specified by PHImageRequestOptions
        imageManager.requestImage(for: asset, targetSize: CGSize.init(width: (UIScreen.main.bounds.size.width * 2), height: (UIScreen.main.bounds.size.height * 2)), contentMode: .aspectFill, options: imageRequestOption, resultHandler: {
            (result, _) -> Void in
            image = result!
        })
        return image
        
    }
}

private let selectionsLimit: Int = 4

internal class CarousellImagePickerController: ImagePickerController {

    internal init() {
        super.init(
            selectedAssets: [],
            configuration: CarousellTheme(),
            camera: UIImagePickerController.init
        )

        hint = {
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.maximumLineHeight = 42
            titleStyle.minimumLineHeight = 42
            titleStyle.paragraphSpacing = 4
            titleStyle.firstLineHeadIndent = 12
            titleStyle.alignment = .left

            let subtitleStyle = NSMutableParagraphStyle()
            subtitleStyle.maximumLineHeight = 12
            subtitleStyle.minimumLineHeight = 12
            subtitleStyle.paragraphSpacing = 10
            subtitleStyle.firstLineHeadIndent = 12
            subtitleStyle.alignment = .left

            let title = NSMutableAttributedString(
                string: "What are you listing?\n",
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: UIColor.black,
                    .backgroundColor: UIColor.white,
                    .paragraphStyle: titleStyle
                ]
            )

            let subtitle = NSAttributedString(
                string: "You can choose up to \(selectionsLimit) photos for your listing.\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.gray,
                    .backgroundColor: UIColor.white,
                    .paragraphStyle: subtitleStyle
                ]
            )

            title.append(subtitle)
            return title
        }()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


private struct CarousellTheme: ImagePickerConfigurable {

    let cancelBarButtonItem: UIBarButtonItem? = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)

    let doneBarButtonItem: UIBarButtonItem? = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)

    let isLiveCameraViewEnabled: Bool? = true

    // MARK: - Navigation Bar
    let navigationBarStyle: UIBarStyle? = .blackTranslucent
    let navigationBarTranslucent: Bool? = false
    let navigationBarTintColor: UIColor? = .white
    let navigationBarBackgroundColor: UIColor? = UIColor.black
    let photoAlbumsNavigationBarShadowColor: UIColor? = .clear

    // MARK: - Navigation Bar Title View
    let navigationBarTitleFont: UIFont? = AppFont.Medium.size(18)
    let navigationBarTitleTintColor: UIColor? = .white
    let navigationBarTitleHighlightedColor: UIColor? = UIColor(red: 0x9E / 255.0, green: 0x0D / 255.0, blue: 0x11 / 255.0, alpha: 1)

    // MARK: - Status Bar
    let prefersStatusBarHidden: Bool? = false
    let preferredStatusBarStyle: UIStatusBarStyle? = .lightContent
    let preferredStatusBarUpdateAnimation: UIStatusBarAnimation? = .fade

    // MARK: - Image Selections
    let imageTagTextAttributes: [NSAttributedString.Key: Any]? = nil
    let selectedImageOverlayColor: UIColor? = nil
    let allowedSelections: ImagePickerSelection? = .limit(to: 4)

    // MARK: -
    let hintTextMargin: UIEdgeInsets? = .zero



    // MARK: - Video Selections
    let videoSelectionBackgroundColor: UIColor? = nil
    let videoNormalBackgroundColor: UIColor? = nil

}

struct CustomDataSources: TLPhotopickerDataSourcesProtocol {
    func headerReferenceSize() -> CGSize {
        return CGSize(width: 320, height: 50)
    }
    
    func footerReferenceSize() -> CGSize {
        return CGSize.zero
    }
    
    func supplementIdentifier(kind: String) -> String {
        if kind == UICollectionView.elementKindSectionHeader {
            return "CustomHeaderView"
        }else {
            return "CustomFooterView"
        }
    }
    
    func registerSupplementView(collectionView: UICollectionView) {
        let headerNib = UINib(nibName: "CustomHeaderView", bundle: Bundle.main)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "CustomHeaderView")
        let footerNib = UINib(nibName: "CustomFooterView", bundle: Bundle.main)
        collectionView.register(footerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: "CustomFooterView")
    }
    
    func configure(supplement view: UICollectionReusableView, section: (title: String, assets: [TLPHAsset])) {
        if let reuseView = view as? CustomHeaderView {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "MMM dd, yyyy"
            dateFormat.locale = Locale.current
            if let date = section.assets.first?.phAsset?.creationDate {
                reuseView.titleLabel.text = dateFormat.string(from: date)
            }
        }else if let reuseView = view as? CustomFooterView {
            reuseView.titleLabel.text = "Footer"
        }
    }
}
