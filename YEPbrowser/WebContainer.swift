//
//  WebContainer.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

extension String {
    func isURL() -> Bool {
        if self.hasPrefix("https://") || self.hasPrefix("http://") {
            return true
        }
        return self.range(of: "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$", options: .regularExpression) != nil
    }
}

class WebContainer: UIView, WKNavigationDelegate, WKUIDelegate {
	
	@objc weak var parentView: UIView?
	@objc var webView: WKWebView?
    @objc var isObserving = false
	@objc weak var tabView: TabView?
	@objc var progressView: UIProgressView?
    var currentScreenshot: UIImage?
    
	deinit {
        if isObserving {
            webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            webView?.removeObserver(self, forKeyPath: "title")
        }
	}
	
	@objc init(parent: UIView) {
		super.init(frame: .zero)
        
		self.parentView = parent
		
        backgroundColor = .white
        
		webView = WKWebView(frame: .zero, configuration: loadConfiguration()).then { [unowned self] in
			$0.allowsLinkPreview = true
			$0.allowsBackForwardNavigationGestures = true
			$0.navigationDelegate = self
            $0.uiDelegate = self
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
                make.edges.equalTo(self)
			}
		}
        
		progressView = UIProgressView().then { [unowned self] in
			$0.isHidden = true
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.width.equalTo(self)
				make.top.equalTo(self)
				make.left.equalTo(self)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Configuration Setup
	@objc func loadConfiguration() -> WKWebViewConfiguration {
		let config = WKWebViewConfiguration()
		
		let contentController = WKUserContentController()
		config.userContentController = contentController
		config.processPool = WebViewManager.sharedProcessPool
		
		return config
	}

    // MARK: - View Managment
    
	@objc func addToView() {
		guard let _ = parentView else { return }
		
		parentView?.addSubview(self)
		self.snp.makeConstraints { (make) in
			make.edges.equalTo(parentView!)
		}
		
		if !isObserving {
			webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
			isObserving = true
		}
	}
	
	@objc func removeFromView() {
		guard let _ = parentView else { return }
        
		// Remove ourself as the observer
        if isObserving {
            webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            webView?.removeObserver(self, forKeyPath: "title")
            isObserving = false
            progressView?.setProgress(0, animated: false)
            progressView?.isHidden = true
        }
		
		self.removeFromSuperview()
	}
	
	@objc func loadQuery(string: String) {
		var urlString = string
		if !urlString.isURL() {
			let searchTerms = urlString.replacingOccurrences(of: " ", with: "+")
            let searchUrl = UserDefaults.standard.string(forKey: SettingsKeys.searchEngineUrl)!
			urlString = searchUrl + searchTerms
		} else if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
			urlString = "http://" + urlString
		}
		
		if let url = URL(string: urlString) {
			let _ = webView?.load(URLRequest(url: url))
		}
	}
    
    func takeScreenshot() {
        currentScreenshot = screenshot()
    }
	
    // MARK: - Webview Delegate
    
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressView?.isHidden = webView?.estimatedProgress == 1
			progressView?.setProgress(Float(webView!.estimatedProgress), animated: true)
            
            if webView?.estimatedProgress == 1 {
                progressView?.setProgress(0, animated: false)
            }
        } else if keyPath == "title" {
            tabView?.tabTitle = webView?.title
        }
	}
    
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		finishedLoadUpdates()
	}
    
    @objc func finishedLoadUpdates() {
        guard let webView = webView else { return }
        
        WebViewManager.shared.logPageVisit(url: webView.url?.absoluteString, pageTitle: webView.title)
        
        tabView?.tabTitle = webView.title
        
        if let tabContainer = TabContainerView.currentInstance, isObserving {
            let attrUrl = WebViewManager.shared.getColoredURL(url: webView.url)
            if attrUrl.string == "" {
                tabContainer.addressBar?.setAddressText(webView.url?.absoluteString)
            } else {
                tabContainer.addressBar?.setAttributedAddressText(attrUrl)
            }
            tabContainer.updateNavButtons()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let tabContainer = TabContainerView.currentInstance, navigationAction.targetFrame == nil {
            tabContainer.addNewTab(withRequest: navigationAction.request)
        }
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if let tabContainer = TabContainerView.currentInstance {
            _ = tabContainer.close(tab: tabView!)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error as NSError)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error as NSError)
    }
    
    func handleError(_ error: NSError) {
        print(error.localizedDescription)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
