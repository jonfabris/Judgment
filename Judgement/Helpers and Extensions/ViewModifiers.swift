//
//  ViewModifiers.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/6/25.
//

import SwiftUI

struct DefaultTextEditStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(0)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1))
    }
}

extension View {
    func withDefaultTextEditStyle() -> some View {
        modifier(DefaultTextEditStyle())
    }
}

public extension View {
    @MainActor
    func snapshot(scale: CGFloat? = nil) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale ?? UIScreen.main.scale
        return renderer.uiImage
    }
}
