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
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 5){
                if viewModel.event.eventLocation.contains("discord.gg"){
                    HStack(spacing: 4){
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                        Text("Discord")
                            .bold()
                            .onTapGesture {
                                if let url = URL(string: "https://\(viewModel.event.eventLocation)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                } else {
                    VStack(alignment: .leading,spacing: 10){
                        HStack(spacing: 4){
                            Image(systemName: DetailItem.location.getSystemImage())
                                .foregroundColor(.blue)
                            Text(DetailItem.location.getTextHeading())
                                .font(.callout)
                        }
                        VStack(alignment: .leading, spacing: 4){
                            if let eventLocationTitle = viewModel.event.eventLocationTitle {
                                Text(eventLocationTitle)
                                    .bold()
                            }
                            Text(viewModel.event.eventLocation)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .onTapGesture {
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
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EventLocationView_Previews: PreviewProvider {
    static var previews: some View {
        EventLocationView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
