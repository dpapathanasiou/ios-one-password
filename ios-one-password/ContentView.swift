//
//  ContentView.swift
//  ios-one-password
//
//  Created by Denis Papathanasiou on 12/28/25.
//

import SwiftUI

// Placeholder functions for the onepassword package
func getCandidatePwd(_ passphrase: String, _ username: String, _ host: String, _ seed: Int, _ iteration: Int) -> String {
    // Dummy implementation - replace with actual password generation logic
    return "dummyPassword"
}

func pwdIsValid(_ password: String, _ size: Int) -> Bool {
    // Dummy validation - replace with actual validation logic
    return true
}

struct ContentView: View {
    @State private var siteName: String = ""
    @State private var username: String = ""
    @State private var passphrase: String = ""
    @State private var showPassphrase: Bool = false
    @State private var passwordLength: Int = 16 // Use Int for the stepper
    @State private var specialChars: String = ""
    @State private var generatedPassword: String = ""

    let defaultPasswordLength = 16

    func generatePassword() {
        guard passwordLength >= 5 else {
            generatedPassword = "Please use a positive number greater than or equal to five (5)"
            return
        }

        let password = getCandidatePwd(passphrase, username, siteName, 12, 0)
        if pwdIsValid(password, passwordLength) {
            generatedPassword = String(password.prefix(passwordLength - specialChars.count)) + specialChars
        } else {
            generatedPassword = "Password is not valid according to the given criteria"
        }
    }

    func clearFields() {
        siteName = ""
        username = ""
        passphrase = ""
        passwordLength = defaultPasswordLength
        specialChars = ""
        generatedPassword = ""
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Credentials")) {
                    TextField("Site Name", text: $siteName)
                    TextField("Username", text: $username)
                    SecureField("Passphrase", text: $passphrase)
                        .overlay(Group {
                            if showPassphrase {
                                Text(passphrase).foregroundColor(.blue).padding([.leading, .trailing], 8)
                                    .onTapGesture {
                                        passphrase = ""
                                    }
                            }
                        })
                    Toggle(isOn: $showPassphrase) {
                        Text("Show Passphrase")
                    }

                    Stepper(value: $passwordLength, in: 5...100) {
                        Text("Password Length (\(passwordLength))")
                    }

                    TextField("Special Chars", text: $specialChars)
                }

                Section(header: Text("Generated Password")) {
                    Text(generatedPassword)
                        .frame(height: 40)
                }

                Button(action: generatePassword) {
                    Text("Generate")
                }

                Button(action: clearFields) {
                    Text("Clear")
                }
            }
            .navigationTitle("One Password Generator")
        }
    }
}

#Preview {
    ContentView()
}
