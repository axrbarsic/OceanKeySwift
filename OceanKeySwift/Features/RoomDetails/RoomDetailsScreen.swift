import SwiftUI

struct RoomDetailsScreen: View {
    let route: RoomDetailsRoute

    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""

    var body: some View {
        ZStack {
            SpriteKitEffectView(.matrixRain)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                header

                VStack(alignment: .leading, spacing: 14) {
                    Text(route.mode.title)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if route.mode == .voice {
                        voicePlaceholder
                    } else {
                        textEditor
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(OceanKeyTheme.surface.opacity(0.84))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OceanKeyTheme.accent.opacity(0.22), lineWidth: 1)
                }

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .black))
                    .frame(width: 48, height: 48)
                    .foregroundStyle(OceanKeyTheme.secondaryText)
                    .background(OceanKeyTheme.surface.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text(route.roomID)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()

            Spacer()
        }
    }

    private var voicePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(OceanKeyTheme.accent)

            Text("Здесь будет нативная запись голоса с транскрипцией.")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(OceanKeyTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }

    private var textEditor: some View {
        TextEditor(text: $noteText)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .scrollContentBackground(.hidden)
            .foregroundStyle(.white)
            .padding(10)
            .frame(minHeight: 240)
            .background(.black.opacity(0.24))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(OceanKeyTheme.accent.opacity(0.18), lineWidth: 1)
            }
    }
}

#Preview {
    RoomDetailsScreen(route: RoomDetailsRoute(roomID: "303", mode: .voice))
        .preferredColorScheme(.dark)
}

