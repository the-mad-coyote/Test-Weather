# Test Weather App

A lightweight, high-performance SwiftUI pet application that demonstrates modern iOS development practices.

---

## Release History

### v1.3.0 (Latest Release)
**Add dynamic city search and geocoding integration**
- Introduce GeocodingService using Open-Meteo API to resolve city names to coordinates
- Implement Codable Location and GeocodingResponse models
- Refactor WeatherService to accept dynamic latitude and longitude parameters
- Upgrade WeatherViewModel with @observable and @mainactor to manage search states
- Implement a full-width .searchable interface and city list overlay in ContentView
- Fix dynamic city seal reloading by updating DynamicCitySealImage to use .task(id:)
<img width="1179" height="2556" alt="IMG_7174" src="https://github.com/user-attachments/assets/fe22f4e3-51f7-437c-bde7-cb3bcc79c6db" />
<img width="1179" height="2556" alt="IMG_7173" src="https://github.com/user-attachments/assets/ea3702d6-a0fe-438c-8be5-2093657795d8" />



### v1.2.0 
**Dynamic city seal with disk caching**
- Implemented `DynamicCitySealViewModel` using modern SwiftUI `@Observable` macro to fetch official city seals from Wikipedia.
- Created `ImageCacheManager` with `FileManager` to store images on disk inside the application Sandbox.
- Integrated `UserDefaults` caching layer for fast URL lookup and bandwidth optimization.
- Resolved low-level iOS `NSPOSIXErrorDomain Code=100 Protocol error` by refining user-agent headers and request formatting.
- Integrated `WKWebView` renderer via `UIViewRepresentable` to safely parse and display remote SVG vector graphics.
- Refactored `ContentView` layout to support dynamic, data-driven location strings
- 
<img width="590" height="1280" alt="IMG_7169 Large" src="https://github.com/user-attachments/assets/fd9896ae-eab3-4117-8f7a-f99b9039b302" />

---

### v1.1.0
**Temp units switching & Humidity added**

---

### v1.0.0
**Initial MVVM structure, refactored spaghetti code**

---

## Tech Stack & Architecture

- **Language:** Swift 5.10+ / iOS 17+
- **UI Framework:** SwiftUI (Declarative Syntax)
- **Architecture:** MVVM (Model-View-ViewModel)
- **State Management:** Modern SwiftUI `@Observable` macro
- **Asynchrony:** Swift Concurrency (`async/await`, `Task`, `MainActor`)
- **Networking:** Native `URLSession` with customized configurations
- **Data Parsing:** Type-safe `Decodable` structs & `JSONSerialization`
