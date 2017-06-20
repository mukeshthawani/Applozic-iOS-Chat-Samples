////
////  SelectParticipantToAddViewController.swift
////  Axiata
////
////  Created by Appsynth on 12/20/2559 BE.
////  Copyright © 2559 Appsynth. All rights reserved.
////
//
//import UIKit
//
//
//protocol SelectParticipantToAddProtocol: class {
//    func selectedParticipant(selectedList: [FriendViewModel], addedList: [FriendViewModel])
//}
//
//
//protocol InviteButtonProtocol: class {
//    func getButtonAppearance(invitedFriendCount count: Int) -> (String, backgroundColor: UIColor, isEnabled: Bool)
//}
//
//
//class SelectParticipantToAddViewController: ALBaseViewController {
//    
//    // MARK: - UI Stuff
//    @IBOutlet private var btnInvite: UIButton!
//    @IBOutlet fileprivate var tblParticipants: UITableView!
//    
//    fileprivate var tapToDismiss:UITapGestureRecognizer?
//    
//    fileprivate let searchController = UISearchController(searchResultsController: nil)
//    
//    // MARK: - Data Stuff
//    
//    fileprivate var datasource = FriendDatasource()
//    
//    fileprivate var existingFriendsInGroupStore = ParticipantStore()
//    fileprivate var newFriendsInGroupStore = ParticipantStore()
//    
//    private var friendDataService: FriendDataService?
//    
//    // MARK: - Initially Setup
//    var friendsInGroup: [FriendViewModel]?
//    weak var selectParticipantDelegate: SelectParticipantToAddProtocol?
//    
//    
//    /*
//     var alphabetDict = ["A":[],"B":[],"C":[],"D":[],"E":[],"F":[],"G":[],"H":[],"I":[],"J":[],"K":[],"L":[],"M":[],"N":[],"O":[],"P":[],"Q":[],"R":[],"S":[],"T":[],"U":[],"V":[],"W":[],"X":[],"Y":[],"Z":[],"#":[]]
//     
//     var alphabetSection : Array<String> = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
//     */
//    
//    // MARK: - Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupUI()
//        
//        if let account = AuthenticationManager.shared.account {
//            friendDataService = FriendDataService(account: account, apiService: apiClient, dbService: db)
//        }
//
//        changeNewlyInvitedContact()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchFriendList()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.isHidden = false
//    }
//    
//    // MARK: - UI Setup
//    private func setupUI() {
//        setupInviteButton()
//        setupSearchBar()
//        
//        definesPresentationContext = true
//        
//        tblParticipants.tableHeaderView = searchController.searchBar
//    }
//    
//    private func setupInviteButton() {
//        btnInvite.layer.cornerRadius = 15
//        btnInvite.clipsToBounds = true
//    }
//    
//    private func setupSearchBar() {
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation   = false
//        searchController.searchBar.delegate                 = self
//        searchController.searchBar.applySearchBarStyle()
//    }
//    
//    // MARK: - Overriden methods
//    override func backTapped() {
//        let completion = { [weak self] in
//            guard let weakSelf = self else { return }
//            _ = weakSelf.navigationController?.popViewController(animated: true)
//        }
//        if (newFriendsInGroupStore.hasAtLeastOneMember()) {
//            let alert = UIAlertController.makeCancelDiscardAlert(title: AlertInformation.discardChange.title,
//                                                                 message: AlertInformation.discardChange.message,
//                                                                 discardAction: {
//                                                                    completion()
//            })
//            present(alert, animated: true, completion: nil)
//        } else {
//            completion()
//        }
//    }
//    
//    // MARK: - API Logic
//    func fetchFriendList() {
//
//        friendDataService?.fetch(complete: { [weak self] (identitys) in
//            
//            guard let weakSelf = self else {return}
//            
//            // Get all friends
//            let friendViewModels = identitys.map(FriendViewModel.init)
//            weakSelf.datasource.update(datasource: friendViewModels, state: .full)
//            
//            // Get existing friends in this group
//            guard let friendsInGroup = weakSelf.friendsInGroup else {
//                weakSelf.tblParticipants.reloadData()
//                return
//            }
//            
//            // Traverse through all friends
//            for friendViewModel in friendViewModels {
//                Logger.debug(message: "Friend name: \(friendViewModel.friendProfileName) \(friendViewModel.friendUUID)")
//                
//                // Select existing friend, and save them to previous friend list
//                for person in friendsInGroup {
//                    
//                    guard friendViewModel.getFriendID() == person.getFriendID() else { continue }
//                
//                    friendViewModel.setIsSelected(select: true)
//                   
//                    // Keep track of existing friend
//                    guard let id = person.friendUUID else { continue }
//                    
//                    weakSelf.existingFriendsInGroupStore.storeParticipantID(idString: id)
//                }
//                
//                guard let friendUUID = friendViewModel.friendUUID else { continue }
//                
//                // Select newly selected friend before user click invite
//                if weakSelf.newFriendsInGroupStore.contain(participantID: friendUUID) {
//                    friendViewModel.setIsSelected(select: true)
//                }
//            }
//            weakSelf.tblParticipants.reloadData()
//        })
//    }
//    
//    //MARK: - Handle keyboard
//    fileprivate func hideSearchKeyboard() {
//        tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dismissSearchKeyboard))
//        view.addGestureRecognizer(tapToDismiss!)
//    }
//    
//    func dismissSearchKeyboard() {
//        if let text = searchController.searchBar.text, text.isEmpty == true {
//            searchController.isActive = false
//        }
//        searchController.searchBar.endEditing(true)
//        searchController.dismissKeyboard()
//        view.endEditing(true)
//    }
//
//    // MARK: - IBAction
//    @IBAction func invitePress(_ sender: Any) {
//        
//        var selectedFriendList = [FriendViewModel]()
//        //get all friends selected into a list
//        for fv in datasource.getDatasource(state: .full) {
//            if fv.getIsSelected() == true {
//                selectedFriendList.append(fv)
//            }
//        }
//        
//        let addedFriendList = getAddedFriend(allFriendsInGroup: selectedFriendList)
//        
//        self.selectParticipantDelegate?.selectedParticipant(selectedList: selectedFriendList, addedList: addedFriendList)
//    }
//    
//    // MARK: - Other
//    private func getNewGroupMemberCount() -> Int {
//        return self.datasource.getDatasource(state: .full).filter { (friendViewModel) -> Bool in
//            friendViewModel.getIsSelected() == true && !isInPreviousFriendGroup(fri: friendViewModel)
//        }.count
//    }
//    
//    fileprivate func changeNewlyInvitedContact() {
//        let count = getNewGroupMemberCount()
//        
//        let (title, background, isEnabled) = getButtonAppearance(invitedFriendCount: count)
//        btnInvite.isEnabled = isEnabled
//        btnInvite.backgroundColor = background
//        btnInvite.setTitle(title, for: .normal)
//    }
//
//    private func getAddedFriend(allFriendsInGroup: [FriendViewModel]) -> [FriendViewModel] {
//        var addedFriendList = [FriendViewModel]()
//        for friend in allFriendsInGroup {
//            if !isInPreviousFriendGroup(fri: friend) {
//                addedFriendList.append(friend)
//            }
//        }
//        return addedFriendList
//    }
//    
//    fileprivate func isInPreviousFriendGroup(fri: FriendViewModel) -> Bool {
//        guard let friendUUID = fri.friendUUID else { return false }
//        
//        return existingFriendsInGroupStore.contain(participantID: friendUUID)
//    }
//    
//}
//
//extension SelectParticipantToAddViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let state = DatasourceState(isInUsed: searchController.isActiveAndContainText())
//        return datasource.count(state: state)
//        
////        let array = alphabetDict[alphabetSection[section]]
////        return (array?.count)!
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "FriendContactCell", for: indexPath) as? FriendContactCell {
//            
//            let state = DatasourceState(isInUsed: searchController.isActiveAndContainText())
//            
//            guard let fri = datasource.getItem(atIndex: indexPath.row, state: state) else {
//                return UITableViewCell()
//            }
//            
//            let isExistingFriendInGroup = isInPreviousFriendGroup(fri: fri)
//            
//            cell.update(viewModel: fri, isExistingFriend: isExistingFriendInGroup)
//            
//            return cell
//        }
//        
//        return UITableViewCell()
//    }
//    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let state = DatasourceState(isInUsed: searchController.isActiveAndContainText())
//        
//        guard let fri = datasource.getItem(atIndex: indexPath.row, state: state) else { return }
//        
//        handleTappingContact(friendViewModel: fri)
//        
//        datasource.updateItem(item: fri, atIndex: indexPath.row, state: state)
//        
//        if !isInPreviousFriendGroup(fri: fri) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
//                tableView.deselectRow(at: indexPath, animated: true)
//                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
//            })
//        }
//    }
//    
//    private func keepTrackTappingNewlySelectedContact(fri: FriendViewModel) {
//        if let friendUUID = fri.friendUUID {
//            if !fri.isSelected {
//                newFriendsInGroupStore.storeParticipantID(idString: friendUUID)
//            } else {
//                newFriendsInGroupStore.removeParticipantID(idString: friendUUID)
//            }
//        }
//    }
//    
//    private func handleTappingContact(friendViewModel: FriendViewModel) {
//        if isInPreviousFriendGroup(fri: friendViewModel) { return }
//        
//        keepTrackTappingNewlySelectedContact(fri: friendViewModel)
//        
//        friendViewModel.setIsSelected(select: !friendViewModel.isSelected)
//        
//        changeNewlyInvitedContact()
//    }
//    
//    /*
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)) //set these values as necessary
//        //returnedView.backgroundColor = UIColor(red: 224.0, green: 9.0, blue: 9.0, alpha: 1)
//        
//        let label = InsetLabel(frame: CGRect(x: 0, y: 0, width: returnedView.frame.size.width, height: returnedView.frame.size.height))
//        label.text = alphabetSection[section]
//        label.backgroundColor = UIColor(netHex:0xFBE6E6)
//        returnedView.addSubview(label)
//        return returnedView
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return alphabetSection[section]
//    }
//    */
//}
//
//extension SelectParticipantToAddViewController: UISearchResultsUpdating, UISearchBarDelegate {
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchText: searchController.searchBar.text!)
//    }
//    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        hideSearchKeyboard()
//    }
//    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if let tab = tapToDismiss {
//            view.removeGestureRecognizer(tab)
//            tapToDismiss = nil
//        }
//    }
//    
//    private func filterContentForSearchText(searchText: String, scope: String = "All") {
//        let filteredList = datasource.getDatasource(state: .full).filter { friendViewModel in
//            friendViewModel.getFriendDisplayName().lowercased().contains(searchText.lowercased())
//        }
//        datasource.update(datasource: filteredList, state: .filtered)
//        self.tblParticipants.reloadData()
//    }
//}
//
//extension SelectParticipantToAddViewController: InviteButtonProtocol {
//    
//    func getButtonAppearance(invitedFriendCount count: Int) -> (String, backgroundColor: UIColor, isEnabled: Bool) {
//        let isEnabled = (count > 0) ? true: false
//        let background = (isEnabled ? UIColor.mainRed() : UIColor.disabledButton())
//        let newMember = count > 0 ? " (\(count))" : ""
//        let title = "Invite\(newMember)"
//        return (title, background, isEnabled)
//    }
//}
//
//class ParticipantStore {
//    
//    private var participants = [String]()
//    
//    func storeParticipantID(idString: String) {
//        participants.append(idString)
//    }
//    
//    func removeParticipantID(idString: String) {
//        participants.remove(object: idString)
//    }
//    
//    func contain(participantID: String) -> Bool {
//        for each in participants {
//            if participantID == each {
//                return true
//            }
//        }
//        return false
//    }
//    
//    func hasAtLeastOneMember() -> Bool {
//        return participants.count > 0
//    }
//}
//
//extension UISearchController {
//    
//    func isActiveAndContainText() -> Bool {
//        return self.isActive && self.searchBar.text != ""
//    }
//}
