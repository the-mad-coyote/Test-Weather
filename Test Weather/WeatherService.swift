//
//  WeatherService.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import Foundation

// MARK: - Сервис погоды
// Исправлено: убран макрос @Observable, так как сервис выполняет только сетевые запросы
class WeatherService {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let latitude = 37.3394
    private let longitude = -121.895
    
    func fetchWeather() async throws -> CurrentWeather {
        let url = URL(string: "\(baseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return response.current
    }
}
