//
//  DynamicCitySealViewModel.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 20.06.2026.
//

import Foundation
import Observation

@Observable
class DynamicCitySealViewModel {
    // ВАЖНО: теперь храним URL-строку вместо UIImage
    var sealUrlString: String? = nil
    var isLoading = false
    var errorMessage: String? = nil
    
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "User-Agent": "TestWeatherForecastApp/1.0 (contact: developer@example.com) SwiftEnvironment"
        ]
        configuration.timeoutIntervalForRequest = 15.0
        self.session = URLSession(configuration: configuration)
    }
    
    func loadSeal(for cityName: String) {
        isLoading = true
        errorMessage = nil
        
        // Кэшируем строку URL в UserDefaults для мгновенного доступа при повторном запуске
        if let cachedUrl = UserDefaults.standard.string(forKey: "cached_url_" + cityName) {
            print("[Кэш]: Ссылка на SVG взята из локального хранилища!")
            self.sealUrlString = cachedUrl
            self.isLoading = false
            return
        }
        
        guard let encodedCity = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            self.handleFailure(message: "Failed to encode city name")
            return
        }
        
        Task {
            print("[Сеть]: Парсинг карточки статьи для города: \(cityName)...")
            
            let urlString = "https://wikipedia.org" + "/w/api.php?action=parse&page=" + encodedCity + "&prop=text&section=0&format=json&redirects=1"
            guard let url = URL(string: urlString) else {
                await MainActor.run { self.handleFailure(message: "Invalid URL") }
                return
            }
            
            guard let (data, _) = try? await session.data(from: url),
                  let htmlText = parseHTMLText(from: data) else {
                await MainActor.run { self.handleFailure(message: "Failed to read data from Wikipedia API") }
                return
            }
            
            // Ищем исходный SVG герб (Тот самый шаг, который выдал нам чистую ссылку!)
            guard var foundUrlString = extractSealURL(from: htmlText) else {
                await MainActor.run { self.handleFailure(message: "Seal URL not found in page HTML structure") }
                return
            }
            
            // Убираем /thumb/ и обрезаем хвост разрешения, чтобы получить ссылку строго на оригинальный SVG
            foundUrlString = foundUrlString.replacingOccurrences(of: "/thumb/", with: "/")
            if let lastSlashIndex = foundUrlString.lastIndex(of: "/") {
                let trailingPart = foundUrlString[lastSlashIndex...]
                if trailingPart.contains("px-") {
                    foundUrlString = String(foundUrlString[..<lastSlashIndex])
                }
            }
            
            let finalSVGUrl = "https:" + foundUrlString
            print("[Успех]: Оригинальный SVG адрес получен: \(finalSVGUrl)")
            
            // Сохраняем строку в легкий кэш
            UserDefaults.standard.set(finalSVGUrl, forKey: "cached_url_" + cityName)
            
            await MainActor.run {
                self.sealUrlString = finalSVGUrl
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    private func handleFailure(message: String) {
        print("[Ошибка]: \(message)")
        self.errorMessage = message
        self.isLoading = false
    }
    
    private func parseHTMLText(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let parse = json["parse"] as? [String: Any],
              let textContainer = parse["text"] as? [String: Any],
              let htmlBody = textContainer["*"] as? String else {
            return nil
        }
        return htmlBody
    }
    
    private func extractSealURL(from html: String) -> String? {
        let pattern = #"//upload\.wikimedia\.org/wikipedia/commons/thumb/[^"'>]*[Ss]eal[^"'>]*\.(?:png|jpg|jpeg|svg)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
              let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }
        if let range = Range(match.range, in: html) {
            return String(html[range])
        }
        return nil
    }
}
