//
//  AppContentBlocking.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation
import BrowserServicesKit
import AVFoundation

//public class AppTrackerDataProvider: TrackerDataProvider {
//
//    public var downloadedTrackerData: Data? {
//        return nil
//    }
//
//}

public class AppContentBlocking {

    static public let trackerDataManager = TrackerDataManager() // TODO: reload

    static public let privacyConfigurationManager = PrivacyConfigurationManager(dataProvider: AppPrivacyConfigurationDataProvider(),
                                                                                localProtection: DomainsProtectionUserDefaultsStore()) //TODO: reload
    static public var contentBlockingRulesManager = ContentBlockerRulesManager(source: DefaultContentBlockerRulesSource(trackerDataManager: trackerDataManager,
                                                                                                                 privacyConfigManager: privacyConfigurationManager))

}
