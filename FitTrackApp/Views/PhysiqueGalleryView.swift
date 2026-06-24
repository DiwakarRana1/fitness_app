import SwiftUI
import SwiftData
import PhotosUI

struct PhysiqueGalleryView: View {
    @Query(sort: \PhysiqueEntry.date, order: .reverse) private var entries: [PhysiqueEntry]
    @Environment(\.modelContext) private var modelContext
    
    @State private var weightInput: String = ""
    @State private var notesInput: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Log Physique Entry")) {
                        HStack {
                            Text("Weight:")
                            TextField("e.g. 75.0", text: $weightInput)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                            Text("kg")
                        }
                        
                        TextField("Notes (e.g. feeling strong)", text: $notesInput)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                Image(systemName: "camera")
                                Text(selectedPhotoData != nil ? "Photo Selected!" : "Select Progress Photo")
                            }
                        }
                        .onChange(of: selectedPhotoItem) { oldValue, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    selectedPhotoData = data
                                }
                            }
                        }
                        
                        Button("Log Entry") {
                            logEntry()
                        }
                        .disabled(weightInput.isEmpty)
                    }
                    
                    Section(header: Text("Progress History")) {
                        if entries.isEmpty {
                            Text("No history yet")
                                .foregroundColor(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(entries) { entry in
                                        VStack(alignment: .leading) {
                                            if let photoData = entry.photoData {
                                                DataImage(data: photoData)
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(8)
                                                    .clipped()
                                            } else {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.secondary.opacity(0.2))
                                                    .frame(width: 120, height: 120)
                                                    .overlay(
                                                        Image(systemName: "photo")
                                                            .foregroundColor(.secondary)
                                                    )
                                            }
                                            Text("\(String(format: "%.1f", entry.bodyWeight)) kg")
                                                .bold()
                                            Text(entry.date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(width: 120)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Physique")
        }
    }
    
    private func logEntry() {
        guard let weight = Double(weightInput) else { return }
        let entry = PhysiqueEntry(date: Date(), bodyWeight: weight, photoData: selectedPhotoData, notes: notesInput)
        modelContext.insert(entry)
        
        // Reset Inputs
        weightInput = ""
        notesInput = ""
        selectedPhotoItem = nil
        selectedPhotoData = nil
    }
}

// Multiplatform helper to load image data safely
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
