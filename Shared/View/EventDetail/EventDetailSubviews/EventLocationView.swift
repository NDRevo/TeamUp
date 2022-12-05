//
//  EventLocationView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventLocationView
//INFO: Section that displays the location of event. On tap leads to Apple Maps or Discord
struct EventLocationView: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10){
                EventLocationHeader(viewModel: viewModel)

                if !(viewModel.eventLocationType == .discord && !viewModel.isEditingEventDetails) {
                    VStack(alignment: .leading, spacing: 4){
                        if let eventLocationTitle = viewModel.event.eventLocationTitle {
                            if !viewModel.isEditingEventDetails {
                                Text(eventLocationTitle)
                                    .bold()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                        }
                        HStack(spacing: viewModel.editedLocationTypePicked == .discord ? 0 : nil) {
                            if viewModel.isEditingEventDetails {
                                if viewModel.editedLocationTypePicked == .irl {
                                    Image(systemName: "magnifyingglass")
                                        .onTapGesture {
                                            viewModel.isPresentingMap = true
                                        }
                                        .foregroundColor(.blue)
                                } else {
                                    Text("discord.gg/")
                                        .foregroundColor(.gray)
                                }
                            }

                            TextField(text: $viewModel.editedLocationName) {
                                Text((viewModel.editedLocationName.isEmpty && viewModel.isEditingEventDetails) ? viewModel.editedLocationTypePicked == .irl ? "Address" : "" : viewModel.editedLocationTypePicked == .discord ? String(viewModel.event.eventLocation.split(separator: "/", omittingEmptySubsequences: true).last ?? "") : viewModel.event.eventLocation)
                                    .foregroundColor((viewModel.editedLocationName.isEmpty && viewModel.isEditingEventDetails) ? .gray : .primary)
                            }
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .minimumScaleFactor(0.85)
                            .disabled(!viewModel.isEditingEventDetails)
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.vertical, viewModel.eventLocationType == .discord ? 14 : 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $viewModel.isPresentingMap, content: {
            SearchMapView(eventLocationTitle: $viewModel.editedLocationTitle, eventLocation: $viewModel.editedLocationName)
        })
        .onChange(of: viewModel.editedLocationTypePicked) { _ in
            viewModel.editedLocationTitle = viewModel.eventLocationType == .irl ? viewModel.editedLocationTypePicked == .discord ? "" : viewModel.event.eventLocationTitle  : ""
            
            viewModel.editedLocationName = viewModel.eventLocationType == .discord ? viewModel.editedLocationTypePicked == .discord ? String(viewModel.event.eventLocation.split(separator: "/", omittingEmptySubsequences: true)[1]) : "" : viewModel.editedLocationTypePicked == .irl ? viewModel.event.eventLocation : ""
        }
        .onChange(of: viewModel.isEditingEventDetails) { _ in
            viewModel.editedLocationName = viewModel.eventLocationType == .discord ? String(viewModel.event.eventLocation.split(separator: "/", omittingEmptySubsequences: true)[1]) : viewModel.event.eventLocation
        }
        .onTapGesture {
            if !viewModel.isEditingEventDetails {
                if viewModel.event.eventLocation.contains("discord.gg"){
                    if let url = URL(string: "https://\(viewModel.event.eventLocation)") {
                        UIApplication.shared.open(url)
                    }
                } else {
                    var url = URL(string: viewModel.event.eventLocation)
                    if viewModel.event.eventLocation.starts(with: "discord.gg") {
                        url = URL(string: "https://\(viewModel.event.eventLocation)")
                        UIApplication.shared.open(url!)
                    } else{
                        url = URL(string: "maps://?address=\(viewModel.event.eventLocation.replacingOccurrences(of: " ", with: "%20"))&q=\(viewModel.event.eventLocationTitle?.replacingOccurrences(of: " ", with: "%20") ?? "")")
                        UIApplication.shared.open(url!)
                    }
                }
            }
        }
    }
}

struct EventLocationView_Previews: PreviewProvider {
    static var previews: some View {
        EventLocationView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}

struct EventLocationHeader: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(alignment: .center){
            HStack(spacing: 4){
                Image(systemName: (viewModel.event.eventLocation.starts(with: "discord.gg") && !viewModel.isEditingEventDetails) ? "link" : DetailItem.location.getSystemImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .foregroundColor(.blue)
                    
                Text( (viewModel.eventLocationType == .discord && !viewModel.isEditingEventDetails) ? "Discord" : DetailItem.location.getTextHeading())
                    .fontWeight((viewModel.eventLocationType == .discord && !viewModel.isEditingEventDetails) ? .semibold : nil)
            }
            Spacer()
            if viewModel.isEditingEventDetails {
                Picker("", selection: $viewModel.editedLocationTypePicked) {
                    ForEach(Locations.allCases, id: \.self){ location in
                        Button {
                            viewModel.editedLocationTypePicked = location
                        } label: {
                            Text(location.rawValue)
                        }
                    }
                }
                //Needs a smaller frame height to prevent header from being pushed down
                .frame(height: 20)
                .labelsHidden()
            }
        }
    }
}
