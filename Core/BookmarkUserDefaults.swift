//
//  BookmarkUserDefaults.swift
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

import Foundation

// This is no longer how bookmarks are stored. It is kept only so old data can be migrated
public class BookmarkUserDefaults: BookmarkStore {
    
    public struct Notifications {
        public static let bookmarkStoreDidChange = Notification.Name("com.duckduckgo.bookmarks.storeDidChange")
    }

    public struct Constants {
        public static let groupName = "\(Global.groupIdPrefix).bookmarks"
    }

    private struct Keys {
        static let bookmarkKey = "com.duckduckgo.bookmarks.bookmarkKey"
        static let favoritesKey = "com.duckduckgo.bookmarks.favoritesKey"
    }

    // yl UserDefaults介绍:https://www.jianshu.com/p/3796886b4953
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults(suiteName: Constants.groupName)!) {
        self.userDefaults = userDefaults
    }

    // yl!! 此处[]的作用？？ 答: 此处表示Link数组
    // yl 关联:025 closure:[]定义捕获列表解决闭包的循环引用问题
    public var bookmarks: [Link] {
        get {
            if let data = userDefaults.data(forKey: Keys.bookmarkKey) {
                // yl let为true时执行括号内语句
                // 返回 Link 数组:[Link]
                // 返回书签数组
                return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Link]) ?? []
            }
            return []
        }
        set(newBookmarks) {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newBookmarks, requiringSecureCoding: false) else { return }
            userDefaults.set(data, forKey: Keys.bookmarkKey)
            // yl?? 发送书签变更通知,通知发给谁？作用是什么？
            NotificationCenter.default.post(name: Notifications.bookmarkStoreDidChange, object: self)
        }
    }

    public var favorites: [Link] {
        get {
            if let data = userDefaults.data(forKey: Keys.favoritesKey) {
                return (try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Link]) ?? []
            }
            return []
        }
        set(newFavorites) {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newFavorites, requiringSecureCoding: false) else { return }
            userDefaults.set(data, forKey: Keys.favoritesKey)
            NotificationCenter.default.post(name: Notifications.bookmarkStoreDidChange, object: self)
        }
    }

    public func addBookmark(_ bookmark: Link) {
        var newBookmarks = bookmarks
        newBookmarks.append(bookmark)
        bookmarks = newBookmarks
    }
    
    public func addFavorite(_ favorite: Link) {
        var newFavorites = favorites
        newFavorites.append(favorite)
        favorites = newFavorites
    }

    public func contains(domain: String) -> Bool {
        // yl domainMatches 是函数类型
        let domainMatches: (Link) -> Bool = {
            $0.url.host == domain
        }
        // yl bookmarks数组是否包含domain(Link.url.host==domain)
        // yl where不是关键字
        return bookmarks.contains(where: domainMatches) || favorites.contains(where: domainMatches)
    }
    
    public func deleteAllData() {
        bookmarks = []
        favorites = []
    }

}
