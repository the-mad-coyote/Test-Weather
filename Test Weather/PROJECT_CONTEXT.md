# Test Weather — Project Context

## 1. Project Purpose
- **What it does:** Displays current weather (temperature, humidity) for a specific city alongside a dynamically fetched city seal/coat of arms rendered as SVG.
- **Target user:** General users checking local weather with a visual city identifier.
- **Primary use cases:**
  - View city seal on the main screen.
  - Tap a button to fetch and display current weather in a modal sheet.
  - Toggle between Celsius and Fahrenheit.

## 2. Architecture Overview
- **Pattern:** MVVM (Model-View-ViewModel).
- **Platform:** iOS, SwiftUI, iOS 17+ (uses `@Observable` macro).
- **Major modules:**
  - **Views:** `ContentView`, `WeatherModalView`, `DynamicCitySealImage`, `SVGNetworkView`.
  - **ViewModels:** `WeatherViewModel`, `DynamicCitySealViewModel`.
  - **Models:** `WeatherResponse`, `CurrentWeather`.
  - **Services:** `WeatherService` (Open-Meteo API), `ImageCacheManager` (file-based cache).
  - **Infrastructure:** `SVGWebViewRepresentable` (UIKit bridge for WKWebView).

## 3. Core Data Models
- **`WeatherResponse`** — Top-level JSON wrapper from Open-Meteo API.
- **`CurrentWeather`** — Contains `temperature` and `relativeHumidity`; uses `CodingKeys` to map API field names.
- No persistent domain models; data is transient per session.

## 4. UI Structure
- **Entry point:** `Test_WeatherApp` → `ContentView`.
- **`ContentView`:**
  - Displays a dynamically loaded city seal (`DynamicCitySealImage`).
  - Shows a city name label.
  - Presents a "Check Weather" button that opens a modal sheet.
- **`WeatherModalView`:**
  - Half-sheet modal (`.medium` detent).
  - Shows loading state, temperature/humidity, or error.
  - Temperature is tappable to toggle °C/°F.
- **Navigation:** Single root view → modal sheet presentation.

## 5. Services and Infrastructure
- **Networking:**
  - `WeatherService` — Fetches weather from Open-Meteo API (`api.open-meteo.com`). Uses `URLSession.shared`.
  - `DynamicCitySealViewModel` — Fetches Wikipedia page HTML, parses it with regex to extract a Wikimedia Commons SVG URL. Uses a custom `URLSession` with a custom User-Agent header and 15s timeout.
- **Persistence:**
  - `UserDefaults` — Caches the last fetched SVG URL string per city name.
  - `ImageCacheManager` — File-based disk cache in the app's Caches directory; stores images keyed by hash. Thread-safe via `NSLock`.
- **External integrations:**
  - Open-Meteo API (weather data, no auth required).
  - Wikipedia Parse API (HTML scraping for city seal URLs).
  - Wikimedia Commons (SVG image hosting).
- **Background tasks:** None implemented.

## 6. Component Dependencies
- `ContentView` owns `WeatherViewModel` and presents `WeatherModalView`.
- `ContentView` embeds `DynamicCitySealImage`, which owns `DynamicCitySealViewModel`.
- `DynamicCitySealImage` renders via `SVGNetworkView` → `SVGWebViewRepresentable` (WKWebView).
- `WeatherModalView` receives `WeatherViewModel` as a parameter.
- `WeatherViewModel` depends on `WeatherService`.
- `WeatherService` depends on `WeatherResponse`/`CurrentWeather` models.
- `ImageCacheManager` is a singleton; currently referenced but not actively wired into the seal or weather flow.

## 7. Development Conventions
- **Naming:** CamelCase; Russian-language comments and labels throughout.
- **State management:** `@Observable` macro (iOS 17+) for ViewModels; `@State` for local view state.
- **Error handling:** ViewModel stores an optional `error: String?`; views display it conditionally. Uses `try?` and `try await` with do-catch in ViewModels.
- **Async patterns:** Swift Concurrency (`async/await`, `Task`, `@MainActor`). `.task` modifier for view lifecycle-bound async work.
- **Threading:** `@MainActor` annotations on ViewModels and UI-mutating methods. `NSLock` for thread-safe cache access.

## 8. Current Limitations and Constraints
- **Hardcoded city:** Weather coordinates are fixed to San Jose (37.3394, -121.895); city name is hardcoded to "Chicago, Illinois" in the UI. No user input for location.
- **Wikipedia scraping is fragile:** Regex-based HTML parsing can break on API changes.
- **No error retry logic:** Failed requests show an error but offer no retry mechanism.
- **`ImageCacheManager` is unused:** The file-based cache exists but is not integrated into the seal or weather flow.
- **SVG rendering via WKWebView:** Heavyweight for vector images; no native SVG rendering library used.
- **No localization:** UI strings are in Russian; no `.strings` files or `LocalizedStringKey` usage.
- **No unit tests:** Only placeholder UI tests exist.

## 9. Typical Data Flow
- **Weather fetch:**
  1. User taps "Check Weather" button in `ContentView`.
  2. `WeatherModalView` is presented; `.task` modifier triggers `viewModel.fetchWeather()`.
  3. `WeatherViewModel` calls `WeatherService.fetchWeather()`.
  4. `WeatherService` makes an async HTTP request to Open-Meteo API.
  5. Response is decoded into `CurrentWeather`.
  6. ViewModel updates `temperature` and `humidity` on the main actor.
  7. `WeatherModalView` re-renders with weather data.
- **City seal fetch:**
  1. `DynamicCitySealImage` appears; `onAppear` triggers `viewModel.loadSeal(for:)`.
  2. ViewModel checks `UserDefaults` cache; if present, updates state immediately.
  3. If not cached, fetches Wikipedia HTML via `URLSession`.
  4. Parses HTML with regex to extract SVG URL.
  5. Caches URL in `UserDefaults`; updates `sealUrlString` on main actor.
  6. `DynamicCitySealImage` renders the SVG via `SVGNetworkView` (WKWebView).
