//
//  SVGNetworkView.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 20.06.2026.
//

import SwiftUI
import WebKit

struct SVGNetworkView: View {
    let urlString: String
    
    var body: some View {
        SVGWebViewRepresentable(urlString: urlString)
            .background(Color.clear)
    }
}

// Мост между UIKit WebKit и SwiftUI
struct SVGWebViewRepresentable: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false // Делаем подложку прозрачной
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Отключаем скролл, герб зафиксирован
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        
        // Формируем HTML-обертку, чтобы SVG идеально масштабировался под размеры frame во View
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
        body, html { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; background-color: transparent; }
        img { width: 100%; height: 100%; object-fit: contain; }
        </style>
        </head>
        <body>
        <img src="\(url.absoluteString)">
        </body>
        </html>
        """
        
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

