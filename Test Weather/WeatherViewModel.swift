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
    @MainActor var humidity: Double?
    @MainActor var isLoading = false
    @MainActor var error: String?
    
    // Состояние для переключения единиц измерения
    @MainActor var isCelsius = true
    
    // Вычисляемое свойство для отображения температуры в текущей единице измерения
    var displayTemperature: Double? {
        guard let temp = temperature else { return nil }
        return isCelsius ? temp : (temp * 9.0 / 5.0) + 32.0
    }
    
    // Метод для переключения единиц измерения
    func toggleTemperatureUnit() {
        isCelsius.toggle()
    }
    
    @MainActor
    func fetchWeather() async {
        isLoading = true
        error = nil
        
        do {
            let weather = try await weatherService.fetchWeather()
            temperature = weather.temperature
            humidity = weather.relativeHumidity
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
