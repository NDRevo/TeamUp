//
//  AddMatchSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddMatchSheet: View {
    
    @Binding var matches: [TUMatch]
    
    @State var matchName: String = ""
    @State var matchDate: Date = Date()

    @Environment(\.dismiss) var dismiss
    
    let dateRange: PartialRangeFrom<Date> = {
        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
        return calendar.date(from:startDate)!...
    }()
    
    var body: some View {
        List{
            TextField("Match Name", text: $matchName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Match Date", selection: $matchDate, in: dateRange, displayedComponents: [.hourAndMinute])
            
            Section{
                Button {
                    matches.append(TUMatch(date: matchDate, name: matchName))
                    dismiss()
                } label: {
                    Text("Create Match")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddMatchSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchSheet(matches: .constant([TUMatch(date: Date(), name: "Randoms")]))
    }
}
