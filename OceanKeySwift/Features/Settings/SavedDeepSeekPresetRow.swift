import SwiftUI

struct SavedDeepSeekPresetRow: View {
    let preset: AIVisualPreset
    let isActiveBackground: Bool
    let onActivateBackground: (() -> Void)?
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: preset.kind == .matrixCodeRain ? "terminal.fill" : "sparkle")
                .font(.system(size: 18, weight: .black))
                .frame(width: 34, height: 34)
                .foregroundStyle(OceanKeyTheme.accent)
                .background(OceanKeyTheme.accent.opacity(0.09))
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

            Text(preset.modelTier.title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(OceanKeyTheme.secondaryText)

            if let onActivateBackground {
                Button(action: onActivateBackground) {
                    Label(isActiveBackground ? "Включён" : "Включить фон", systemImage: isActiveBackground ? "checkmark.circle.fill" : "play.circle.fill")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(isActiveBackground ? OceanKeyTheme.roomForeground : OceanKeyTheme.accent)
                        .padding(.horizontal, 9)
                        .frame(height: 34)
                        .background(isActiveBackground ? OceanKeyTheme.accent : OceanKeyTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 15, weight: .black))
                    .frame(width: 34, height: 34)
                    .foregroundStyle(.yellow)
                    .background(.yellow.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(OceanKeyTheme.surface.opacity(0.84))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OceanKeyTheme.accent.opacity(0.18), lineWidth: 1)
        }
    }
}
