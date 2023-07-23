//
//  NewAddAccountView.swift
//  Mlem
//
//  Created by Sam Marfleet on 22/07/2023.
//

import SwiftUI

struct NewAddAccountView: View {
    
    @State private var instance: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showingInstanceField: Bool = false
    
    @Namespace var animation
    
    var content: some View {
        VStack(spacing: 10) {
            Group {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 50, idealWidth: 100, maxWidth: 100, minHeight: 50, idealHeight: 100, maxHeight: 100)
                    .foregroundColor(.blue)
                
                Text("Login to Lemmy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                VStack {
                    Button {
                        showingInstanceField = true
                    } label: {
                        HStack {
                            Text("Instance URL")
                                .foregroundStyle(.tertiary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.gray, lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .matchedGeometryEffect(id: "InstanceField", in: animation)
                    )
                }
                Spacer()
            }
            
            TextField("Username", text: $username)
                .textFieldStyle(LargeTextFieldStyle())
                .controlSize(.large)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(LargeTextFieldStyle())
                .controlSize(.large)
            
            Spacer()
            
            VStack {
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .blur(radius: showingInstanceField ? 10 : 0)
        .allowsHitTesting(!showingInstanceField)
        .padding(.horizontal, 20)
    }
    
    var body: some View {
        ZStack {
            content
//            if showingInstanceField {
//                content
//                    .ignoresSafeArea(.keyboard)
//            } else {
//                content
//            }
            
            VStack {
                if showingInstanceField {
                    InstanceTextFieldView(instance: $instance, showingInstanceField: $showingInstanceField, animation: animation)
                }
            }
        }
        .animation(.default, value: showingInstanceField)
        .modifier(TabSafeScrollView())
        .navigationBarBackButtonHidden(true)
    }
}

struct NewAddAccountPreview: PreviewProvider {
    static var previews: some View {
        NewAddAccountView()
            .previewDisplayName("Default preview")
    }
}
