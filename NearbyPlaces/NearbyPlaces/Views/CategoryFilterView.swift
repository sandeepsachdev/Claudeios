import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: PlaceCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PlaceCategory.allCases) { category in
                    CategoryChip(category: category, isSelected: selectedCategory == category)
                        .onTapGesture { selectedCategory = category }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

struct CategoryChip: View {
    let category: PlaceCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.system(size: 13, weight: .semibold))
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(isSelected ? category.color : Color(.systemGray6))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(22)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
