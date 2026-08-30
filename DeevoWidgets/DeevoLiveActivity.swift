import ActivityKit
import WidgetKit
import SwiftUI

struct DeevoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeevoActivityAttributes.self) { context in
            LockScreenLiveActivityView(state: context.state)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ArtworkView(urlString: context.state.artworkURL)
                        .frame(width: 44, height: 44)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.title).font(.caption).bold().lineLimit(1)
                        Text(context.state.artist).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.elapsed, total: max(context.state.duration, 1))
                        .tint(.orange)
                }
            } compactLeading: {
                ArtworkView(urlString: context.state.artworkURL)
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(.orange)
            } minimal: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

private struct ArtworkView: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            Color.gray.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// Présentation sur écran verrouillé (au-dessus des notifications) : reprend
// le même esprit que l'écran plein de l'app (pochette + titre/artiste +
// progression + play/pause), mais en compact.
private struct LockScreenLiveActivityView: View {
    let state: DeevoActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(urlString: state.artworkURL)
                .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text(state.title).font(.subheadline).bold().lineLimit(1)
                Text(state.artist).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                ProgressView(value: state.elapsed, total: max(state.duration, 1))
                    .tint(.orange)
            }

            Spacer()

            Image(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.orange)
        }
        .padding()
    }
}
