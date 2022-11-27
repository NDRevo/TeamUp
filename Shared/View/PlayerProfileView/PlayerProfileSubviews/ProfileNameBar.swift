//
//  ProfileNameBar.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

//MARK: ProfileNameBar
//INFO: Displays username and first and last name of player
struct ProfileNameBar: View {
    @EnvironmentObject var playerManager: PlayerManager

    var body: some View {
        HStack(spacing: 8){
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 80,height: playerManager.isEditingProfile ? 130 : 80)
                    .foregroundColor(playerManager.profileColor)
                if playerManager.isEditingProfile {
                    Button {
                        playerManager.isShowingColorPicker = true
                    } label: {
                        Image(systemName: "swatchpalette.fill")
                            .foregroundColor(.appCell)
                            .font(.title)
                            .frame(width: 80,height: playerManager.isEditingProfile ? 130 : 80)
                        
                    }
                }
            }

            RoundedRectangle(cornerRadius: 8)
                .frame(height: playerManager.isEditingProfile ? 130 : 80)
                .foregroundColor(.appCell)
                .overlay(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if let playerProfile = playerManager.playerProfile {
                                if playerManager.isEditingProfile {
                                    TextField(playerProfile.username, text: $playerManager.editedUsername)
                                        .font(.title)
                                        .bold()
                                        .keyboardType(.twitter)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .minimumScaleFactor(0.75)
                                        .padding(.horizontal, 4)
                                } else {
                                    Text("@\(playerProfile.username)")
                                        .font(.title)
                                        .bold()
                                }
                                
                                if playerManager.isEditingProfile {
                                    VStack(spacing: 6) {
                                        TextField(playerProfile.firstName, text: $playerManager.editedFirstName)
                                            .padding(4)
                                            .background { Color.appBackground.cornerRadius(8) }
                                            .autocorrectionDisabled()
                                        TextField(playerProfile.lastName, text: $playerManager.editedLastName)
                                            .padding(4)
                                            .background { Color.appBackground.cornerRadius(8) }
                                            .autocorrectionDisabled()
                                    }
                                    .font(.title2)
                                    .minimumScaleFactor(0.75)
                                } else {
                                    Text("\(playerProfile.firstName) \(playerProfile.lastName)")
                                        .font(.title2)
                                        .minimumScaleFactor(0.75)
                                }
                            }
                        }
                        if !playerManager.isEditingProfile { Spacer() }
                    }
                    .padding(.horizontal, 8)
                }
        }
        .padding(.horizontal, 12)
        .sheet(isPresented: $playerManager.isShowingColorPicker) {
            NavigationView {
                VStack{
                    ColorPickerViewController(
                        profileColor: playerManager.profileColor,
                        selectedColor: $playerManager.selectedColor,
                        isShowingColorPicker: $playerManager.isShowingColorPicker
                    )
                    .onAppear {
                        playerManager.editedSelectedColor = playerManager.profileColor!
                        playerManager.selectedColor =  playerManager.profileColor!
                    }
                }
                .navigationTitle("Color Picker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            if (playerManager.editedSelectedColor != nil) && (playerManager.selectedColor != nil) {
                                playerManager.editedSelectedColor = playerManager.editedSelectedColor
                            } else {
                                // Not called in didSet, when tapping on 'dismiss' or 'change' it would have set editedSelectedColor to nil before saving
                                playerManager.editedSelectedColor = nil
                            }
                            playerManager.isShowingColorPicker = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Change") {
                            playerManager.editedSelectedColor = playerManager.selectedColor
                            playerManager.isShowingColorPicker = false
                        }
                    }
                }
            }
        }
    }
}

struct ProfileNameBar_Previews: PreviewProvider {
    static var previews: some View {
        ProfileNameBar()
            .environmentObject(PlayerManager(playerProfile: TUPlayer(record: MockData.player)))
    }
}
