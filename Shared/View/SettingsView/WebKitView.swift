//
//  WebKitView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/15/22.
//

import SwiftUI
import WebKit

struct WebKitView: UIViewRepresentable {
    @ObservedObject var viewModel: SettingsViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let urlRequest = URLRequest(url: URL(string: "https://cas.rutgers.edu/login")!)
        uiView.load(urlRequest)
    }

    func makeCoordinator() -> WebKitView.Coordinator {
        return Coordinator(self, viewModel)
    }

    class Coordinator : NSObject, WKNavigationDelegate {
        @ObservedObject var viewModel: SettingsViewModel
        let parent: WebKitView
        
        init(_ parent: WebKitView, _ viewModel: SettingsViewModel) {
            self.parent = parent
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            let config = WKFindConfiguration()
            config.caseSensitive = false
            //This is the dumbest thing i've ever created and its why trust issues exist
            
            webView.find("Log In Successful", configuration: config) { result in
                if result.matchFound {
                    self.viewModel.isShowingWebsite = false
                    self.viewModel.hasVerified = true
                }
            }
        }
    }
}
