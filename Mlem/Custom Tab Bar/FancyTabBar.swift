//
//  FancyTabBar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabBar<Selection: FancyTabBarSelection, Content: View>: View {
    
    @Binding private var selection: Selection
    private let content: () -> Content
    
    @State private var presentationDetent: PresentationDetent = .height(50)
    @State private var tabItemKeys: [Selection] = []
    @State private var tabItems: [Selection: FancyTabItemLabelBuilder<Selection>] = [:]
    
    @State private var sheetOpen: Bool = false
    
    var dragUpGestureCallback: (() -> Void)?
    
    init(selection: Binding<Selection>,
         dragUpGestureCallback: (() -> Void)? = nil,
         @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.content = content
        self.dragUpGestureCallback = dragUpGestureCallback
    }
    
    var body: some View {
        ZStack(content: content)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: .constant(true)) {
                VStack(spacing: 0) {
                    Divider()
                    GeometryReader { geometry in
                        ZStack {
                            VStack {
                                tabBar
                                Spacer()
                            }
                            .opacity((400.0 - geometry.size.height) / 350.0)
                            VStack {
                                Capsule()
                                    .frame(width: 50, height: 5)
                                    .foregroundStyle(.tertiary)
                                    .padding(7)
                                    .transition(.scale.combined(with: .opacity))
                                AccountsPage(onboarding: false)
                                    .scrollContentBackground(.hidden)
                            }
                            .opacity((geometry.size.height - 50) / 350.0)
                        }
                    }
                }
                .presentationDetents([.height(50), .height(400)], selection: $presentationDetent)
                .presentationBackground(.thinMaterial)
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
                .interactiveDismissDisabled()
            }
            
//            .safeAreaInset(edge: .bottom, alignment: .center) {
//                // this VStack/Spacer()/ignoresSafeArea thing prevents the keyboard from pushing the bar up
//                VStack {
//                    Spacer()
//                    tabBar
//                }
//                .ignoresSafeArea(.keyboard, edges: .bottom)
//            }
            .environment(\.tabSelectionHashValue, selection.hashValue)
            .onPreferenceChange(FancyTabItemPreferenceKey<Selection>.self) {
                self.tabItemKeys = $0
            }
            .onPreferenceChange(FancyTabItemLabelBuilderPreferenceKey<Selection>.self) {
                self.tabItems = $0
            }
    }
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(tabItemKeys, id: \.hashValue) { key in
                    tabItems[key]?.label()
                        .accessibilityElement(children: .combine)
                    // IDK how to get the "Tab: 1 of 5" VO working natively so here's a janky solution
                        .accessibilityLabel("Tab \(key.index) of \(tabItems.count.description)")
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    // high priority to prevent conflict with long press/drag
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    selection = key
                                }
                        )
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if let callback = dragUpGestureCallback, gesture.translation.height < -50 {
                            callback()
                        }
                    }
            )
        }
        .accessibilityElement(children: .contain)
    }
}
