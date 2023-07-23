//
//  LargeTextFieldStyle.swift
//  Mlem
//
//  Created by Sjmarf on 22/07/2023.
//

import SwiftUI

struct LargeTextFieldStyle: TextFieldStyle {
    @Environment(\.isEnabled) var isEnabled
    @FocusState private var textFieldFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                )
            .opacity(isEnabled ? 1: 0.5)
            .focused($textFieldFocused)
            .onTapGesture {
                textFieldFocused = true
            }
            .animation(.easeOut(duration: 0.2), value: isEnabled)
    }
}
