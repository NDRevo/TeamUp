//
//  EventDescriptionView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventDescriptionView
//INFO: Displays the description of the event
struct EventDescriptionView: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .center ,spacing: 4){
                Image(systemName: "doc.plaintext")
                    .font(.headline)
                    .frame(width: 15)
                    .foregroundColor(.blue)
                Text("Description")
                    .font(.system(.body, design: .monospaced, weight: .medium))
            }
            TextField(text: $viewModel.editedDescription, axis: .vertical) {
                Text((viewModel.editedDescription.isEmpty && viewModel.isEditingEventDetails) ? "Event Description" : viewModel.event.eventDescription)
                        .foregroundColor((viewModel.editedDescription.isEmpty && viewModel.isEditingEventDetails) ? .gray : .primary)
                
            }
            .font(.system(.body, design: .rounded, weight: .regular))
            .lineLimit(nil)
            .disabled(!viewModel.isEditingEventDetails)
            .onChange(of: viewModel.editedDescription) { _ in
                viewModel.editedDescription = String(viewModel.editedDescription.prefix(350))
            }
            .onChange(of: viewModel.isEditingEventDetails) { _ in
                viewModel.editedDescription = (viewModel.editedDescription.isEmpty && viewModel.isEditingEventDetails) ? WordConstants.eventDescription : viewModel.event.eventDescription
            }
            .onAppear {
                viewModel.editedDescription = (viewModel.editedDescription.isEmpty && viewModel.isEditingEventDetails) ? WordConstants.eventDescription : viewModel.event.eventDescription
            }

            if viewModel.isEditingEventDetails {
                Text("\(350 - viewModel.editedDescription.count) characters left.")
                    .font(.system(.footnote, design: .monospaced, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EventDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        EventDescriptionView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
