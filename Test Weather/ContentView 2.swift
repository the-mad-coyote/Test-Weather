//
//  ContentView.swift
//  Test Weather
//
//  Created by Pavel Puchkov on 17.06.2026.
//

import SwiftUI

// MARK: - Основной экран
struct ContentView: View {
    @State private var viewModel = WeatherViewModel()
    @State private var isSheetPresented = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // На входе пишем полное официальное имя со штатом
            let targetLocation = "San Jose, California"

            // Магия Swift: делим строку по запятой и берем только первое слово ("San Francisco")
            let shortCityName = targetLocation.components(separatedBy: ",").first ?? targetLocation

            VStack(spacing: 16) {
                // 1. Гербу отдаем ПОЛНОЕ имя, чтобы Википедия точно нашла нужный штат
                DynamicCitySealImage(cityName: targetLocation)
                
                // 2. Пользователю показываем КРАСИВОЕ короткое имя без мусора ("Weather in San Francisco")
                Text("Weather in \(shortCityName)")
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
                WeatherModalView(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .padding(.bottom, 50)
    }
}

#Preview {
    ContentView()
}
