import SwiftUI

struct MacroProgressBar: View {
    var title: String
    var current: Int
    var target: Int
    var color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.caption)
                    .bold()
                Spacer()
                Text("\(current) / \(target)g")
                    .font(.caption)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 8)
                        .opacity(0.3)
                        .foregroundColor(color)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .foregroundColor(color)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    MacroProgressBar(title: "Protein", current: 140, target: 180, color: .blue)
        .padding()
}
