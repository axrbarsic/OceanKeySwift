import SwiftUI

struct AIBackgroundPresetActivationRow: View {
    let preset: AIVisualPreset
    let isActive: Bool
    let onActivate: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .black))
                .frame(width: 34, height: 34)
                .foregroundStyle(isActive ? OceanKeyTheme.roomForeground : OceanKeyTheme.accent)
                .background(isActive ? OceanKeyTheme.accent : OceanKeyTheme.accent.opacity(0.09))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(preset.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text(preset.summary)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(OceanKeyTheme.secondaryText.opacity(0.82))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button(action: onActivate) {
                Label(isActive ? "Вкл" : "Включить", systemImage: isActive ? "checkmark.circle.fill" : "play.circle.fill")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(isActive ? OceanKeyTheme.roomForeground : OceanKeyTheme.accent)
                    .padding(.horizontal, 10)
                    .frame(height: 34)
                    .background(isActive ? OceanKeyTheme.accent : OceanKeyTheme.accent.opacity(0.10))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(OceanKeyTheme.surface.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke((isActive ? OceanKeyTheme.accent : OceanKeyTheme.accent.opacity(0.18)), lineWidth: 1)
        }
    }
}
