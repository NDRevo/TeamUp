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
        HStack{
            VStack(alignment: .leading, spacing: 10){
                HStack(spacing: 4){
                    Image(systemName: "doc.plaintext")
                        .foregroundColor(.blue)
                    Text("Description")
                }
                //TIP: Make Collapsable
                Text(viewModel.event.eventDescription)
                    .lineLimit(15)
            }
            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
