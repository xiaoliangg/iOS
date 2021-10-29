//
//  WebCacheManager.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import WebKit

public protocol WebCacheManagerCookieStore {
    
    func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void)

    func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)?)

    func delete(_ cookie: HTTPCookie, completionHandler: (() -> Void)?)
    
}

public protocol WebCacheManagerDataStore {
    
    var cookieStore: WebCacheManagerCookieStore? { get }
    
    func removeAllDataExceptCookies(completion: @escaping () -> Void)
    
}

public class WebCacheManager {

    private struct Constants {
        static let cookieDomain = "duckduckgo.com"
    }
    
    public static var shared = WebCacheManager()
    
    private init() { }

    /// This function is used to extract cookies stored in CookieStorage and restore them to WKWebView's HTTP cookie store during the Fire button operation.
    /// The Fire button no longer persists and restores cookies, but this function remains in the event that cookies have been stored and not yet restored.
    public func consumeCookies(cookieStorage: CookieStorage = CookieStorage(),
                               httpCookieStore: WebCacheManagerCookieStore? = WKWebsiteDataStore.default().cookieStore,
                               completion: @escaping () -> Void) {
        DebugLogger.shared.log("- start -")
        
        guard let httpCookieStore = httpCookieStore else {
            completion()
            return
        }
        
        let cookies = cookieStorage.cookies
        
        guard !cookies.isEmpty else {
            DebugLogger.shared.log(" cookieStorage empty")
            DebugLogger.shared.log("- finish-")
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        DebugLogger.shared.log(" cookies count: \(cookies.count)")
        let oldCookies = HTTPCookieStorage.shared.cookies ?? []
        DebugLogger.shared.log(" HTTPCookieStorage count: \(oldCookies.count)")
        
        var cookieCounter = 0
        for cookie in cookies {
            group.enter()
            DebugLogger.shared.log(" -consuming cookie #\(cookieCounter) for domain: \(cookie.domain) \(cookie.name)")
            let domain = cookie.domain
            httpCookieStore.setCookie(cookie) { [cookieCounter, domain] in
                DebugLogger.shared.log(" -succesfully consumed cookie #\(cookieCounter) in domain: \(domain)")
                group.leave()
            }
            
            cookieCounter += 1
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            group.wait()
            
            DispatchQueue.main.async {
                DebugLogger.shared.log(" attempting to clear cookie storage")
                
                cookieStorage.clear()
                
                DebugLogger.shared.log("- finish-")
                completion()
            }
        }
    }

    public func removeCookies(forDomains domains: [String],
                              dataStore: WebCacheManagerDataStore = WKWebsiteDataStore.default(),
                              completion: @escaping () -> Void) {
        DebugLogger.shared.log()
        
        guard let cookieStore = dataStore.cookieStore else {
            completion()
            return
        }

        cookieStore.getAllCookies { cookies in
            let group = DispatchGroup()
            cookies.forEach { cookie in
                if domains.contains(where: { self.isCookie(cookie, matchingDomain: $0)}) {
                    group.enter()
                    cookieStore.delete(cookie) {
                        group.leave()
                    }
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let result = group.wait(timeout: .now() + 5)

                if result == .timedOut {
                    Pixel.fire(pixel: .cookieDeletionTimedOut, withAdditionalParameters: [
                        PixelParameters.removeCookiesTimedOut: "1"
                    ])
                }

                DispatchQueue.main.async {
                    completion()
                }
            }
        }

    }

    public func clear(dataStore: WebCacheManagerDataStore = WKWebsiteDataStore.default(),
                      logins: PreserveLogins = PreserveLogins.shared,
                      completion: @escaping () -> Void) {
        DebugLogger.shared.log("- start -")
        
        dataStore.removeAllDataExceptCookies {
            guard let cookieStore = dataStore.cookieStore else {
                completion()
                return
            }

            cookieStore.getAllCookies { cookies in
                let group = DispatchGroup()
                let cookiesToRemove = cookies.filter { !logins.isAllowed(cookieDomain: $0.domain) && $0.domain != Constants.cookieDomain }
                
                DebugLogger.shared.log(" cookies count: \(cookies.count)")
                let oldCookies = HTTPCookieStorage.shared.cookies ?? []
                DebugLogger.shared.log(" HTTPCookieStorage count: \(oldCookies.count)")
            
                DebugLogger.shared.log(" cookies for removal: \(cookiesToRemove.count)")
                DebugLogger.shared.log(" protected domains: \(logins.allowedDomains)")
                
                var cookieCounter = 0
                
                for cookie in cookiesToRemove {
                    group.enter()
                    DebugLogger.shared.log(" -deleting cookie #\(cookieCounter) for domain: \(cookie.domain) \(cookie.name)")
                    
                    let domain = cookie.domain
                    cookieStore.delete(cookie) { [cookieCounter, domain] in
                        DebugLogger.shared.log(" -succesfully deleted cookie #\(cookieCounter) in domain: \(domain)")
                        group.leave()
                    }
                    
                    cookieCounter += 1
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    let result = group.wait(timeout: .now() + 5)

                    if result == .timedOut {
                        DebugLogger.shared.log(" !cookie removal timed out!")
                        Pixel.fire(pixel: .cookieDeletionTimedOut, withAdditionalParameters: [
                            PixelParameters.clearWebDataTimedOut: "1"
                        ])
                    }

                    DispatchQueue.main.async {
                        DebugLogger.shared.log("- finish -")
                        completion()
                        
                        cookieStore.getAllCookies { cookies in
                            DebugLogger.shared.log(" cookies count: \(cookies.count)")
                            DebugLogger.shared.log(" HTTPCookieStorage count: \(oldCookies.count)")
                        }
                    }
                }
            }
        }
        
    }

    /// The Fire Button does not delete the user's DuckDuckGo search settings, which are saved as cookies. Removing these cookies would reset them and have undesired
    ///  consequences, i.e. changing the theme, default language, etc.  These cookies are not stored in a personally identifiable way. For example, the large size setting
    ///  is stored as 's=l.' More info in https://duckduckgo.com/privacy
    private func isCookie(_ cookie: HTTPCookie, matchingDomain domain: String) -> Bool {
        return cookie.domain == domain || (cookie.domain.hasPrefix(".") && domain.hasSuffix(cookie.domain))
    }

}

extension WKHTTPCookieStore: WebCacheManagerCookieStore {
        
}

extension WKWebsiteDataStore: WebCacheManagerDataStore {

    public var cookieStore: WebCacheManagerCookieStore? {
        return self.httpCookieStore
    }

    public func removeAllDataExceptCookies(completion: @escaping () -> Void) {
        var types = WKWebsiteDataStore.allWebsiteDataTypes()

        // Force the HSTS cache to clear when using the Fire button.
        // https://github.com/WebKit/WebKit/blob/0f73b4d4350c707763146ff0501ab62425c902d6/Source/WebKit/UIProcess/API/Cocoa/WKWebsiteDataRecord.mm#L47
        types.insert("_WKWebsiteDataTypeHSTSCache")

        types.remove(WKWebsiteDataTypeCookies)

        removeData(ofTypes: types,
                   modifiedSince: Date.distantPast,
                   completionHandler: completion)
    }
    
}
