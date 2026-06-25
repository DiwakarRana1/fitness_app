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
    
    // Body Dimensions
    @State private var heightInput: String = ""
    @State private var chestInput: String = ""
    @State private var waistInput: String = ""
    @State private var hipsInput: String = ""
    @State private var bicepsInput: String = ""
    @State private var thighsInput: String = ""
    @State private var showMeasurementsForm = false
    
    // AI Vision Trigger states
    @State private var isAnalyzing = false
    @State private var showAIReport = false
    @State private var aiReportText = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Log Physique & Weight")) {
                    HStack {
                        Text("Weight:")
                        TextField("e.g. 75.0", text: $weightInput)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                        Text("kg")
                    }
                    
                    TextField("Notes / How you feel", text: $notesInput)
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "camera")
                            Text(selectedPhotoData != nil ? "Photo Selected!" : "Select Progress Photo")
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedPhotoData = data
                            }
                        }
                    }
                }
                
                Section(header: Text("Manual Body Measurements")) {
                    Toggle("Add Tape Measurements", isOn: $showMeasurementsForm)
                    
                    if showMeasurementsForm {
                        Group {
                            HStack {
                                Text("Height (cm):")
                                TextField("Optional", text: $heightInput)
                            }
                            HStack {
                                Text("Chest (in):")
                                TextField("Optional", text: $chestInput)
                            }
                            HStack {
                                Text("Waist (in):")
                                TextField("Optional", text: $waistInput)
                            }
                            HStack {
                                Text("Hips (in):")
                                TextField("Optional", text: $hipsInput)
                            }
                            HStack {
                                Text("Biceps (in):")
                                TextField("Optional", text: $bicepsInput)
                            }
                            HStack {
                                Text("Thighs (in):")
                                TextField("Optional", text: $thighsInput)
                            }
                        }
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    }
                }
                
                Button(action: logEntry) {
                    Text("Log Physique Entry")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(weightInput.isEmpty)
                
                Section(header: Text("AI Vision Progress Analysis")) {
                    if entries.count < 2 {
                        Text("Please log at least 2 entries with progress photos to run AI analysis.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        Button(action: runAIAnalysis) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                                Text(isAnalyzing ? "Analyzing Images..." : "Run AI Progress Analysis")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        .disabled(isAnalyzing)
                    }
                }
                
                Section(header: Text("Progress History")) {
                    if entries.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(entries) { entry in
                                    VStack(alignment: .leading, spacing: 6) {
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
                                        
                                        // Show logged manual measurements if present
                                        if let chest = entry.chest {
                                            Text("Chest: \(String(format: "%.1f", chest))\"")
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                        if let waist = entry.waist {
                                            Text("Waist: \(String(format: "%.1f", waist))\"")
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(width: 120)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Physique")
            .sheet(isPresented: $showAIReport) {
                NavigationStack {
                    ScrollView {
                        Text(aiReportText)
                            .padding()
                            .textSelection(.enabled)
                    }
                    .navigationTitle("AI Progress Report")
                    .toolbar {
                        Button("Done") { showAIReport = false }
                    }
                }
            }
        }
    }
    
    private func logEntry() {
        guard let weight = Double(weightInput) else { return }
        
        let height = Double(heightInput)
        let chest = Double(chestInput)
        let waist = Double(waistInput)
        let hips = Double(hipsInput)
        let biceps = Double(bicepsInput)
        let thighs = Double(thighsInput)
        
        let entry = PhysiqueEntry(
            date: Date(),
            bodyWeight: weight,
            photoData: selectedPhotoData,
            notes: notesInput,
            height: height,
            chest: chest,
            waist: waist,
            hips: hips,
            biceps: biceps,
            thighs: thighs
        )
        
        modelContext.insert(entry)
        
        // Reset Inputs
        weightInput = ""
        notesInput = ""
        selectedPhotoItem = nil
        selectedPhotoData = nil
        heightInput = ""
        chestInput = ""
        waistInput = ""
        hipsInput = ""
        bicepsInput = ""
        thighsInput = ""
        showMeasurementsForm = false
    }
    
    private func runAIAnalysis() {
        isAnalyzing = true
        
        let entriesWithPhotos = entries.filter { $0.photoData != nil }
        guard entriesWithPhotos.count >= 2 else {
            isAnalyzing = false
            return
        }
        
        let current = entriesWithPhotos[0]
        let previous = entriesWithPhotos[1]
        
        Task {
            do {
                let report = try await AIService.shared.comparePhysiquePhotos(
                    currentPhoto: current.photoData!,
                    previousPhoto: previous.photoData!,
                    currentWeight: current.bodyWeight,
                    previousWeight: previous.bodyWeight
                )
                await MainActor.run {
                    aiReportText = report
                    isAnalyzing = false
                    showAIReport = true
                }
            } catch {
                await MainActor.run {
                    aiReportText = "Failed to generate report: \(error.localizedDescription)\n\nPlease verify that your API key is correctly configured in Settings."
                    isAnalyzing = false
                    showAIReport = true
                }
            }
        }
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
