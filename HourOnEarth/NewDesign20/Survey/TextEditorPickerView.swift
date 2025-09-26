//
//  TextEditorPickerView.swift
//  Other
//
//  Created by Paresh Dafda on 13/05/20.
//  Copyright © 2020 Other. All rights reserved.
//

import UIKit

class TextEditorPickerView : UIPickerView {
 
    typealias SelectionHandler = ((String) -> Void)
    var pickerData : [String]!
    var pickerTextField : UITextField!
    var selectionHandler : SelectionHandler?
 
    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)
 
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
 
        self.delegate = self
        self.dataSource = self
 
        DispatchQueue.main.async {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData.first
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        }
 
        if let selectedText = pickerTextField.text{
            selectionHandler?(selectedText)
        }
    }
 
    convenience init(pickerData: [String], dropdownField: UITextField, onSelect selectionHandler : @escaping SelectionHandler) {
        self.init(pickerData: pickerData, dropdownField: dropdownField)
        self.selectionHandler = selectionHandler
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextEditorPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
        
        if let selectedText = pickerTextField.text{
            selectionHandler?(selectedText)
        }
    }
}

extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = TextEditorPickerView(pickerData: data, dropdownField: self)
    }
 
    func loadDropdownData(data: [String], onSelect selectionHandler : @escaping TextEditorPickerView.SelectionHandler) {
        self.inputView = TextEditorPickerView(pickerData: data, dropdownField: self, onSelect: selectionHandler)
    }
}
