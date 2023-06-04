import SwiftUI

struct MGSwitchButton: View {
    
    enum State: Int, Identifiable {
        var id: Self { self }
        case off = 0
        case processing = 1
        case on = 2
    }
    
    @Binding private var state: State
    
    let action: (State) -> Void
    
    init(state: Binding<State>, action: @escaping (State) -> Void) {
        self._state = state
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if state == .on {
                Spacer()
                    .frame(width: 20)
            }
            Circle()
                .frame(width: 27, height: 27)
                .foregroundColor(.white)
                .overlay {
                    ProgressView()
                        .tint(Color.black.opacity(0.5))
                        .opacity(state == .processing ? 1.0 : 0.0)
                }
            if state == .off {
                Spacer()
                    .frame(width: 20)
            }
        }
        .padding(2)
        .onTapGesture {
            action(state)
        }
        .background {
            Capsule()
                .foregroundColor(backgroundColor)
        }
        .buttonStyle(.plain)
        .fixedSize()
        .disabled(state == .processing)
        .animation(.easeInOut(duration: 0.15), value: state)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .off:
            return Color(uiColor: .systemGray5)
        case .processing:
            return Color(uiColor: .systemGray5)
        case .on:
            return Color(uiColor: .systemGreen)
        }
    }
}
