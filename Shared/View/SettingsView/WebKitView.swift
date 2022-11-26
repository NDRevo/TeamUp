//
//  WebKitView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/15/22.
//

import SwiftUI
import WebKit

struct WebKitView: UIViewRepresentable {
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: SettingsViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        //Too much force unwrapping
        let urlLink = URL(string: SchoolLibrary(rawValue: playerManager.playerProfile!.inSchool)!.getVerificationLink())
        let urlRequest = URLRequest(url: urlLink!)
        uiView.load(urlRequest)
    }

    func makeCoordinator() -> WebKitView.Coordinator {
        return Coordinator(self, playerManager, viewModel)
    }

    class Coordinator : NSObject, WKNavigationDelegate {
        @ObservedObject var playerManager: PlayerManager
        @ObservedObject var viewModel: SettingsViewModel
        let parent: WebKitView
        var iRanAlready = false

        init(_ parent: WebKitView,_ playerManager: PlayerManager, _ viewModel: SettingsViewModel) {
            self.parent = parent
            self.playerManager = playerManager
            self.viewModel = viewModel
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            //This is the dumbest thing i've ever created and its why trust issues exist
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies({ cookies in
                if !self.iRanAlready {
                    for cookie in cookies {
                        if cookie.name == "TGC" {
                            self.iRanAlready = true
                            self.viewModel.isShowingWebsite = false
                            self.playerManager.studentVerifiedStatus = .isVerifiedStudent
                        }
                    }
                }
            })
        }
    }
}
