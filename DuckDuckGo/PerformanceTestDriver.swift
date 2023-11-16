//
//  PerformanceTestDriver.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import WebKit

class PerformanceTestDriver {

    let urls = [
        "https://m.twitch.tv/",
        "https://weather.com/",
        "https://www.amazon.com/",
        "https://www.bbc.co.uk/",
        "https://www.ebay.co.uk/",
        "https://www.espn.co.uk/",
        "https://www.nytimes.com/",
        "https://www.reddit.com/",
        "https://www.tripadvisor.com/",
        "https://www.walmart.com/",
        "https://www.wikipedia.org/",
        "https://duckduckgo.com/",
    ]

    weak var webView: WKWebView?

    var index = 0

    init(_ webView: WKWebView) {
        self.webView = webView
    }

    func start() {
        index = -1
        loadNext()
    }

    func loadNext() {
        index += 1
        if urls.indices.contains(index) {
            let url = URL(string: urls[index])!
            ActionMessageView.present(message: "\(index + 1) of \(urls.count): \(urls[index])")
            webView?.load(URLRequest(url: url))
        } else {
            ActionMessageView.present(message: "Performance test complete")
        }
    }

}
