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
                            if let photoData = entry.photoData {
                                DataImage(data: photoData)
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

struct DataImage: View {
    var data: Data
    
    var body: some View {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
        }
        #else
        Color.clear
        #endif
    }
}

#Preview {
    PhysiqueGalleryView()
}
