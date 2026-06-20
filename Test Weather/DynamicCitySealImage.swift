import SwiftUI

struct DynamicCitySealImage: View {
    let cityName: String
    @State private var viewModel = DynamicCitySealViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let svgUrl = viewModel.sealUrlString {
                // ВЫЗЫВАЕМ НАШ СИСТЕМНЫЙ ВЕКТОРНЫЙ РЕНДЕРЕР
                SVGNetworkView(urlString: svgUrl)
            } else {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140, height: 140) // Чуть увеличим для сочности вектора
        .onAppear {
            viewModel.loadSeal(for: cityName)
        }
    }
}
