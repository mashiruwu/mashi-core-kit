//
//  ContentView.swift
//  Example
//
//  Created by Diego Henrick on 25/10/25.
//

import SwiftUI
import MashiCoreKit

struct ContentView: View {
    var body: some View {
      SplashView(
          logoSplashImageName: "logo",
          logoTitleImageName: "memora",
          subtitle1: "Powered by AI.",
          subtitle2: "Designed for your brain.",
          backgroundImageName: "bg"
      )
    }
}

#Preview {
    ContentView()
}
