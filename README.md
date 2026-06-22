# Test Weather App

A lightweight, high-performance SwiftUI pet application that demonstrates modern iOS development practices.

---

## Release History

### v1.2.0 (Latest Release)
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
