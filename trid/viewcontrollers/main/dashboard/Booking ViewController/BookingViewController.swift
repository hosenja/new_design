//
//  BookingViewController.swift
//  Snapgroup
//
//  Created by snapmac on 31/01/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import WebKit


class BookingViewController: DashboardBaseViewController, UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate, UIScrollViewDelegate {

    @IBOutlet weak var topConstrate: NSLayoutConstraint!
    
    @IBOutlet weak var bootomConstarate: NSLayoutConstraint!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var webview : WKWebView?
    @IBOutlet weak var coverWebView: UIView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tabbar.isHidden = true
        print("Im in payment view controler \(String(describing: AppState.currentGroup?.group_settings?.payments_url)) \n")
     
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        webview = WKWebView(frame: .zero, configuration: configuration)
        header.makeHeaderBooking()
       
        webview?.scrollView.delegate = self
        progress.startAnimating()
        webview?.frame = CGRect(x: 0, y: 0, width: self.coverWebView.frame.width, height: self.coverWebView.frame.height)
        webview?.frame = self.coverWebView.bounds
        //   self.coverWebView = webview!
        // self.coverWebView.frame = (webview?.frame)!
        var urlString: String = "https://www.snapgroup.co/"
        if verifyUrl(urlString: AppState.currentGroup?.group_settings?.payments_url != nil ? (AppState.currentGroup?.group_settings?.payments_url)! : "") {
            urlString = (AppState.currentGroup?.group_settings?.payments_url)!
        }
      //  urlString = "https://account.snapgroup.co/booking/728"

        print("Url payment \(urlString)")
        
        let urlss = encodedUrl(from: urlString)
        self.webview?.load(URLRequest(url: urlss!))
        self.webview?.navigationDelegate = self
        self.coverWebView.addSubview(self.webview!)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("header.frame.height \(header.frame.height)")
    
        
        topConstrate.constant = header.frame.height
    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func encodedUrl(from string: String) -> URL? {
        // Remove preexisting encoding
        guard let decodedString = string.removingPercentEncoding,
            // Reencode, to revert decoding while encoding missed characters
            let percentEncodedString = decodedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                // Coding failed
                return nil
        }
        // Create URL from encoded string, or nil if failed
        return URL(string: percentEncodedString)
    }
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked
        {
            if let url_text = request.url?.absoluteURL {
                print("linkClicked:", url_text)
            }
        }
        return true;
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webView.frame = self.coverWebView.frame
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = self.coverWebView.frame
        progress.hide()
        progress.isHidden = true
        
        webView.frame.size.height = 1
        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("yessss \(webView.tag)")
        self.progress.hide()
        self.progress.isHidden = true
        webView.frame = self.coverWebView.frame
        
        //        webView.frame.size = webView.sizeThatFits(CGSize.zero)
        
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation:
        WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.frame = self.coverWebView.bounds
        self.webview? = WKWebView(frame: self.coverWebView.bounds, configuration: WKWebViewConfiguration())
        
    }
    
}
