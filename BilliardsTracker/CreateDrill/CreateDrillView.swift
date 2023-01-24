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

    init(store: StoreOf<CreateDrill>) {
        self.store = store
    }

    @State private var showInfo = false

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    Color.secondaryBackground
                        .ignoresSafeArea()

                    VStack(spacing: Self.spacing) {
                        TitleTextField(title: viewStore.binding(\.$title))

                        Slider(
                            value: viewStore.binding(\.$attempts),
                            in: 1...100,
                            step: 1.0
                        )
                        .padding(.horizontal)
                        .accentColor(.customBlue)

                        Text("\(Int(viewStore.attempts))")
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

                            Toggle("", isOn: viewStore.binding(\.$isFailable))
                                .toggleStyle(SwitchToggleStyle(tint: .customBlue))
                        }
                        .padding(.horizontal)

                        Divider()

                        failableHelpView

                        Spacer()
                    }
                }
                .navigationBarTitle("Create Drill", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button("Cancel") {
                            viewStore.send(.cancelButtonDidTap)
                        },
                    trailing:
                        Button("Save") {
                            var title = viewStore.title

                            if title.isEmpty {
                                title = "Drill Title"
                            }

                            withAnimation {
                                drillStore.addDrill(
                                    title: title,
                                    attempts: Int(viewStore.attempts),
                                    isFailable: viewStore.isFailable
                                )
                            }

                            viewStore.send(.saveButtonDidTap)
                        }
                )
            }
        }
        .accessibility(identifier: "createDrillView")
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
            .cornerRadius(Self.failableHelpViewCornerRadius)
            .padding()
            .opacity(showInfo ? 1.0 : 0)
            .onTapGesture {
                withAnimation {
                    showInfo.toggle()
                }
            }
            .accessibility(identifier: "createDrillView_failableHelpView")
    }
}

private extension CreateDrillView {
    static let spacing: CGFloat = 16
    static let failableHelpViewCornerRadius: CGFloat = 25
}

private struct TitleTextField: View {
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

private extension TitleTextField {
    static let cornerRadius: CGFloat = 8
    static let innerPadding: CGFloat = 12
}

// swiftlint:disable force_try
struct CreateDrillView_Previews: PreviewProvider {
    static var store = StoreManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var previews: some View {
        CreateDrillView(
            store: Store(initialState: CreateDrill.State(), reducer: CreateDrill())
        )
        .environmentObject(store)
    }
}
// swiftlint:enable force_try
