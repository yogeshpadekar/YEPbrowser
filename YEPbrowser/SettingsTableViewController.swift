//
//  SettingsTableViewController.swift
//  YEPbrowser
//
//  Created by Yogesh Padekar on 06/09/20.
//  Copyright © 2020 Yogesh. All rights reserved.
//

import UIKit
import WebKit

enum SearchEngineTitles: String {
    case google = "Google"
    case duckduckgo = "DuckDuckGo"
    case bing = "Bing"
    case yahoo = "Yahoo"
    
    static let allValues: [SearchEngineTitles] = [.google, .duckduckgo, .bing, .yahoo]
    
    static func getUrl(title: SearchEngineTitles) -> String {
        switch title {
        case .google:
            return "https://google.com/search?q="
        case .duckduckgo:
            return "https://duckduckgo.com/?q="
        case .bing:
            return "https://bing.com/search?q="
        case .yahoo:
            return "https://search.yahoo.com/search?p="
        }
    }
}

enum Mode: String {
    case dark = "Dark"
    case light = "Light"
    static let modeValues = [dark, light]
}

class SettingsTableViewController: UITableViewController {
    
    static let identifier = "SettingsIdentifier"
    
    lazy var currentSearchUrl = UserDefaults.standard.string(forKey: SettingsKeys.searchEngineUrl)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsTableViewController.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func done() {
        //If search engine isn't selected then show an alert to select it
        guard let _ = UserDefaults.standard.string(forKey: SettingsKeys.searchEngineUrl) else {
            let alertSearchEngine = UIAlertController(title: "", message: "Please select search engine", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
            }
            alertSearchEngine.addAction(okAction)
            self.present(alertSearchEngine, animated: true, completion: nil)
            return
        }
        
        if let vcMain = self.presentingViewController as? MainViewController {
            vcMain.setMode()
        }
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        return SearchEngineTitles.allValues.count
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
        return "Search Engine"
        }
        return "Mode"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.identifier, for: indexPath)
        cell.textLabel?.textColor = .black
        
        cell.selectionStyle = .default
        
        if indexPath.section == 0 {
            let engineTitle = SearchEngineTitles.allValues[indexPath.row]
            if SearchEngineTitles.getUrl(title: engineTitle) == currentSearchUrl {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.text = engineTitle.rawValue
        } else {
            cell.textLabel?.text = Mode.modeValues[indexPath.row].rawValue
            if UserDefaults.standard.string(forKey: SettingsKeys.mode) == cell.textLabel?.text {
              cell.accessoryType = .checkmark
            } else {
              cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            didSelectSearchEngine(withRowIndex: indexPath.row)
        } else {
            didSelectMode(withRowIndex: indexPath.row)
        }
    }

    // MARK: - Search Section
    
    func didSelectSearchEngine(withRowIndex rowIndex: Int) {
        let searchUrl = SearchEngineTitles.getUrl(title: SearchEngineTitles.allValues[rowIndex])
        UserDefaults.standard.set(searchUrl, forKey: SettingsKeys.searchEngineUrl)
        UserDefaults.standard.synchronize()
        currentSearchUrl = searchUrl
        tableView.reloadData()
    }
    
    func didSelectMode(withRowIndex rowIndex: Int) {
        UserDefaults.standard.set(Mode.modeValues[rowIndex].rawValue, forKey: SettingsKeys.mode)
        UserDefaults.standard.synchronize()
        tableView.reloadData()
    }
}
