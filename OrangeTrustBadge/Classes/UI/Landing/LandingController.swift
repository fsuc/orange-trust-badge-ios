/*
*
* OrangeTrustBadge
*
* File name:   LandingController.swift
* Created:     15/12/2015
* Created by:  Romain BIARD
*
* Copyright 2015 Orange
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import CoreLocation
import Contacts
import Photos
import MediaPlayer
import EventKit
import CoreBluetooth
import AVFoundation
import Speech
import UserNotifications

class LandingController: UITableViewController {
    
    static let defaultReuseIdentifier = "DefaultCell"
    
    var mainGestureRecognizer : UIGestureRecognizer?
    var usageGestureRecognizer : UIGestureRecognizer?
    @IBOutlet weak var header : Header!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = TrustBadge.shared.localizedString("landing-title")
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.clearsSelectionOnViewWillAppear = false
        }
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: LandingController.defaultReuseIdentifier)
        tableView.estimatedRowHeight = 70
        NotificationCenter.default.post(name: Notification.Name(rawValue: TrustBadge.TRUSTBADGE_ENTER), object: nil)
        
        mainGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LandingController.goToMainElements(_:)))
        usageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LandingController.goToUsageElements(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.manageLogoVisibility()
        tableView.configure(header: header, with: TrustBadge.shared.localizedString("landing-header-title"),
                            subtitle: TrustBadge.shared.localizedString("landing-header-subtitle"),
                            textColor: TrustBadge.shared.config?.headerTextColor)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TrustBadge.shared.pageDidAppear("Landing")
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.manageLogoVisibility()
        self.tableView.reloadData()
    }
    
    /**
     Hide the logo on MasterView when sizeClass != .Compact (e.g on iPad and Iphone6 Plus for instance)
     */
    func manageLogoVisibility(){
        if let header = self.header, let image = header.logo.image {
            if (self.splitViewController?.traitCollection.horizontalSizeClass != .compact) {
                header.logo.isHidden = true
                header.hiddingConstraint.constant = 0
            } else {
                header.logo.isHidden = false
                header.hiddingConstraint.constant = image.size.width
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = TrustBadge.shared.delegate,
            let should = delegate.shouldDisplayCustomViewController?(), should else {
            return 3
        }
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0 :
            if (self.splitViewController?.traitCollection.horizontalSizeClass == .compact) {
                let cell = tableView.dequeueReusableCell(withIdentifier: ElementMenuCell.reuseIdentifier, for: indexPath) as! ElementMenuCell
                cell.title.text = TrustBadge.shared.localizedString("landing-permission-title")
                cell.representedObject = TrustBadge.shared.mainElements
                cell.content.text = permissionSubtitle
                cell.overview.reloadData()
                cell.overview.removeGestureRecognizer(mainGestureRecognizer!)
                cell.overview.removeGestureRecognizer(usageGestureRecognizer!)
                cell.overview.addGestureRecognizer(mainGestureRecognizer!)
                cell.layoutIfNeeded() // needed for iOS 8 to allow multiline in "content" label
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LandingController.defaultReuseIdentifier, for: indexPath)
                cell.textLabel?.text = TrustBadge.shared.localizedString("landing-permission-title")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                return cell
            }
        case 1 :
            if (self.splitViewController?.traitCollection.horizontalSizeClass == .compact) {
                let cell = tableView.dequeueReusableCell(withIdentifier: ElementMenuCell.reuseIdentifier, for: indexPath) as! ElementMenuCell
                cell.title.text = TrustBadge.shared.localizedString("landing-usages-title")
                cell.content.text = TrustBadge.shared.localizedString("landing-usages-content")
                cell.representedObject = TrustBadge.shared.usageElements
                cell.overview.reloadData()
                cell.overview.removeGestureRecognizer(mainGestureRecognizer!)
                cell.overview.removeGestureRecognizer(usageGestureRecognizer!)
                cell.overview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LandingController.goToUsageElements(_:))))
                cell.layoutIfNeeded() // needed for iOS 8 to allow multiline in "content" label
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LandingController.defaultReuseIdentifier, for: indexPath)
                cell.textLabel?.text = TrustBadge.shared.localizedString("landing-usages-title")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                return cell
            }
        case 2 :
            if (self.splitViewController?.traitCollection.horizontalSizeClass == .compact) {
                let cell = tableView.dequeueReusableCell(withIdentifier: TermsMenuCell.reuseIdentifier, for: indexPath) as! TermsMenuCell
                cell.title.text = TrustBadge.shared.localizedString("landing-terms-title")
                cell.content.text = TrustBadge.shared.localizedString("landing-terms-content")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LandingController.defaultReuseIdentifier, for: indexPath)
                cell.textLabel?.text = TrustBadge.shared.localizedString("landing-terms-title")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                return cell
            }
            
        default :
            if (self.splitViewController?.traitCollection.horizontalSizeClass == .compact) {
                let cell = tableView.dequeueReusableCell(withIdentifier: CustomMenuCell.reuseIdentifier, for: indexPath) as! CustomMenuCell
                cell.title.text = TrustBadge.shared.localizedString("landing-custom-title")
                cell.content.text = TrustBadge.shared.localizedString("landing-custom-content")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LandingController.defaultReuseIdentifier, for: indexPath)
                cell.textLabel?.text = TrustBadge.shared.localizedString("landing-custom-title")
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.splitViewController?.traitCollection.horizontalSizeClass == .compact) {
            return UITableViewAutomaticDimension
        } else {
            return 55
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegue(withIdentifier: "Permissions", sender: self)
        case 1 :
            self.performSegue(withIdentifier: "Usages", sender: self)
        case 2 :
            self.performSegue(withIdentifier: "Terms", sender: self)
        default :
            if let delegate = TrustBadge.shared.delegate,
                let viewController = delegate.viewController?(at: indexPath) {
                self.show(viewController, sender: self)
            }
            break
        }
    }
    
    // MARK
    
    @IBAction func dismissModal(){
        self.splitViewController?.preferredDisplayMode = .primaryHidden
        self.splitViewController?.dismiss(animated: true, completion: { () -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: TrustBadge.TRUSTBADGE_LEAVE), object: nil)
        })
    }
    
    @objc func goToMainElements(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.performSegue(withIdentifier: "Permissions", sender: self)
        }
    }
    
    @objc func goToUsageElements(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.performSegue(withIdentifier: "Usages", sender: self)
        }
    }
    
    private var permissionSubtitle: String {
        guard !TrustBadge.shared.mainElements.isEmpty else { return TrustBadge.shared.localizedString("landing-permission-unrequested") }
        
        var subtitleKey = "landing-permission-denied"
        let firstRequestedDevicePermission =
            TrustBadge.shared.mainElements
                .compactMap { return $0 as? PreDefinedElement }
                .filter { $0.type.isDevicePermission }
                .first { $0.isPermissionRequested }
        
        if let _ = firstRequestedDevicePermission {
            subtitleKey = "landing-permission-content"
        }
        return TrustBadge.shared.localizedString(subtitleKey)
    }
    
}

extension PreDefinedElement {
    var isPermissionRequested: Bool {
        switch type {
        case .location:
            return CLLocationManager.authorizationStatus() != .notDetermined
        
        case .contacts:
            return CNContactStore.authorizationStatus(for: CNEntityType.contacts) != .notDetermined
        
        case .photoLibrary:
            return PHPhotoLibrary.authorizationStatus() != .notDetermined
        
        case .media:
            if #available(iOS 9.3, *) {
                return MPMediaLibrary.authorizationStatus() != .notDetermined
            } else {
                return false
            }
        
        case .calendar:
            return EKEventStore.authorizationStatus(for: EKEntityType.event) != .notDetermined
        
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .notDetermined
        
        case .reminders:
            return EKEventStore.authorizationStatus(for: EKEntityType.reminder) != .notDetermined
        
        case .bluetoothSharing:
            return CBPeripheralManager.authorizationStatus() != .notDetermined
        
        case .microphone:
            return AVAudioSession.sharedInstance().recordPermission() != .undetermined
        
        case .speechRecognition:
            if #available(iOS 10.0, *) {
                return SFSpeechRecognizer.authorizationStatus() != .notDetermined
            } else {
                return false
            }

        default:
            return statusClosure()
            break
        }
        return true
    }
}
