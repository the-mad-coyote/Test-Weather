//
//  ContentView.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import SwiftUI

// MARK: - Модели данных погоды
struct WeatherResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature: Double
    
    // Кодирование с использованием CodingKeys для соответствия API Open-Meteo
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
    }
}

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

// MARK: - Модальное окно погоды
struct WeatherModalView: View {
    // Для объектов @Observable внутри дочерних View обертки больше не требуются
    var viewModel: WeatherViewModel
    
    // Исправлено: убран неиспользуемый @Binding var isPresented для чистоты кода
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Погода в Сан-Хосе")
                .font(.title3)
                .foregroundColor(.secondary)
                .padding(.top, 30)
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let temperature = viewModel.temperature {
                VStack(spacing: 12) {
                    Text("Текущая температура")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("\(temperature, format: .number.precision(.fractionLength(1)))°C")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                }
            } else if let error = viewModel.error {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Ошибка: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            // Метод .task автоматически отменит сетевой запрос, если пользователь закроет шторку раньше времени
            await viewModel.fetchWeather()
        }
    }
}

// MARK: - Основной экран
struct ContentView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)
                
                Text("Погода в Сан-Хосе")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button(action: {
                isSheetPresented = true
            }) {
                Text("Проверить погоду")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 240)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .sheet(isPresented: $isSheetPresented) {
                // Исправлено: передаем только чистый viewModel
                WeatherModalView(viewModel: viewModel)
                    .presentationDetents([.medium]) // Шторка открывается на половину экрана (улучшает UX)
                    .presentationDragIndicator(.visible) // Добавляет индикатор полоски для свайпа закрытия
            }
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    ContentView()
}
