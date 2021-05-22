//
//  CreateDrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-20.
//

import SwiftUI

struct CreateDrillView: View {
    @EnvironmentObject var manager: DrillManager

    @Binding var isCreatingDrill: Bool

    @State private var title = ""
    @State private var attempts = 1.0
    @State private var isFailable = false

    private var cancelButton: some View {
        Button("Cancel") {
            isCreatingDrill = false
        }
    }

    private var saveButton: some View {
        Button("Save") {
            manager.addDrill(title: title, attempts: Int(attempts), isFailable: isFailable)
            isCreatingDrill = false
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Drill Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Slider(value: $attempts, in: 1...100, step: 1.0)
                    .padding(.horizontal)

                Text(String(Int(attempts)))

                Toggle("Failable", isOn: $isFailable)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitle("Create Drill", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
}

struct CreateDrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var previews: some View {
        CreateDrillView(isCreatingDrill: .constant(true))
            .environmentObject(manager)
    }
}
