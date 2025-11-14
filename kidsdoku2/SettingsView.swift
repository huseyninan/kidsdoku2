import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var soundManager = SoundManager.shared
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @State private var isShowingAbout = false
    @State private var pendingReset: ResetTarget?
    @State private var showResetDialog = false
    
    private let completionManager = PuzzleCompletionManager.shared
    private let privacyPolicyURL = URL(string: "https://kidsdoku.app/privacy")!
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SettingsSection(title: "Audio & Feedback", iconName: "speaker.wave.2.fill") {
                    SettingsToggleRow(
                        title: "Sound Effects",
                        subtitle: "Play taps, hints, and celebration jingles",
                        isOn: $soundManager.isSoundEnabled
                    )
                    
                    Divider().padding(.horizontal, -8)
                    
                    SettingsToggleRow(
                        title: "Haptic Feedback",
                        subtitle: "Plan for gentle vibrations during key actions",
                        isOn: $hapticsEnabled
                    )
                }
                
                SettingsSection(title: "Progress Management", iconName: "chart.bar.fill") {
                    SettingsActionRow(
                        title: "Reset 4x4 Progress",
                        subtitle: "Clears completed 4x4 quest badges",
                        iconName: "4.circle.fill",
                        tint: Color(red: 0.97, green: 0.69, blue: 0.22)
                    ) {
                        presentResetDialog(.size(4))
                    }
                    
                    Divider().padding(.horizontal, -8)
                    
                    SettingsActionRow(
                        title: "Reset 6x6 Progress",
                        subtitle: "Clears completed 6x6 quest badges",
                        iconName: "6.circle.fill",
                        tint: Color(red: 0.89, green: 0.44, blue: 0.34)
                    ) {
                        presentResetDialog(.size(6))
                    }
                    
                    Divider().padding(.horizontal, -8)
                    
                    SettingsActionRow(
                        title: "Reset All Progress",
                        subtitle: "Clears every checkmark across all puzzle sizes",
                        iconName: "wand.and.stars.inverse",
                        tint: Color.red.opacity(0.8)
                    ) {
                        presentResetDialog(.all)
                    }
                }
                
                SettingsSection(title: "About & Privacy", iconName: "info.circle.fill") {
                    Button {
                        isShowingAbout = true
                    } label: {
                        SettingsNavigationRow(
                            title: "About Kidsdoku",
                            subtitle: "Meet the storytellers, illustrators, and sound team",
                            iconName: "sparkles",
                            tint: Color.purple
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.horizontal, -8)
                    
                    Link(destination: privacyPolicyURL) {
                        SettingsNavigationRow(
                            title: "Privacy Policy",
                            subtitle: "Read how we keep young players safe",
                            iconName: "lock.shield.fill",
                            tint: Color.green
                        )
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(.headline)
            }
        }
        .confirmationDialog(
            pendingReset?.dialogTitle ?? "",
            isPresented: $showResetDialog,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                performReset()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let message = pendingReset?.dialogMessage {
                Text(message)
            }
        }
        .sheet(isPresented: $isShowingAbout) {
            AboutView()
        }
    }
    
    private func presentResetDialog(_ target: ResetTarget) {
        pendingReset = target
        showResetDialog = true
    }
    
    private func performReset() {
        guard let target = pendingReset else { return }
        switch target {
        case .size(let size):
            completionManager.resetSize(size)
        case .all:
            completionManager.resetAll()
        }
        pendingReset = nil
    }
}

private enum ResetTarget: Identifiable {
    case size(Int)
    case all
    
    var id: String {
        switch self {
        case .size(let value):
            return "size-\(value)"
        case .all:
            return "all"
        }
    }
    
    var dialogTitle: String {
        switch self {
        case .size(let size):
            return "Reset \(size)x\(size) Progress?"
        case .all:
            return "Reset All Progress?"
        }
    }
    
    var dialogMessage: String {
        switch self {
        case .size(let size):
            return "This removes every completed \(size)x\(size) puzzle badge. This cannot be undone."
        case .all:
            return "This wipes every completion badge across all puzzle sizes. This cannot be undone."
        }
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let iconName: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: iconName)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.15))
            
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
        )
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.98, green: 0.65, blue: 0.25)))
    }
}

private struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let tint: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(tint)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let iconName: String
    let tint: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 6)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Kidsdoku2 is built by a tiny team obsessed with playful logic adventures crafted for younger players.")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        AboutRow(title: "Creative Direction", detail: "The Kidsdoku Collective")
                        AboutRow(title: "Illustrations", detail: "Poppy Fields Studio")
                        AboutRow(title: "Sound Design", detail: "Wonder Tone Audio")
                        AboutRow(title: "Engineering", detail: "Studio Kidu Labs")
                    }
                    
                    Text("Thank you for puzzling with us! We hope these gentle adventures spark curiosity and confidence.")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.3, blue: 0.2))
                }
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.primary)
                .padding(24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("About Kidsdoku")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
    
    private struct AboutRow: View {
        let title: String
        let detail: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                Text(detail)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

