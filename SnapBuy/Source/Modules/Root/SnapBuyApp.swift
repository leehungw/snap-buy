//
//  SnapBuyApp.swift
//  SnapBuy
//
//  Created by minhgaa on 11/3/25.
//

import SwiftUI

@main
struct SnapBuyApp: App {
    var body: some Scene {
        WindowGroup {
            SBLoginView()
                .environment(\.font, .custom("Outfit-Regular", size: 16))
            
        }
    }
}
