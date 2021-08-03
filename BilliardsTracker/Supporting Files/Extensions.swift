//
//  Extensions.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-05.
//

import SwiftUI

extension Binding where Value: Equatable {
    /// Workaround for `NavigationLink's `isActive = false` called multiple times per dismissal.
    public func removeDuplictates() -> Binding<Value> {
        var previous: Value?

        return Binding<Value>(
            get: { self.wrappedValue },
            set: { newValue in
                guard newValue != previous else {
                    return
                }
                previous = newValue
                self.wrappedValue = newValue
            }
        )
    }
}

extension Color {
    static var primaryBackground: Color {
        Color("primaryBackground")
    }

    static var secondaryBackground: Color {
        Color("secondaryBackground")
    }

    static var primaryElement: Color {
        Color("primaryElement")
    }

    static var secondaryElement: Color {
        Color("secondaryElement")
    }

    static var customRed: Color {
        Color("customRed")
    }

    static var customGreen: Color {
        Color("customGreen")
    }

    static var customBlue: Color {
        Color("customBlue")
    }
}

extension Date {
    var asString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension ScrollView {
    /// Fixes navigation bar title flicker while scrolling.
    func fixFlickering() -> some View {
        self.fixFlickering { scrollView in
            scrollView
        }
    }

    func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        GeometryReader { geometryWithSafeArea in
            GeometryReader { _ in
                configurator(
                    ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
                        AnyView(
                            VStack {
                                self.content
                            }
                            .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                            .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                            .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                            .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                        )
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
