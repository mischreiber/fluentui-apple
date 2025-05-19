import SwiftUI

/// ViewModifier that uses GeometryReader to get the size of the content view and sets it in the SizePreferenceKey
struct OnSizeChangeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometryReader in
            Color.clear.preference(key: SizePreferenceKey.self,
                                   value: geometryReader.size)
        })
    }
}

/// PreferenceKey that will store the measured size of the view
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    /// Measures the size of a view, monitors when its size is updated, and takes a closure to be called when it does
    /// - Parameter action: Block to be performed on size change
    /// - Returns The modified view.
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(OnSizeChangeViewModifier())
            .onPreferenceChange(SizePreferenceKey.self,
                                perform: action)
    }
}
