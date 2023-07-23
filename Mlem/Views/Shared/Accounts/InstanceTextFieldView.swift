//
//  InstanceTextFieldView.swift
//  Mlem
//
//  Created by Sam Marfleet on 22/07/2023.
//

import SwiftUI

struct InstanceTextFieldView: View {
    
    @Binding var instance: String
    @Binding var showingInstanceField: Bool
    
    let animation: Namespace.ID
    
    @FocusState private var focusedField: Bool
    
    var body: some View {
        ZStack {
            VStack {
                TextField("Instance URL", text: $instance)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .focused($focusedField)
                    .onAppear {
                        focusedField = true
                    }
                    .onChange(of: focusedField) { newValue in
                        if !newValue {
                            showingInstanceField = false
                        }
                    }
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.gray, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .matchedGeometryEffect(id: "InstanceField", in: animation)
            )
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = false
            showingInstanceField = false
        }
    }
}
