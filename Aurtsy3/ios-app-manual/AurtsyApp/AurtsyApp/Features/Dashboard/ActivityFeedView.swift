import SwiftUI

struct ActivityFeedView: View {
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if networkManager.isLoadingFeed {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button(action: refreshFeed) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if networkManager.activityFeed.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 12) {
                    ForEach(networkManager.activityFeed) { item in
                        FeedItemRow(item: item)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            refreshFeed()
        }
    }
    
    func refreshFeed() {
        if let child = networkManager.selectedChild {
            networkManager.fetchActivityFeed(childId: child.id)
        }
    }
}

struct FeedItemRow: View {
    let item: FeedItem
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(UIColor.systemBackground))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 14))
                        .foregroundColor(item.color)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(item.date, style: .time)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().stroke(Color.primary.opacity(0.2)))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.03))
        )
    }
}
