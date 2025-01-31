//
//  HomePageConfiguration.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import Core

final class HomePageConfiguration {
    
    enum Component: Equatable {
        case navigationBarSearch(fixed: Bool)
        case favorites
        case homeMessage
    }
    
    func components(bookmarksManager: BookmarksManager = BookmarksManager()) -> [Component] {
        let fixed = bookmarksManager.favoritesCount == 0
        return [
            .navigationBarSearch(fixed: fixed),
            .homeMessage,
            .favorites
        ]
    }
    
    // MARK: - Messages
    
    private var homeMessageStorage: HomeMessageStorage
    
    init(variantManager: VariantManager? = nil) {
        homeMessageStorage = HomeMessageStorage(variantManager: variantManager)
    }
    
    var homeMessages: [HomeMessage] { homeMessageStorage.messagesToBeShown }
    
    func dismissHomeMessage(_ homeMessage: HomeMessage) {
        switch homeMessage {
        case .widgetEducation:
            homeMessageStorage.hideWidgetEducation()
        }
    }
}
