//
//  IVPNWidget.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-05.
//  Copyright (c) 2023 IVPN Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import WidgetKit
import SwiftUI
import NetworkExtension

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        geoLookup(completion: completion)
    }
    
    func geoLookup(completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        guard Date().timeIntervalSince(UserDefaults.shared.lastWidgetUpdate) > 2 else {
            completion(timeline)
            return
        }
        
        UserDefaults.shared.set(Date(), forKey: UserDefaults.Key.lastWidgetUpdate)
        
        let requestIPv4 = ApiRequestDI(method: .get, endpoint: Config.apiGeoLookup, addressType: .IPv4)
        ApiService.shared.request(requestIPv4) { (result: Result<GeoLookup>) in
            switch result {
            case .success(let model):
                let status: NEVPNStatus = model.isIvpnServer ? .connected : .disconnected
                UserDefaults.shared.set(status.rawValue, forKey: UserDefaults.Key.connectionStatus)
                model.save()
                NotificationCenter.default.post(name: Notification.Name.UpdateWidget, object: "UpdateWidget")
                completion(timeline)
            case .failure:
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct EntryView: View {
    var entry: Provider.Entry

    var body: some View {
        MainView()
    }
}

struct IVPNWidget: Widget {
    let kind: String = "IVPNWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EntryView(entry: entry)
        }
        .configurationDisplayName("IVPN")
        .description("Quickly connect and disconnect VPN.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .disableContentMarginsIfNeeded()
    }
}

struct IVPNWidget_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
