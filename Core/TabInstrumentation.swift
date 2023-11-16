//
//  TabInstrumentation.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
import os.signpost

public class TabInstrumentation {
    
    static let tabsLog = OSLog(subsystem: "com.duckduckgo.instrumentation",
                               category: "TabInstrumentation")
    
    static var tabMaxIdentifier: UInt64 = 0
    
    private var siteLoadingSPID: OSSignpostID?
    private var currentURL: String?
    private var currentTabIdentifier: UInt64
    
    public init() {
        Self.tabMaxIdentifier += 1
        currentTabIdentifier = Self.tabMaxIdentifier
    }
    
    private var tabInitSPID: OSSignpostID?
    
    public func willPrepareWebView() {
        // Each event needs to have the same message so that it gets summarised properly in instruments
        //  otherwise it's just a big list of events you have to then manually calculate averages for
        tabInitSPID = Instruments.shared.startTimedEvent(.tabInitialisation, info: "Start")
    }
    
    public func didPrepareWebView() {
        if let tabInitSPID {
            Instruments.shared.endTimedEvent(for: tabInitSPID)
        }
    }
    
    public func willLoad(url: URL) {
        currentURL = url.absoluteString
        let id = OSSignpostID(log: Self.tabsLog)
        siteLoadingSPID = id
        os_signpost(.begin,
                    log: Self.tabsLog,
                    name: "Load Page",
                    signpostID: id,
                    "Loading URL: %@ in %llu", url.host ?? "<error>", currentTabIdentifier)
    }
    
    public func didLoadURL() {
        if let siteLoadingSPID {
            os_signpost(.end,
                        log: Self.tabsLog,
                        name: "Load Page",
                        signpostID: siteLoadingSPID,
                        "Loading Finished")
        }
    }
    
    // MARK: - JS events
    
    public func request(url: String, allowedIn timeInMs: Double) {
        request(url: url, isTracker: false, blocked: false, in: timeInMs)
    }
    
    public func tracker(url: String, allowedIn timeInMs: Double, reason: String?) {
        request(url: url, isTracker: true, blocked: false, reason: reason ?? "?", in: timeInMs)
    }
    
    public func tracker(url: String, blockedIn timeInMs: Double) {
        request(url: url, isTracker: true, blocked: true, in: timeInMs)
    }
    
    private func request(url: String, isTracker: Bool, blocked: Bool, reason: String = "", in timeInMs: Double) {
        let currentURL = self.currentURL ?? "unknown"
        let requestType = isTracker ? "Tracker" : "Regular"
        let status = blocked ? "Blocked" : "Allowed"

        let timeInNS: UInt64 = timeInMs.asNanos

        os_log(.debug,
               log: Self.tabsLog,
               "[%@] Request: %@ - %@ - %@ (%@) in %llu", currentURL, url, requestType, status, reason, timeInNS)
    }
    
    public func jsEvent(name: String, executedIn timeInMs: Double) {
        let currentURL = self.currentURL ?? "unknown"
        let timeInNS: UInt64 = timeInMs.asNanos

        os_log(.debug,
               log: Self.tabsLog,
               "[%@] JSEvent: %@ executedIn: %llu", currentURL, name, timeInNS)
    }
}

extension Double {

    // 0 is treated as 1ms
    var asNanos: UInt64 {
        return self > 0 ? UInt64(self * 1000 * 1000) : 1000000
    }

}
