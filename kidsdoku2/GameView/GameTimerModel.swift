import Foundation
import Combine
import SwiftUI

/// Isolated timer ObservableObject so only GameTimerView re-renders on each 1Hz tick,
/// not the entire GameView tree.
@MainActor
final class GameTimerModel: ObservableObject {
    @Published private(set) var formattedTime: String = "00:00"

    private var elapsedTime: TimeInterval = 0
    private var timerCancellable: AnyCancellable?
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsedTime += 1
                self.formattedTime = Self.format(self.elapsedTime)
            }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func reset() {
        stop()
        elapsedTime = 0
        formattedTime = "00:00"
    }

    /// Read the current elapsed time on demand (e.g. for star calculation).
    var currentElapsedTime: TimeInterval { elapsedTime }

    private static func format(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    deinit {
        timerCancellable?.cancel()
    }
}
