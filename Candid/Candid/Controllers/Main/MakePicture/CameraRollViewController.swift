//
//  CameraRollViewController.swift
//  Candid
//
//  Created by khrmac on 2021/3/29.
//

import UIKit

protocol CameraRollViewControllerDelegate: class{
    func imagePicked(image: UIImage)
}

class CameraRollViewController: UIViewController {

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    weak var delegate: CameraRollViewControllerDelegate?
    
    var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let dataPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("CandidDirectory").absoluteString
        print(dataPath)
        if !FileManager.default.fileExists(atPath: dataPath){
            do{
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print(error)
            }
            
            self.imagesCollectionView.reloadData()
            return
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

}

extension CameraRollViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 5) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.imagePicked(image: UIImage())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1{
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
