//
//  CreateDrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-20.
//

import ComposableArchitecture
import SwiftUI

struct CreateDrillView: View {
    let store: StoreOf<CreateDrill>

    @EnvironmentObject var drillStore: StoreManager

    @Binding var isCreatingDrill: Bool

    @State private var title = ""
    @State private var attempts = 1.0
    @State private var isFailable = false

    @State private var showInfo = false

    var body: some View {
        WithViewStore(store) { _ in
            NavigationView {
                ZStack {
                    Color.secondaryBackground
                        .ignoresSafeArea()

                    VStack(spacing: .spacing) {
                        TextFieldView(title: $title)

                        Slider(value: $attempts, in: 1...100, step: 1.0)
                            .padding(.horizontal)
                            .accentColor(.customBlue)
                            .accessibility(identifier: "createDrillView_attemptsSlider")

                        Text("\(Int(attempts))")
                            .padding(.bottom)
                            .font(.headline)
                            .foregroundColor(.primaryElement)
                            .accessibility(identifier: "createDrillView_attemptsText")

                        Divider()
                            .padding(.top)

                        HStack {
                            Text("Failable")
                                .font(Font.body.weight(.semibold))

                            infoButton

                            Toggle("", isOn: $isFailable)
                                .toggleStyle(SwitchToggleStyle(tint: .customBlue))
                                .accessibility(identifier: "createDrillView_failableToggle")

                        }
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
    }

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
        .accessibility(identifier: "createDrillView_infoButton")
    }

    private var failableHelpView: some View {
        Text("Drill will finish when first shot is missed")
            .padding()
            .background(Color.primaryBackground)
            .font(.footnote)
            .foregroundColor(.primaryElement)
            .cornerRadius(.failableHelpViewCornerRadius)
            .padding()
            .opacity(showInfo ? 1.0 : 0)
            .onTapGesture {
                withAnimation {
                    showInfo.toggle()
                }
            }
            .accessibility(identifier: "createDrillView_failableHelpView")
    }

    private var cancelButton: some View {
        Button("Cancel") {
            isCreatingDrill = false
        }
        .accessibility(identifier: "createDrillView_cancelButton")
    }

    private var saveButton: some View {
        Button("Save") {
            if title.isEmpty {
                title = "Drill Title"
            }

            withAnimation {
                drillStore.addDrill(title: title, attempts: Int(attempts), isFailable: isFailable)
            }

            isCreatingDrill = false
        }
        .accessibility(identifier: "createDrillView_saveButton")
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

private struct TextFieldView: View {
    @Binding var title: String

    var body: some View {
        TextField("Drill Title", text: $title)
            .accentColor(.primaryElement)
            .foregroundColor(.primaryElement)
            .padding(Self.innerPadding)
            .background(Color.primaryBackground)
            .cornerRadius(Self.cornerRadius)
            .padding()
            .padding(.top)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

private extension TextFieldView {
    static let cornerRadius: CGFloat = 8
    static let innerPadding: CGFloat = 12
}

// swiftlint:disable force_try
struct CreateDrillView_Previews: PreviewProvider {
    static var store = StoreManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        CreateDrillView(
            store: Store(initialState: CreateDrill.State(), reducer: CreateDrill()),
            isCreatingDrill: .constant(true)
        )
        .environmentObject(store)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
