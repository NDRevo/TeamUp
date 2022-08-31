//
//  CalendarViewController.swift
//  TeamUp
//
//  Created by Noé Duran on 8/7/22.
//

import Foundation
import SwiftUI
import EventKit
import EventKitUI

struct CalendarViewController: UIViewControllerRepresentable {

    var event: TUEvent
    var store: EKEventStore
    @Binding var isShowingCalendarView: Bool

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventViewController = EKEventEditViewController()

        eventViewController.event = EKEvent(eventStore: store)
        eventViewController.eventStore = store

        eventViewController.event!.startDate = event.eventStartDate
        eventViewController.event!.endDate = event.eventEndDate
        eventViewController.event!.location = event.eventLocation
        eventViewController.event!.title = event.eventName
        eventViewController.event!.notes = event.eventDescription

        eventViewController.editViewDelegate = context.coordinator
        return eventViewController
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> CalendarViewController.Coordinator {
        return Coordinator(isShowingCalendarView: $isShowingCalendarView)
    }

    class Coordinator : NSObject, EKEventEditViewDelegate {

        @Binding var isShowingCalendarView: Bool

        init(isShowingCalendarView: Binding<Bool>) {
            _isShowingCalendarView = isShowingCalendarView
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            switch action {
            case .canceled:
                ///Bug: **Publishing changes from within view updates is not allowed, this will cause undefined behavior.
                isShowingCalendarView = false
            case .saved:
                do {
                    try controller.eventStore.save(controller.event!, span: .thisEvent, commit: true)
                }
                catch {
                    print("Event couldn't be saved")
                    //MARK: Create Alert?
                }
                isShowingCalendarView = false
            case .deleted:
                isShowingCalendarView = false
            @unknown default:
                isShowingCalendarView = false
            }
        }
    }
}
