//
//  WKWebViewConfigurationExtension.swift
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
import os.log

extension WKWebViewConfiguration {

    private static var sharedProcessPool = WKProcessPool()

    // Should really change this to be thread safe
    public static func regenerateProcessPool() {
        sharedProcessPool = WKProcessPool()
        os_log("Regenerated WKProcessPool", log: webviewLog, type: .debug)
    }

    public static func persistent() -> WKWebViewConfiguration {
        return configuration(persistsData: true)
    }

    public static func nonPersistent() -> WKWebViewConfiguration {
        return configuration(persistsData: false)
    }
    
    private static func configuration(persistsData: Bool) -> WKWebViewConfiguration {
        os_log("Creating new WKWebViewConfiguration using pool %@", log: webviewLog, type: .debug, sharedProcessPool)
        let configuration = WKWebViewConfiguration()
        if !persistsData {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        configuration.dataDetectorTypes = [.phoneNumber]

        configuration.installContentBlockingRules()

        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.ignoresViewportScaleLimits = true
        configuration.processPool = sharedProcessPool

        os_log("Created new WKWebViewConfiguration using pool %@", log: webviewLog, type: .debug, sharedProcessPool)

        return configuration
    }
    
    private func installContentBlockingRules() {
        func addRulesToController(rules: WKContentRuleList) {
            self.userContentController.add(rules)
        }
        
        if let rules = ContentBlockerRulesManager.shared.currentRules,
           PrivacyConfigurationManager.shared.privacyConfig.isEnabled(featureKey: .contentBlocking) {
            addRulesToController(rules: rules.rulesList)
        }
    }
    
    public func installContentRules(trackerProtection: Bool) {
        if trackerProtection {
            self.installContentBlockingRules()
        }
    }
}
