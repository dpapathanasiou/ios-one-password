//
//  ContentView.swift
//  ios-one-password
//
//  Created by Denis Papathanasiou on 12/28/25.
//

import SwiftUI

public func createPassword(
    passphrase: String,
    hostname: String,
    username: String,
    passwordLength: Int,
    specials: String
) -> String {
    var i = 0
    var candidate: String = ""
    var isValid = false

    while !isValid {
        guard let result = OnePassword.getCandidatePwd(
                passphrase: passphrase,
                username: username,
                host: hostname,
                generation: 12,
                iteration: i
        ) else {
            // if candidate generation fails, simply bump the iteration and try again
            i += 1
            continue
        }

        candidate = result
        isValid = OnePassword.pwdIsValid(candidate, pwdLen: passwordLength)

        i += 1
    }
    
    return candidate
}

struct ContentView: View {
    @State private var siteName: String = ""
    @State private var username: String = ""
    @State private var passphrase: String = ""
    @State private var showPassphrase: Bool = false
    @State private var passwordLength: Int = 16
    @State private var specialChars: String = ""
    @State private var generatedPassword: String = ""

    let defaultPasswordLength = 16

    func generatePassword() {
        guard passwordLength >= 5 else {
            generatedPassword = "Please use a positive number greater than or equal to five (5)"
            return
        }
        
        guard !siteName.isEmpty, !username.isEmpty, !passphrase.isEmpty else {
            generatedPassword = "Please fill in all the fields"
            return
        }

        let password = createPassword(
            passphrase: passphrase,
            hostname: siteName,
            username: username,
            passwordLength: passwordLength,
            specials: specialChars
        )
        generatedPassword = String(password.prefix(passwordLength - specialChars.count)) + specialChars
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
                        .disableAutocorrection(true)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                    TextField("Username", text: $username)
                        .disableAutocorrection(true)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                    SecureField("Passphrase", text: $passphrase)
                        .disableAutocorrection(true)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
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
            .navigationTitle("iOS One Password")
        }
    }
}

#Preview {
    ContentView()
}
