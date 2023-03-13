//
//  NewDrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-20.
//

import ComposableArchitecture
import SwiftUI

struct NewDrillView: View {
    let store: StoreOf<NewDrill>

    @State private var isShowingPicker = false

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    Color.secondaryBackground
                        .ignoresSafeArea()

                    List {
                        TextField("Drill Title", text: viewStore.binding(\.$title))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, Self.textFieldVerticalPadding)

                        Section {
                            HStack {
                                ListItemLabel(title: "Attempts", imageName: "checklist", fillColor: .customBlue)

                                Spacer()

                                Button {
                                    withAnimation {
                                        isShowingPicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: Self.attemptsSectionButtonSpacing) {
                                        Text("\(viewStore.attempts)")

                                        Image(systemName: "chevron.up.chevron.down")
                                            .imageScale(.small)
                                    }
                                    .foregroundColor(.secondaryElement)
                                }
                            }

                            if isShowingPicker {
                                Picker("Set attempts", selection: viewStore.binding(\.$attempts)) {
                                    ForEach(1..<101) { i in
                                        Text("\(i)")
                                            .tag(i)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                        }

                        Section {
                            Toggle(isOn: viewStore.binding(\.$isContinuous)) {
                                ListItemLabel(title: "Continuous", imageName: "repeat", fillColor: .customRed)
                            }
                            .toggleStyle(.switch)
                            .tint(.customBlue)
                        } footer: {
                            Text("Deselecting this option will end the drill once the first shot is missed.")
                        }
                    }
                    .listStyle(.insetGrouped)
                    .environment(\.defaultMinListRowHeight, .zero)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            viewStore.send(.cancelButtonDidTap)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            viewStore.send(.saveButtonDidTap, animation: .default)
                        }
                    }
                }
                .navigationTitle("New Drill")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

private struct ListItemLabel: View {
    let title: String
    let imageName: String
    let fillColor: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .fill(fillColor)
                    .frame(width: Self.imageSize.width, height: Self.imageSize.height)

                Image(systemName: imageName)
                    .imageScale(.medium)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Constants

private extension ListItemLabel {
    static let cornerRadius: CGFloat = 4
    static let imageSize: CGSize = CGSize(width: 28, height: 28)
}

private extension NewDrillView {
    static let attemptsSectionButtonSpacing: CGFloat = 4
    static let textFieldVerticalPadding: CGFloat = 2
}

// MARK: - Previews

struct NewDrillView_Previews: PreviewProvider {
    static var previews: some View {
        NewDrillView(store: Store(initialState: NewDrill.State(), reducer: NewDrill()))
    }
}
