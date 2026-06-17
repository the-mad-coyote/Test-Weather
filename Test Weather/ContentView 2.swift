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
