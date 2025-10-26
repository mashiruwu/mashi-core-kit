//
//  SplashScreen.swift
//  Example
//
//  Created by Diego Henrick on 26/10/25.
//

import SwiftUI
import MashiCoreKit

struct RootDemoScreen: View {
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
