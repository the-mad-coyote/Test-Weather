//
//  WeatherModalView.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import SwiftUI

// MARK: - Модальное окно погоды
struct WeatherModalView: View {
    // Для объектов @Observable внутри дочерних View обертки больше не требуются
    var viewModel: WeatherViewModel
    
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
            } else if let displayTemp = viewModel.displayTemperature, let humidity = viewModel.humidity {
                VStack(spacing: 12) {
                    // Temperature Section
                    VStack(spacing: 4) {
                        Text("Текущая температура")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(displayTemp, format: .number.precision(.fractionLength(1)))\(viewModel.isCelsius ? "°C" : "°F")")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .onTapGesture {
                                viewModel.toggleTemperatureUnit()
                            }
                    }
                    
                    // Humidity Section
                    VStack(spacing: 4) {
                        Text("Влажность")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "humidity.fill") // Water drop icon
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            
                            Text("\(humidity, format: .number.precision(.fractionLength(0)))%")
                                .font(.system(size: 24, weight: .semibold))
                        }
                    }
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
