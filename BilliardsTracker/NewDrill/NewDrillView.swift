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

                        Section {
                            HStack {
                                ListItemLabel(title: "Shots", imageName: "checklist")
                                    .foregroundColor(.customBlue)

                                Spacer()

                                Button {
                                    withAnimation {
                                        isShowingPicker.toggle()
                                    }
                                } label: {
                                    HStack(spacing: Self.shotCountSectionButtonSpacing) {
                                        Text("\(viewStore.shotCount)")

                                        Image(systemName: "chevron.up.chevron.down")
                                            .imageScale(.small)
                                    }
                                    .foregroundColor(.secondaryElement)
                                }
                            }

                            if isShowingPicker {
                                Picker("Set Shot Count", selection: viewStore.binding(\.$shotCount)) {
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
                                ListItemLabel(title: "Continuous", imageName: "repeat")
                                    .foregroundColor(.customRed)
                            }
                            .toggleStyle(.switch)
                            .tint(.customBlue)
                        } footer: {
                            Text("Deselecting this option will end the drill once a shot is missed.")
                        }
                    }
                    .listStyle(.insetGrouped)
                    .environment(\.defaultMinListRowHeight, Self.defaultMinListRowHeight)
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
    @ScaledMetric private var scale: CGFloat = 1

    let title: String
    let imageName: String

    var body: some View {
        Label {
            Text(title)
                .foregroundColor(.primaryElement)
        } icon: {
            ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .frame(
                        width: Self.imageBackgroundSize.width * scale,
                        height: Self.imageBackgroundSize.height * scale
                    )

                Image(systemName: imageName)
                    .imageScale(.medium)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Constants

private extension ListItemLabel {
    static let cornerRadius: CGFloat = 6
    static let imageBackgroundSize: CGSize = CGSize(width: 28, height: 28)
}

private extension NewDrillView {
    static let defaultMinListRowHeight: CGFloat = 50
    static let shotCountSectionButtonSpacing: CGFloat = 4
}

// MARK: - Previews

struct NewDrillView_Previews: PreviewProvider {
    static var previews: some View {
        NewDrillView(store: Store(initialState: NewDrill.State(), reducer: NewDrill()))
    }
}
