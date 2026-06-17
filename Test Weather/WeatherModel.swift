//
//  WeatherModel.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import Foundation

// MARK: - Модели данных погоды
struct WeatherResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature: Double
    
    // MARK: - Кодирование с использованием CodingKeys для соответствия API
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
    }
}
