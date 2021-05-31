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

            Color.secondaryBackground

            HStack(spacing: .zero) {
                ZStack {
                    Text("100").opacity(0)
                    Text("\(drill.attempts)")
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .font(Font.title.weight(.semibold))
                .foregroundColor(.primaryElement)

                Text(drill.title.uppercased())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                    .font(Font.headline.weight(.bold))
                    .foregroundColor(.secondaryElement)

                VStack(spacing: .iconsSpacing) {
                    failableIcon
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(.customRed)
                        .opacity(drill.isFailable ? 1 : 0)

                    Spacer()

                    statisticsButton
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(.customGreen)
                }
                .padding()
            }
        }
        .cornerRadius(.cornerRadius)
        .onTapGesture {
            manager.start(drill: drill)
        }
    }

    private var failableIcon: some View {
        Image(systemName: "xmark.seal")
            .font(Font.title3.weight(.regular))
            .imageScale(.small)
    }

    private var statisticsButton: some View {
        NavigationLink(
            destination: StatisticsView(drill: drill),
            label: {
                Image(systemName: "chart.bar.xaxis")
                    .imageScale(.large)
            }
        )
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat {
        10
    }

    static var iconsSpacing: CGFloat {
        4
    }
}

struct DrillView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))
    static var drill = manager.drills.first!

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            DrillView(drill: drill)
                .environmentObject(manager)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
