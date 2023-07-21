//
//  DragAndDropTest.swift
//  Mlem
//
//  Created by Sam Marfleet on 21/07/2023.
//

import SwiftUI

struct DragAndDropTest: View {
    
    @Namespace var animation
    
    @State private var offset = CGSize.zero
    
    @GestureState var isDragging: Bool = false
    @State private var alignment: Alignment = .leading
    
    var thumbnail: some View {
        Image("SampleImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        
    }
    
    var dropLocation: some View {
        Color.blue.opacity(0.2)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
    }
    
    var title: some View {
        Text("ITAP of some beautiful flowers!")
            .font(.headline)
            .matchedGeometryEffect(id: "Title", in: animation)
    }
    var body: some View {
        Group {
            HStack {
                if alignment == .trailing {
                    if isDragging {
                        dropLocation
                    }
                    title
                    Spacer()
                }
                
                thumbnail
                    .zIndex(1)
                    .offset(offset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isDragging) { _, state, transaction in
                                transaction.animation = .default
                                state = true
                            }
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { value in
                                offset = .zero
                                
                                if value.translation.width < -50 {
                                    alignment = .leading
                                    print("LEADING")
                                } else if value.translation.width > 50 {
                                    alignment = .trailing
                                    print("TRAILING")
                                }
                            }
                    )
                    .scaleEffect(isDragging ? 1.2 : 1)
                    .shadow(color: .black.opacity(isDragging ? 0.3 : 0), radius: 5, x: 5, y: 5)
                
                if alignment == .leading {
                    title
                    Spacer()
                    if isDragging {
                        dropLocation
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(10)
            .animation(.bouncy, value: isDragging)
            .animation(.default, value: alignment)
        }
        .frame(height: 80)
        .background(.background)
        // .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
