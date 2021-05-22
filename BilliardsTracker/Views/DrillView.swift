//
//  DrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct DrillView: View {
    @EnvironmentObject var manager: DrillManager
    private let drill: Drill

    init(drill: Drill) {
        self.drill = drill
    }

    var body: some View {
        let navigationBinding = Binding<Bool>(
                                    get: { manager.runState == .running && manager.selectedDrill == drill },
                                    set: { manager.runState = $0 ? .running : .stopped }
                                ).removeDuplictates()

        ZStack {
            NavigationLink(destination: RunningView(drill: drill, startDate: manager.startDate),
                           isActive: navigationBinding) { EmptyView() }.disabled(true)

            Color(red: 0/255.0, green: 184/255.0, blue: 148/255.0)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))

            VStack {
                Text(drill.title)
                    .foregroundColor(.white)
                    .font(Font.largeTitle.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .imageScale(.medium)
                    Text("\(drill.attempts)")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
                .padding(4)

                Image(systemName: "xmark.seal")
                    .font(Font.title3.weight(.black))
                    .foregroundColor(.red)
                    .isHidden(!drill.isFailable)

                HStack {
                    deleteButton
                    Spacer()
                    statisticsButton
                }
                .padding(.top)
                .foregroundColor(.white)
            }
            .padding()

        }.onTapGesture {
            manager.start(drill: drill)
        }
    }

    @State private var shouldDelete = false

    private var deleteButton: some View {
        Button {
            shouldDelete = true
        } label: {
            Image(systemName: "trash")
                .imageScale(.large)
        }
        .alert(isPresented: $shouldDelete, content: {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want to delete this drill?"),
                primaryButton: .destructive(Text("Delete")) {
                    manager.delete(drill: drill)
                },
                secondaryButton: .cancel()
            )
        })
    }

    private var statisticsButton: some View {
        NavigationLink(
            destination: StatisticsView(drill: drill),
            label: {
                Image(systemName: "chart.bar.doc.horizontal")
                    .imageScale(.large)
            }
        )
    }

}

extension View {
    /// Hide or show the view based on a boolean value.
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }
}

struct DrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))
    static var drill = manager.drills.first!

    static var previews: some View {
        DrillView(drill: drill)
            .environmentObject(manager)
            .aspectRatio(2.0, contentMode: .fit)
            .padding()
    }
}
