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
                        .textFieldStyle(CreateDrillTextFieldStyle())
                        .padding()
                        .padding(.top)

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

                            infoButton
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .customGreen))
                    .padding(.horizontal)

                    Divider()

                    failableHelpView

                    Spacer()
                }
            }
            .navigationBarTitle("Create Drill", displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }

    @State private var showInfo = false

    private var infoButton: some View {
        Button(
            action: {
                withAnimation {
                    showInfo.toggle()
                }
            },
            label: {
                Image(systemName: "info.circle")
                    .padding(.horizontal)
                    .imageScale(.large)
                    .foregroundColor(.secondaryElement)
            }
        )
    }

    private var failableHelpView: some View {
        Text("Drill will finish when shot is missed")
            .padding()
            .background(Color.primaryBackground)
            .font(.caption)
            .foregroundColor(.primaryElement)
            .cornerRadius(.failableHelpViewCornerRadius)
            .padding()
            .opacity(showInfo ? 1.0 : 0)
            .onTapGesture {
                withAnimation {
                    showInfo.toggle()
                }
            }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            isCreatingDrill = false
        }
    }

    private var saveButton: some View {
        Button("Save") {
            if title.isEmpty {
                title = "Drill Title"
            }

            withAnimation {
                manager.addDrill(title: title, attempts: Int(attempts), isFailable: isFailable)
            }

            isCreatingDrill = false
        }
    }
}

private extension CGFloat {
    static var spacing: CGFloat {
        16
    }

    static var failableHelpViewCornerRadius: CGFloat {
        25
    }
}

private struct CreateDrillTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding(padding)
            .background(Color.primaryBackground)
            .foregroundColor(.primaryElement)
            .accentColor(.primaryElement)
            .cornerRadius(cornerRadius)
    }

    private var cornerRadius: CGFloat {
        10
    }

    private var padding: CGFloat {
        10
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
