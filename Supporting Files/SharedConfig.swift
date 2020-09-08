//
//  SharedConfig.swift
//  YEPbrowser
//
//  Created by Yogesh Padekar on 06/09/20.
//  Copyright © 2020 Yogesh. All rights reserved.
//

import UIKit

struct SettingsKeys {
    static let searchEngineUrl = "searchEngineUrl"
    static let mode = "Mode"
}

struct Colors {
    let mode = UserDefaults.standard.string(forKey: SettingsKeys.mode)
    static let lightGrayColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1.0)
    static let grayColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
    static let darkThemeLightColor = UIColor(red: 59/255.0, green: 60/255.0, blue: 54/255.0, alpha: 1.0)
    static let darkThemeDarkColor = UIColor(red: 52/255.0, green: 52/255.0, blue: 52/255.0, alpha: 1.0)
}
