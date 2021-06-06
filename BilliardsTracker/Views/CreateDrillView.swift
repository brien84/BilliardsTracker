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

    var body: some View {
        NavigationView {
            ZStack {
                Color.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: .spacing) {
                    TextField("Drill Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .padding(.top)
                        .foregroundColor(.primaryElement)

                    Slider(value: $attempts, in: 1...100, step: 1.0)
                        .padding(.horizontal)
                        .accentColor(.customGreen)

                    Text("\(Int(attempts))")
                        .padding(.bottom)
                        .font(.headline)
                        .foregroundColor(.primaryElement)

                    Divider()
                        .padding(.top)

                    Toggle(isOn: $isFailable) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("Failable")
                                .font(Font.body.weight(.semibold))

                            Button(action: {}) {
                                Image(systemName: "info.circle")
                                    .imageScale(.large)
                            }
                            .padding(.horizontal)
                            .foregroundColor(.secondaryElement)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .customGreen))
                    .padding(.horizontal)

                    Divider()

                    Spacer()
                }
            }
            .navigationBarTitle("Create Drill", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            isCreatingDrill = false
        }
    }

    private var saveButton: some View {
        Button("Save") {
            if title == "" {
                title = "Drill Title"
            }

            manager.addDrill(title: title, attempts: Int(attempts), isFailable: isFailable)
            isCreatingDrill = false
        }
    }
}

private extension CGFloat {
    static var spacing: CGFloat {
        16
    }
}

struct CreateDrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        CreateDrillView(isCreatingDrill: .constant(true))
            .environmentObject(manager)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
