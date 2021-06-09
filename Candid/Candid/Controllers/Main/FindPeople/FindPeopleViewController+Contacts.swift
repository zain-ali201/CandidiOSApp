//
//  FindPeopleViewController+Ext.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//


import UIKit
import SwiftyContacts
import SVProgressHUD
import Kingfisher

extension FindPeopleViewController{
    func compareAll_Numbers(){
        var tempNumbers = self.allNumbers
        if tempNumbers.count > 0{
            for _ in 0...tempNumbers.count - 1 {
                let num = tempNumbers[0]
                print(num)
                let filteredArray = allUsers.filter { $0.mobileNo == num }
                if filteredArray.count > 0{
                    suggestedUsers.append(filteredArray[0])
                }
                tempNumbers.remove(at: 0)
            }
        }
        let selectedPeopleIDs = suggestedUsers.map { $0.uid }
        let filteredPeople = allUsers.filter { !selectedPeopleIDs.contains($0.uid) }
        self.otherUsers = filteredPeople.sorted { $0.fullname < $1.fullname }
        self.usersTableView.reloadData()
    }
    func getUsers(loader : Bool){
        self.allUsers.removeAll()
        self.suggestedUsers.removeAll()
        self.otherUsers.removeAll()
        self.searchActive = false
        self.searchedUsers .removeAll()
        self.usersTableView.reloadData {
            APIManager.shared.getServer_Users(uid: currentUser?.uid ?? 0, loader: loader) { success, users, message in
                if !loader{
                    self.refreshControl.endRefreshing()
                }
                let selectedPeopleIDs = users.map { $0.mobileNo }
                print(selectedPeopleIDs)
                self.allUsers = users
                self.compareAll_Numbers()
            }
        }
    }
    func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    func getAll_Contacts(loader : Bool){
        fetchContactsOnBackgroundThread(completionHandler: { (result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let contacts):
                    var contactsArray = [CNContact]()
                    // Do your thing here with [CNContacts] array
                    let filteredContacts1 = contacts.filter { !["Spam","spam","SPAM"].contains($0.givenName) }
                    contactsArray = filteredContacts1
                    for index in 0...contactsArray.count - 1 {
                        let numPhones = contactsArray[index].phoneNumbers
                        for num in numPhones{
                            let valueNum = num.value.stringValue
                            let numberStripped = valueNum.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                            self.allNumbers.append(numberStripped)
                        }
                    }
                    self.allNumbers = self.unique(source: self.allNumbers)
                    self.getUsers(loader: loader)
                    break
                case .failure(let error):
                    print(error)
                    self.getUsers(loader: loader)
                    break
                }
            }
        })
    }
}
extension UIImageView {
    func download(url: String?, rounded: Bool = true) {
        guard let _url = url else {
            return
        }
        if rounded {
            let processor = ResizingImageProcessor(referenceSize: (self.image?.size)!) |> RoundCornerImageProcessor(cornerRadius: self.frame.size.width / 2)
            self.kf.setImage(with: URL(string: _url), placeholder: UIImage(named: "avatar"), options: [.processor(processor)])
        } else {
            self.kf.setImage(with: URL(string: _url))
        }
    }
}
