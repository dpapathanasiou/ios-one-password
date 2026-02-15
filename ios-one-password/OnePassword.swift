//
//  OnePassword.swift
//  ios-one-password
//
//  Created by Denis Papathanasiou on 2/15/26.
//

import Foundation
import CryptoSwift

public struct OnePassword {
    /// Generates a candidate password.
    ///
    /// - Parameters:
    ///   - passphrase: The master secret known only to the user.
    ///   - username:   The account’s username (used as the scrypt salt).
    ///   - host:       The domain name of the target site.
    ///   - generation: A counter that changes whenever you want a new password.
    ///   - iteration:  A counter that changes for each character position.
    /// - Returns: Base‑64 encoded password string or `nil` if scrypt fails.

    public static func getCandidatePwd(
        passphrase pp: String,
        username usr: String,
        host: String,
        generation g: Int,
        iteration i: Int
    ) -> String? {
        // Convert the string inputs to `[UInt8]`.
        let passwordBytes = Array(pp.utf8)
        let saltBytes     = Array(usr.utf8)

        // 1. Derive a 32‑byte key from the passphrase and username using scrypt.
        let dk: [UInt8]
        do {
            dk = try Scrypt(password: passwordBytes,
                            salt: saltBytes,
                            dkLen: 32,
                            N: 16384,
                            r: 8,
                            p: 1).calculate()
        } catch {
            fputs("Error! \(error)\n", stderr)
            return nil
        }

        // 2. Build the message to hash.
        let msg = "G1P,v.1.0\(usr)\(host)\(g)\(i)"
        guard let msgData = msg.data(using: .utf8) else { return nil }

        // 3. Compute HMAC‑SHA512 with the derived key.
        let hmac = HMAC(key: dk, variant: .sha2(.sha512))
        let digest: [UInt8]
        do {
            // ← Convert RawSpan<UInt8> → [UInt8]
            digest = try hmac.authenticate(Array(msgData))
        } catch {
            fputs("Error! \(error)\n", stderr)
            return nil
        }
        
        // 4. Return the base‑64 representation.
        return Data(digest).base64EncodedString()
    }

    public static func pwdIsValid(_ pwd: String, pwdLen: Int) -> Bool {
        guard pwd.count >= pwdLen else { return false }

        let prefix = String(pwd.prefix(pwdLen))
        guard prefix.allSatisfy({ $0.isLetter || $0.isNumber }) else { return false }

        let uppercasePattern = "[A-Z]{1,5}"
        let lowercasePattern = "[a-z]{1,5}"
        let digitPattern     = "[0-9]{1,5}"

        guard prefix.range(of: uppercasePattern, options: .regularExpression) != nil,
              prefix.range(of: lowercasePattern, options: .regularExpression) != nil,
              prefix.range(of: digitPattern,     options: .regularExpression) != nil
        else { return false }

        return true
    }
}
