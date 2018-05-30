//
//  BanUserViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 29/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class BanUserViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var users = [Passenger]()
    var bannedUsers = [Passenger]()
    var currentUsers = [Passenger]()
    var currentBannedUsers = [Passenger]()
    var usersToBan = [Passenger]()
    var usersToUnBan = [Passenger]()
    var selectedBannedUser = 0
    var selectedNotBannedUser = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Ban Users"
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsets(top: 46, left: 0, bottom: 0, right: 0)
        
        loadUsersToTableView()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func loadUsersToTableView() {
    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { snapshot in
        print("bejott masodikba1\n")
        print(snapshot)
        for user in snapshot.children {
            let userSnap = user as! DataSnapshot
            if !userSnap.hasChild("driver") {
                if userSnap.hasChild("banned") {
                    self.bannedUsers.append(Passenger(snapshot: userSnap))
                }
                else {
                    self.users.append(Passenger(snapshot: userSnap))
                }
            }
        }
        self.currentUsers = self.users
        self.currentBannedUsers = self.bannedUsers
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        })
    }
    
    @IBAction func banTouched(_ sender: Any) {
        if selectedBannedUser != 0 {
            showAlertWithMessage(message: "You try to ban already banned users!")
            return
        }
        selectedNotBannedUser = 0
        for passenger in usersToBan {
            print(passenger.writeData())
            var i = 0
            var found = false
            var user: Passenger?
            while !found, i < users.count {
                if passenger.key == users[i].key {
                    //megkaptuk a user-t a listaban
                    found = true
                    user = users[i]
                }
                i += 1
            }
            if let user = user {
                //ha emgkaptuk a user-t, kitoroljuk a listabol es hozzaadjuk a bann-elt listahoz
                users.remove(at: (i-1))
                bannedUsers.append(user)
                
                //update-olunk az adatbazisban is
                let values = ["banned": "true"]
                Database.database().reference().child("users").child(user.key).updateChildValues(values)
            }
        }
        usersToBan = [Passenger]()
        copyUsersListToList()
        tableView.reloadData()
    }
    
    @IBAction func unBanTouched(_ sender: Any) {
        if selectedNotBannedUser != 0 {
            showAlertWithMessage(message: "You try to unban not banned users!")
            return
        }
        selectedBannedUser = 0
        for passenger in usersToUnBan {
            print(passenger.writeData())
            var i = 0
            var found = false
            var user: Passenger?
            while !found, i < bannedUsers.count {
                if passenger.key == bannedUsers[i].key {
                    //megkaptuk a user-t a listaban
                    found = true
                    user = bannedUsers[i]
                }
                i += 1
            }
            if let user = user {
                print("itt")
                //ha emgkaptuk a user-t, kitoroljuk a listabol es hozzaadjuk a bann-elt listahoz
                bannedUsers.remove(at: (i-1))
                users.append(user)
                
                //update-olunk az adatbazisban is
                Database.database().reference().child("users").child(user.key).child("banned").setValue(nil)
            }
        }
        usersToUnBan = [Passenger]()
        copyUsersListToList()
        tableView.reloadData()
        
    }
    
    func copyUsersListToList() {
        currentUsers = users
        currentBannedUsers = bannedUsers
    }
    
    func showAlertWithMessage(message: String) {
        let alertController = UIAlertController(title: "Whooops!", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK!", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension BanUserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            copyUsersListToList()
            tableView.reloadData()
            return
        }
        
        currentUsers = users.filter({ (passenger) -> Bool in
            passenger.fullName.lowercased().contains(searchText.lowercased())
        })
        currentBannedUsers = bannedUsers.filter({ (passenger) -> Bool in
            passenger.fullName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension BanUserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, currentUsers.count == 0 {
            return 1
        }
        else if section == 1, currentBannedUsers.count == 0{
            return 1
        }
        else if section == 0 {
            return currentUsers.count
        }
        else {
            return currentBannedUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userCell"
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell.textLabel?.textColor = UIColor.black
        
        cell.accessoryType = .none
        if currentUsers.count == 0, indexPath.section == 0 {
            cell.textLabel!.text = "(There is no User!)"
        }
        else if currentBannedUsers.count == 0, indexPath.section == 1 {
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel!.text = "(There is no User!)"
        }
        else {
            switch (indexPath.section){
            case 0:
                cell.textLabel!.text = currentUsers[indexPath.row].fullName
            case 1:
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel!.text = currentBannedUsers[indexPath.row].fullName
            default:
                cell.textLabel!.text = currentUsers[indexPath.row].fullName
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Banned Users"
        }
        else {
            return "Users"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if currentBannedUsers.count != 0 {
                if let cell = tableView.cellForRow(at: indexPath) {
                    if cell.accessoryType == .none {
                        cell.accessoryType = .checkmark
                        selectedBannedUser += 1
                        usersToUnBan.append(currentBannedUsers[indexPath.row])
                        print("--------- checkmarkot tettem \(indexPath.row)-hoz")
                    }
                    else {
                        cell.accessoryType = .none
                        selectedBannedUser -= 1
                        let user = currentBannedUsers[indexPath.row]
                        let index = usersToUnBan.index(of: user)
                        print("index banned: \(index)")
                        if let index = index {
                            usersToUnBan.remove(at: index)
                        }
                    }
                }
            }
        }
        else {
            if currentUsers.count != 0 {    //azer kell hogy ne lehessen ban-olni a No User message-t!
                if let cell = tableView.cellForRow(at: indexPath) {
                    if cell.accessoryType == .none {
                        cell.accessoryType = .checkmark
                        selectedNotBannedUser += 1
                        usersToBan.append(currentUsers[indexPath.row])
                    }
                    else {
                        cell.accessoryType = .none
                        selectedNotBannedUser -= 1
                        let user = currentUsers[indexPath.row]
                        let index = usersToBan.index(of: user)
                        print("index: \(index)")
                        if let index = index {
                            usersToBan.remove(at: index)
                        }
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
