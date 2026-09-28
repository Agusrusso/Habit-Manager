import SwiftUI

struct AchievementsView: View {
    @State var viewModel: GamificationViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = viewModel.profile {
                        userLevelCard(profile: profile)
                    }
                    
                    categoryFilterSection
                    
                    badgesGridSection
                }
                .padding()
            }
            .navigationTitle("Logros")
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(item: $viewModel.selectedAchievementForDetail) { achievement in
                AchievementDetailSheet(achievement: achievement)
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.visible)
            }
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Level & XP Header Card
    private func userLevelCard(profile: UserGamificationProfile) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("NIVEL \(profile.level)")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                    
                    Text(profile.levelTitle)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(profile.totalXP) XP")
                            .font(.headline.bold())
                    }
                    
                    Text("\(profile.unlockedAchievementsCount)/\(profile.totalAchievementsCount) insignias")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // XP Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Progreso de Nivel")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(profile.progressInLevel * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.18))
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(profile.progressInLevel), height: 10)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
    
    // MARK: - Category Filter Chips
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "Todos", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                
                ForEach(AchievementCategory.allCases) { category in
                    categoryChip(title: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectedCategory = category
                    }
                }
            }
        }
    }
    
    private func categoryChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(uiColor: .secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Badges Grid
    private var badgesGridSection: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.filteredAchievements) { achievement in
                BadgeCard(achievement: achievement) {
                    viewModel.selectedAchievementForDetail = achievement
                }
            }
        }
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let achievement: AchievementEntity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked
                            ? AnyShapeStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.gray.opacity(0.18))
                        )
                        .frame(width: 58, height: 58)
                        .shadow(color: achievement.isUnlocked ? .orange.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
                    
                    if achievement.isUnlocked {
                        Image(systemName: achievement.iconName)
                            .font(.title2)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
                
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(.subheadline.bold())
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    
                    Text(achievement.isUnlocked ? "Completado" : "\(achievement.currentProgress)/\(achievement.targetProgress)")
                        .font(.caption2)
                        .foregroundStyle(achievement.isUnlocked ? .green : .secondary)
                }
                
                // Progress or Reward pill
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("+\(achievement.xpReward) XP")
                        .font(.caption2.bold())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(achievement.isUnlocked ? Color.orange.opacity(0.15) : Color.gray.opacity(0.12))
                )
                .foregroundColor(achievement.isUnlocked ? .orange : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(achievement.isUnlocked ? Color.orange.opacity(0.2) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail Sheet
struct AchievementDetailSheet: View {
    let achievement: AchievementEntity
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? AnyShapeStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        : AnyShapeStyle(Color.gray.opacity(0.2))
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: achievement.isUnlocked ? .orange.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                
                Image(systemName: achievement.isUnlocked ? achievement.iconName : "lock.fill")
                    .font(.largeTitle)
                    .foregroundColor(achievement.isUnlocked ? .white : .secondary)
            }
            .padding(.top, 16)
            
            VStack(spacing: 6) {
                Text(achievement.title)
                    .font(.title3.bold())
                
                Text(achievement.category.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text(achievement.isUnlocked ? "¡Desbloqueado!" : "Progreso: \(achievement.currentProgress) de \(achievement.targetProgress)")
                        .font(.caption.bold())
                        .foregroundColor(achievement.isUnlocked ? .green : .secondary)
                    
                    Spacer()
                    
                    Text("+\(achievement.xpReward) XP")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
                
                ProgressView(value: achievement.progressPercentage)
                    .tint(achievement.isUnlocked ? .green : .orange)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding()
    }
}
