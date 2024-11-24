//
//  PopView.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/23/24.
//

import SwiftUI

extension View {
    func popView<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> (),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .modifier(
                PopViewHelper(
                    isPresented: isPresented,
                    onDismiss: onDismiss,
                    viewContent: content
                )
            )
    }
}

fileprivate struct PopViewHelper<ViewContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @EnvironmentObject private var constants: Constants
    var onDismiss: () -> ()
    @ViewBuilder var viewContent: ViewContent
    // Local view properties
    @State private var presentFullScreenCover: Bool = false
    @State private var animateView: Bool = false
    func body(content: Content) -> some View {
        // Unmutable properties
        let screenHeight = screenSize.height
        let animateView = animateView
        
        content
            .fullScreenCover(isPresented: $presentFullScreenCover, onDismiss: onDismiss) {
                ZStack {
                    Rectangle()
                        .fill(constants.popupBackgroundColor)
                        .ignoresSafeArea()
                        .opacity(animateView ? 1 : 0)
                    
                    viewContent
                        .visualEffect({content, proxy in
                            content
                                .offset(y: offset(proxy, screenHeight: screenHeight, animateView: animateView))
                        })
                        .presentationBackground(.clear)
                        .task {
                            guard !animateView else { return }
                            withAnimation(.bouncy(duration: 0.4, extraBounce: 0.05)) {
                                self.animateView = true
                            }
                        }
                        .ignoresSafeArea(.container, edges: .all)
                }
            }
            .onChange(of: isPresented) { oldValue, newValue in
                if newValue {
                    toggleView(true)
                } else {
                    Task {
                        withAnimation(.snappy(duration: 0.45, extraBounce: 0)) {
                            self.animateView = false
                        }
                        
                        try? await Task.sleep(for: .seconds(0.45))
                        
                        toggleView(false)
                    }
                }
            }
    }
    
    func toggleView(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            presentFullScreenCover = status
        }
    }
    
    nonisolated func offset(_ proxy: GeometryProxy, screenHeight: CGFloat, animateView: Bool) -> CGFloat {
        let viewHeight = proxy.size.height
        return animateView ? 0 : (screenHeight + viewHeight) / 2
    }
    
    var screenSize: CGSize {
        if let screenSize = (
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        )?.screen.bounds.size {
            return screenSize
        }
        
        return .zero
    }
}

#Preview {
    ContentView()
}
