//
//  ConfirmPhotoViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/23.
//

import UIKit
import UPCarouselFlowLayout

protocol ConfirmPhotoViewControllerDelegate: AnyObject{
    func publish(images : [UIImage],index:Int)
    func deleted(images : [UIImage],index:Int)
    func saved(images : [UIImage],index:Int)
}

class ConfirmPhotoViewController: UIViewController {

    let cellIdentifier = "ImageCell"
    var imageArray = [UIImage]()
    @IBOutlet weak var pageControl: UIPageControl!{
        didSet{
            pageControl.pageIndicatorTintColor = .black
            pageControl.numberOfPages = 0
        }
    }

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoCollector: UICollectionView!{
        didSet{
            photoCollector.dataSource = self
            photoCollector.delegate = self
            photoCollector.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        }
    }
    fileprivate var currentPage: Int = 0 {
        didSet {
            self.pageControl.currentPage = currentPage
        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.photoCollector.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    weak var delegate: ConfirmPhotoViewControllerDelegate?
    
    var takenPhoto: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.currentPage = 0
        self.pageControl.hidesForSinglePage = true
        self.pageControl.numberOfPages = imageArray.count
        //photoImageView.image = imageArray[0]
        // Do any additional setup after loading the view.
        self.photoImageView.image = self.takenPhoto
    }
    fileprivate func setupLayout() {
        let layout = self.photoCollector.collectionViewLayout as! UPCarouselFlowLayout
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        layout.scrollDirection = .horizontal
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 0)
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        if self.imageArray.count > 0{
            self.imageArray.remove(at: self.currentPage)
            self.showToast(message: "Deleted")
            self.currentPage = 0
            self.pageControl.numberOfPages = imageArray.count
            self.photoCollector.reloadData()
            if self.imageArray.count > 0{
                self.photoCollector.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
            }
            if self.imageArray.count == 0{
                self.dismiss(animated: true) {
                    self.delegate?.deleted(images: self.imageArray, index:self.currentPage)
                }
            }
        }else{
            self.dismiss(animated: true) {
                self.delegate?.deleted(images: self.imageArray, index:self.currentPage)
            }
        }
    }
    
    @IBAction func confirmButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.publish(images: self.imageArray, index: self.currentPage)
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        let dataPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("CandidDirectory").absoluteString
//        print(dataPath)
//        if !FileManager.default.fileExists(atPath: dataPath){
//            try? FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
//        }
//
//        let fileURL = URL(fileURLWithPath: dataPath).appendingPathComponent("\(Int(Date().timeIntervalSince1970)).jpg")
//        print(fileURL)
//        let data = UIImage().jpegData(compressionQuality: 1.0)
//        do{
//            try data?.write(to: fileURL, options: .atomic)
//        }catch{
//            print(error)
//        }
        
        let img = imageArray[currentPage]
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
//        self.dismiss(animated: true) {
//            self.delegate?.saved(images: self.imageArray, index: self.currentPage)
//        }
//
    }
    
}

extension ConfirmPhotoViewController : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCell
        cell.backgroundColor = .clear
        cell.imgView.image = imageArray[indexPath.row]
        cell.imgView.contentMode = .scaleAspectFill
        
        return cell
    }

}
extension ConfirmPhotoViewController : UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.photoCollector.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
}
