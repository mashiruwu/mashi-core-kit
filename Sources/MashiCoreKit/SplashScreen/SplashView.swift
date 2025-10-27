//
//  SplashView.swift
//  MashiCoreKit
//
//  Created by Diego Henrick on 26/10/25.
//

import SwiftUI

public struct SplashView: View {
  // MARK: - Stored config the host app must provide

  private let logoSplashImageName: String
  private let logoTitleImageName: String
  private let subtitle1: String?
  private let subtitle2: String?
  private let backgroundImageName: String?

  // MARK: - Public initializer (this is what apps will call)

  public init(
      logoSplashImageName: String,
      logoTitleImageName: String,
      subtitle1: String? = nil,
      subtitle2: String? = nil,
      backgroundImageName: String? = nil
  ) {
      self.logoSplashImageName = logoSplashImageName
      self.logoTitleImageName = logoTitleImageName
      self.subtitle1 = subtitle1
      self.subtitle2 = subtitle2
      self.backgroundImageName = backgroundImageName
  }

  public var body: some View {
    HStack {
      Spacer()
      VStack {
        Spacer()
        Image(logoSplashImageName)
          .resizable()
          .frame(width: 250, height: 250)
          .blendMode(.screen)

        Image(logoTitleImageName)
          .resizable()
          .scaledToFit()
          .padding(.horizontal, 20)
        Text(subtitle1 ?? "")
          .foregroundStyle(.white)
        Text(subtitle2 ?? "")
          .foregroundStyle(.white)
        Spacer()
      }
      Spacer()
    }
    .background() {
        Image(backgroundImageName ?? "")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
  }
}

#Preview {
  SplashView(logoSplashImageName: "", logoTitleImageName: "")
}
