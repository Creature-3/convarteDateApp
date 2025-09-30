import SwiftUI

struct DateItem: Identifiable, Hashable {
    let id = UUID()
    var date: String
    var day: String
}

struct DatesSheetView: View {
    @State private var dates: [DateItem] = [
        DateItem(date: "05/12/2001", day: "tuesday"),
        DateItem(date: "11/03/2025", day: "friday"),
        DateItem(date: "20/05/2021", day: "thursday"),
        DateItem(date: "12/03/1997", day: "sunday"),
        DateItem(date: "03/08/2025", day: "monday")
    ]
    
    @State private var isEditing = false
    @State private var selectedItems: Set<DateItem> = []
    @State private var showClearConfirmation = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
              
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                
                ZStack {
                    Color.navyBlue.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        if dates.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.7))
                                Text("No History")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(selection: $selectedItems) {
                                ForEach(dates, id: \.self) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.date)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(item.day)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.vertical, 4)
                                    .listRowBackground(Color.navyBlue)
                                }
                            }
                            .scrollContentBackground(.hidden)
                            .listStyle(.plain)
                            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
                        }
                        
                        Divider().background(Color.white.opacity(0.4))
                        
                        HStack {
                            Button(isEditing ? "Cancel" : "Edit") {
                                withAnimation {
                                    isEditing.toggle()
                                    if !isEditing {
                                        selectedItems.removeAll()
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Clear") {
                                if isEditing {
                                    deleteSelectedItems()
                                } else {
                                    showClearConfirmation = true
                                }
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(Color.navyBlue)
                    }
                }
            }
        }
        .confirmationDialog("All items will be deleted. This action cannot be undone.",
                            isPresented: $showClearConfirmation,
                            titleVisibility: .visible) {
            Button("Clear History", role: .destructive) {
                dates.removeAll()
                selectedItems.removeAll()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func deleteSelectedItems() {
        dates.removeAll { selectedItems.contains($0) }
        selectedItems.removeAll()
    }
}

extension Color {
    static let navyblue = Color(hex: "0B2D4E")
    
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView: View {
    @State private var showSheet = true
    
    var body: some View {
        Color.white
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                DatesSheetView()
                    .presentationDetents([.fraction(0.4), .large])
                    .presentationDragIndicator(.hidden)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
