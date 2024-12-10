import SwiftUI
import WebKit

// MARK: - Cross-Platform WebView
struct WebView: View {
    let url: URL
    let customUserAgent: String
    
    var body: some View {
#if os(iOS)
        iOSWebView(url: url, customUserAgent: customUserAgent)
#elseif os(macOS)
        macOSWebView(url: url, customUserAgent: customUserAgent)
#endif
    }
}

#if os(iOS)
// MARK: - iOS WebView
struct iOSWebView: UIViewRepresentable {
    let url: URL
    let customUserAgent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = customUserAgent
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
#elseif os(macOS)
// MARK: - macOS WebView
struct macOSWebView: NSViewRepresentable {
    let url: URL
    let customUserAgent: String
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = customUserAgent
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}
#endif
// MARK: - ContentView
struct ContentView: View {
    @State private var helloSheet = false
    @State private var ipadOSMenu = false

    @State private var showSettings = false
    @State private var shaken = false
    @AppStorage("ResetOnLaunch") var relaunch = false
    @AppStorage("User Agent") var customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edge/44.19041.4788"
    private let websiteURL = URL(string: "https://youtube.com/tv")!
    
    var body: some View {
        ZStack {
            WebView(url: websiteURL, customUserAgent: customUserAgent)
                .edgesIgnoringSafeArea(.all) // Makes the WebView fill the screen
                .onAppear {
                    helloSheet = true
                }
                .sheet(isPresented: $helloSheet) {
                    VStack {
                        Text("Welcome")
                            .font(.largeTitle)
                        Spacer()
                        Text("To use this app, use a keyboard or controller, then use either the arrow keys and Enter button on Keyboard or the Joystick/Arrow Buttons and Primary Button (X on PlayStation Controllers, A on Xbox Controllers)")
                        Spacer()
                        Button("Continue") {
                            helloSheet = false
                        }
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.blue)
                        )
                    }
                    .padding()
                }
                .onAppear {
                    if relaunch {
                        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            records.forEach { record in
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                            }
                        }
                        relaunch = false
                    }
                }
                .onChange(of: relaunch) { newValue in
                    if relaunch {
                        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            records.forEach { record in
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                            }
                        }
                        relaunch = false
                    }
                }
#if os(iOS)
                .onShake {
                    shaken = true
                }
                .confirmationDialog("Shake Menu", isPresented: $shaken, titleVisibility: .visible) {
                    Button("Open Settings") {
                        showSettings = true
                    }
                    Button("Empty Cache") {
                        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                            records.forEach { record in
                                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                            }
                        }
                        exit(0)
                    }
                    
                }
#endif
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack {
                    Button(action: {
                        ipadOSMenu = true
                    }) {
                        Image(systemName: "apple.logo")
                    }
                    .foregroundStyle(.primary)
                    .padding()
                    .background(
                        RoundedRectangle (cornerRadius: 15)
                            .fill(.thinMaterial)
                    )
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .sheet(isPresented: $ipadOSMenu) {
                    List {
                        Button("Empty Cache ") {
                            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
                            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                                records.forEach { record in
                                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                                }
                            }
                            exit(0)
                        }
                        Button("Settings") {
                            showSettings = true
                        }
                    }
                }
            }
            #endif
        }
    }
    
}

#if os(iOS)
// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

// A view modifier that detects shaking and calls a function of our choosing.
struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
#endif
