//
//  View+Ext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/11/22.
//
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func allowToPresentCalendar(with data: EventDetailViewModel) -> some View {
        modifier(onTapPresentCalendar(viewModel: data))
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct onTapPresentCalendar: ViewModifier {
    
    @ObservedObject var viewModel: EventDetailViewModel
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                Task {
                    await viewModel.checkCalendarAcces()
                }
            }
            .sheet(isPresented: $viewModel.isShowingCalendarView) {
                CalendarViewController(event: viewModel.event, store: viewModel.store, isShowingCalendarView: $viewModel.isShowingCalendarView)
                
            }
    }
}
