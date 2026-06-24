import SwiftUI
import SwiftData

struct PhysiqueGalleryView: View {
    @Query(sort: \PhysiqueEntry.date) private var entries: [PhysiqueEntry]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                // Weight Chart here
                // Metric Logger here
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(entries) { entry in
                            if let photoData = entry.photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Physique")
        }
    }
}

#Preview {
    PhysiqueGalleryView()
}
