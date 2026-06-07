import SwiftUI

struct SummaryHeader: View {
    let counts: SummaryCounts

    var body: some View {
        HStack(spacing: 16) {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 26, weight: .bold))
                    .frame(width: 58, height: 58)
                    .background(OceanKeyTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 16))
            }
            .foregroundStyle(OceanKeyTheme.secondaryText)

            Spacer()

            HStack(spacing: 14) {
                Text("\(counts.pending)").foregroundStyle(OceanKeyTheme.pending)
                Text("\(counts.ready)").foregroundStyle(OceanKeyTheme.ready)
                Text("\(counts.open)").foregroundStyle(OceanKeyTheme.open)
            }
            .font(.system(size: 32, weight: .black, design: .rounded))
            .monospacedDigit()

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "puzzlepiece.extension.fill")
                Image(systemName: "puzzlepiece.fill")
            }
            .font(.system(size: 24, weight: .bold))
            .padding(.horizontal, 14)
            .frame(height: 58)
            .foregroundStyle(OceanKeyTheme.secondaryText)
            .background(OceanKeyTheme.surface.opacity(0.82), in: RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    SummaryHeader(counts: SummaryCounts(pending: 10, ready: 10, open: 0))
        .background(OceanKeyTheme.background)
}
