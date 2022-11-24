//
//  UIKit+ColorPicker.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/23/22.
//

import UIKit
import SwiftUI

struct ColorPickerViewController: UIViewControllerRepresentable {

    var profileColor: Color?
    @Binding var selectedColor: Color?
    @Binding var isShowingColorPicker: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedColor: $selectedColor, isShowingColorPicker: $isShowingColorPicker)
    }
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.supportsAlpha = false
        colorPickerVC.extendedLayoutIncludesOpaqueBars = false
        colorPickerVC.delegate = context.coordinator
        colorPickerVC.setToolbarItems([UIBarButtonItem(systemItem: .cancel)], animated: false)

        if let color = profileColor {
            colorPickerVC.selectedColor = UIColor(color)
        }

        return colorPickerVC
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {

        @Binding var selectedColor: Color?
        @Binding var isShowingColorPicker: Bool

        init(selectedColor: Binding<Color?>, isShowingColorPicker: Binding<Bool>) {
            _selectedColor = selectedColor
            _isShowingColorPicker = isShowingColorPicker
        }

        func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
            selectedColor = Color(uiColor: color)
        }

        func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
            isShowingColorPicker = false
        }
    }
}


struct UIColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerViewController(selectedColor: .constant(.blue), isShowingColorPicker: .constant(true))
    }
}
