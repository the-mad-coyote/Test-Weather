//
//  WeatherViewModel.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import Foundation

// MARK: - ViewModel погоды
@Observable
class WeatherViewModel {
    private let weatherService = WeatherService()
    
    // Исправлено: изолируем свойства и функции изменения UI на Главном потоке (@MainActor).
    // Это критически важно для предотвращения падений и корректной работы Swift 6 Concurrency.
    @MainActor var temperature: Double?
    @MainActor var isLoading = false
    @MainActor var error: String?
    
    @MainActor
    func fetchWeather() async {
        isLoading = true
        error = nil
        
        do {
            let weather = try await weatherService.fetchWeather()
            temperature = weather.temperature
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
