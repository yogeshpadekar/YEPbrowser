//
//  ViewController.swift
//  YEPbrowser
//
//  Created by Yogesh Padekar on 06/09/20.
//  Copyright © 2020 Yogesh. All rights reserved.
//

import UIKit
import Then
import SnapKit
import LUAutocompleteView

class MainViewController: UIViewController {
    
    @objc var container: UIView?
    @objc var tabContainer: TabContainerView?
    var addressBar: AddressBar!
    private let autocompleteView = LUAutocompleteView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.overrideUserInterfaceStyle == .dark ? Colors.darkThemeDarkColor : Colors.grayColor
        
        tabContainer = TabContainerView(frame: .zero).then { [unowned self] in
            $0.addTabButton?.addTarget(self, action: #selector(self.addTab), for: .touchUpInside)
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.left.equalTo(self.view)
                make.width.equalTo(self.view)
                make.height.equalTo(TabContainerView.standardHeight)
            }
        }
        
        addressBar = AddressBar(frame: .zero).then { [unowned self] in
            $0.tabContainer = self.tabContainer
            self.tabContainer?.addressBar = $0
            
            $0.setupNaviagtionActions(forTabConatiner: self.tabContainer!)
            $0.settingButton?.addTarget(self, action: #selector(self.showSettings), for: .touchUpInside)
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(self.tabContainer!.snp.bottom)
                make.left.width.equalTo(self.view)
                make.height.equalTo(AddressBar.standardHeight)
            }
        }
        
        container = UIView().then { [unowned self] in
            self.tabContainer?.containerView = $0
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(addressBar.snp.bottom)
                make.width.equalTo(self.view)
                make.bottom.equalTo(self.view)
                make.left.equalTo(self.view)
            }
        }
        
        self.view.addSubview(autocompleteView)
        autocompleteView.textField = addressBar.addressField
        autocompleteView.delegate = self
        autocompleteView.rowHeight = 45
        autocompleteView.autocompleteCell = AutocompleteTableViewCell.self
        autocompleteView.throttleTime = 0.2
        
        addressBar.addressField?.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: SettingsKeys.searchEngineUrl) == nil {
            self.showSettings()
        }
        self.setMode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabContainer?.currentTab?.webContainer?.takeScreenshot()
    }
    
    override func viewDidLayoutSubviews() {
        tabContainer?.setUpTabConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tabContainer?.setUpTabConstraints()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @objc func addTab() {
        let _ = tabContainer?.addNewTab(container: container!)
    }
    
    func setMode() {
        if UserDefaults.standard.string(forKey: SettingsKeys.mode) == nil {
            UserDefaults.standard.set(Mode.light.rawValue, forKey: SettingsKeys.mode)
        }
        let defaults = UserDefaults.standard
        self.overrideUserInterfaceStyle = defaults.string(forKey: SettingsKeys.mode) == Mode.light.rawValue ? .light : .dark
        self.container?.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle
        self.tabContainer?.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle
        self.addressBar.addressField?.textColor = .black
        self.tabContainer?.addTabButton?.tintColor = self.overrideUserInterfaceStyle == .dark ? .white : .darkGray
        self.view.backgroundColor = self.overrideUserInterfaceStyle == .dark ? Colors.darkThemeDarkColor : Colors.grayColor
        self.tabContainer?.backgroundColor = self.overrideUserInterfaceStyle == .dark ? Colors.darkThemeDarkColor : Colors.grayColor
        self.tabContainer?.updateNavButtons()
        self.tabContainer?.setTabColors()
        self.addressBar.backgroundColor = self.overrideUserInterfaceStyle == .dark ? Colors.darkThemeDarkColor : Colors.grayColor
        self.addressBar.backButton?.tintColor = self.overrideUserInterfaceStyle == .dark ? .white : .darkGray
        self.addressBar.forwardButton?.tintColor = self.overrideUserInterfaceStyle == .dark ? .white : .darkGray
        self.addressBar.settingButton?.tintColor = self.overrideUserInterfaceStyle == .dark ? .white : .darkGray
    }
    
    @objc func showSettings() {
        let vc = SettingsTableViewController(style: .grouped)
        let nav = UINavigationController(rootViewController: vc)
        
        if UIDevice().userInterfaceIdiom == .pad {
            nav.modalPresentationStyle = .formSheet
        }
        
        self.present(nav, animated: true, completion: nil)
    }
}
    
    // MARK: - Import methods

extension MainViewController: LUAutocompleteViewDelegate {
    func autocompleteView(_ autocompleteView: LUAutocompleteView, didSelect text: String) {
        addressBar.addressField?.text = text
        _ = addressBar.textFieldShouldReturn(addressBar.addressField!)
    }
}

