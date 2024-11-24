//
//  CustomAlertWithTextField.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/23/24.
//

import SwiftUI

struct CustomAlertWithTextField: View {
    @EnvironmentObject private var constants: Constants
    @Binding var show: Bool
    var title: String
    var defaultText: String? = nil
    var onUnlock: (String) -> ()
    @State private var text: String = ""
    
    init(show: Binding<Bool>, title: String, defaultText: String? = nil, onUnlock: @escaping (String) -> ()) {
            self._show = show
            self.title = title
            self.defaultText = defaultText
            self.onUnlock = onUnlock
            self._text = State(initialValue: defaultText ?? "")
        }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 65, height: 65)
                .background {
                    Circle()
                        .fill(.blue.gradient)
                        .background {
                            Circle()
                                .fill(.background)
                                .padding(-5)
                        }
                }
            
            Text(title)
                .fontWeight(.semibold)
            
            TextField("Item Name", text: $text)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.bar)
                }
                .textInputAutocapitalization(
                    constants.textCasing == .firstWord ? .sentences :
                        constants.textCasing == .allWords ? .words : .none
                )
                .disableAutocorrection(!constants.showSuggestions)
                .padding(.vertical, 10)
            
            HStack(spacing: 10) {
                Button {
                    show = false
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.red.gradient)
                        }
                }
                
                Button {
                    onUnlock(text)
                    show = false
                } label: {
                    Text("Add")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                        }
                }
            }
        }
        .frame(width: 250)
        .padding([.horizontal, .bottom], 25)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.background)
                .padding(.top, 25)
        }
    }
}
