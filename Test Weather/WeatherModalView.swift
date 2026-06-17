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
