//
//  MainView.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Juraj Hilje on 2023-04-05.
//  Copyright (c) 2023 Privatus Limited.
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

import SwiftUI

struct MainView: View {
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.background)
            VStack(alignment: .leading) {
                StatusView()
                if family != .systemSmall {
                    Divider()
                        .padding(.top, -10)
                    LocationView()
                }
                if family == .systemLarge {
                    Divider()
                        .padding(.top, -6)
                    ConnectionInfoView()
                }
            }
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
