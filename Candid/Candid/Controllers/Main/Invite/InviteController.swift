//
//  InviteController.swift
//  Candid
//
//  Created by Rupinder on 01/05/21.
//


import UIKit
import SwiftyContacts
import IPImage
import SVProgressHUD

class InviteController: UIViewController ,UIGestureRecognizerDelegate{
    
    let shareText = "I'm trying to upload a picture of you but you don't have Candid yet! tell me when you get it so I can tag you - "
    let shareURL = "https://apps.apple.com/us/app/candid-photo/id1561801465?ign-mpt=uo%3D2"
    
    @IBOutlet weak var backBTN: UIButton!
    @IBOutlet weak var searchTextField: UITextField!{
        didSet{
            searchTextField.delegate = self
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Type to search", attributes: [NSAttributedString.Key.foregroundColor: mainGray])
        }
    }
    @IBOutlet weak var usersTableView: UITableView!{
        didSet{
            usersTableView.separatorStyle = .none
            usersTableView.backgroundColor = .clear
            usersTableView.dataSource = self
            usersTableView.tableFooterView = UIView()
            usersTableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        }
    }
    let cellIdentifier = "InviteCell"
    var allUsers = [User]()
    var allNumbers: [LocalContact] = []
    var refreshControl = UIRefreshControl()
    var searchedUsers = [LocalContact]()
    var isSearching = false
    var dataLoading = true
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshContacts), for: .valueChanged)
        usersTableView.addSubview(refreshControl)
        self.swipeToPop()
        backBTN.onTap {
            self.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getAll_Contacts(loader: true)

    }
  
    func swipeToPop(){
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

                // Detect swipe gesture to load next entry
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeNextEntry)))
    }
    
    @objc func swipeNextEntry(_ sender: UIPanGestureRecognizer) {
        if (sender.state == .ended) {
            let velocity = sender.velocity(in: self.view)

            if (velocity.x > 0) { // Coming from left
                self.navigationController?.popViewController(animated: true)
            } else { // Coming from right
                print("down")
            }
        }
    }
    func addField_Indicator(){
        let _activityHolder = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
        let _activityIndicator = UIActivityIndicatorView(style: .gray)
        searchTextField.rightViewMode = UITextField.ViewMode.always
        _activityIndicator.startAnimating()
        _activityIndicator.backgroundColor = UIColor.clear
        _activityIndicator.center = CGPoint(x: _activityHolder.frame.size.width/2, y: _activityHolder.frame.size.height/2)
        _activityHolder.addSubview(_activityIndicator)
        searchTextField.rightView = _activityHolder
    }
    func removeField_Indicator(){
        searchTextField.rightView = nil
    }
    @objc func refreshContacts(){
        self.getAll_Contacts(loader: false)
    }

    func getUsers(loader : Bool){
        self.allUsers.removeAll()
        self.usersTableView.reloadData {
            APIManager.shared.getServer_Users(uid: currentUser?.uid ?? 0, loader: false) { success, users, message in
                if loader{
                    SVProgressHUD.dismiss()
                }else{
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
    func getContacts(contacts : [CNContact],loader : Bool){
        DispatchQueue.main.async {
            var contactsArray = [CNContact]()
            // Do your thing here with [CNContacts] array
            let filteredContacts1 = contacts.filter { !["Spam","spam","SPAM"].contains($0.givenName) }
            contactsArray = filteredContacts1
            for index in 0...contactsArray.count - 1 {
                var nameStr = contactsArray[index].givenName
                var avatarImageView = UIImage()

                if nameStr.count == 0{
                    nameStr = "Not Available"
                }
          
                let ipimage = IPImage(text: nameStr, radius: 30, font: AppFont.SemiBold.size(24), textColor: .white, backgroundColor: UIColor(named: "MainGray"))
                avatarImageView = ipimage.generateImage()!
                
                let numPhones = contactsArray[index].phoneNumbers
                for num in numPhones{
                    let valueNum = num.value.stringValue
                    let numberStripped = valueNum.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    let obj = LocalContact(nameStr: nameStr, imageData: avatarImageView, phoneStr: numberStripped)
                    self.allNumbers.append(obj)
                }
            }
            self.getUsers(loader: loader)
        }
    }
    
    func getAll_Contacts(loader : Bool){
        self.allNumbers.removeAll()
        self.allUsers.removeAll()
        self.searchedUsers.removeAll()
        self.dataLoading = true

        if loader{
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.show()
        }else{
            self.refreshControl.beginRefreshing()
        }
        
        fetchContacts { (result) in
            switch result {
            case .success(let contacts):
                self.getContacts(contacts: contacts, loader: loader)
                // Do your thing here with [CNContacts] array
                break
            case .failure(_):
                if loader{
                    SVProgressHUD.dismiss()
                }else{
                    self.refreshControl.endRefreshing()
                }
                break
            }
        }
    }
    
    func compareAll_Numbers(){
        let selectedPeopleNumbers = allUsers.map { $0.mobileNo }
        let filteredPeople = allNumbers.filter { !selectedPeopleNumbers.contains($0.phone) }
        self.allNumbers = filteredPeople.sorted { $0.name < $1.name }
        self.dataLoading = false
        self.usersTableView.reloadData()
    }

}

extension InviteController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataLoading{
            return 0
        }else{
            if isSearching{
                return searchedUsers.count
            }else{
                return allNumbers.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InviteCell
        
        let user : LocalContact?
        if isSearching{
            user = searchedUsers[indexPath.row]
        }else{
            user = allNumbers[indexPath.row]
        }
        
        cell.nameLabel.text = user?.name
        cell.imgView.image = user?.image
        cell.inviteBTN.onTap {
            self.invitedUser(index: indexPath.row, btn: cell.inviteBTN)
        }
        return cell
    }
    func invitedUser(index : Int,btn : UIButton){
        
        guard let url = URL(string: shareURL) else {
            return
        }
        
        let items: [Any] = [shareText, url]
        let vc = VisualActivityViewController(activityItems: items, applicationActivities: nil)
        vc.previewNumberOfLines = 5
        presentActionSheet(vc, from: btn)
    }
    private func presentActionSheet(_ vc: VisualActivityViewController, from view: UIView) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceView = view
            vc.popoverPresentationController?.sourceRect = view.bounds
            vc.popoverPresentationController?.permittedArrowDirections = [.right, .left]
        }
        
        present(vc, animated: true, completion: nil)
    }
}


struct LocalContact {
    var name : String = ""
    var image = UIImage()
    var phone : String = ""
    
    init(nameStr : String,imageData : UIImage,phoneStr : String) {
        name = nameStr
        image = imageData
        phone = phoneStr
    }
}

extension InviteController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var updatedTextString : NSString = textField.text! as NSString
        updatedTextString = updatedTextString.replacingCharacters(in: range, with: string) as NSString
        
        print(updatedTextString)
        
        self.searchUser(searchText: updatedTextString as String)
      
        return true
    }
    
    func searchUser(searchText : String){
        if searchText.count == 0{
            self.isSearching = false
            self.searchedUsers.removeAll()
            self.usersTableView.reloadData()
        }else{
            self.addField_Indicator()
            searchedUsers.removeAll()
            searchedUsers = allNumbers.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
//            print("matches",matches.count)

//            searchedUsers = allNumbers.filter {$0.name."contains(searchText)}
            
            isSearching = true
            self.usersTableView.reloadData {
                print(searchText)
                self.removeField_Indicator()
            }
        }
    }
}
