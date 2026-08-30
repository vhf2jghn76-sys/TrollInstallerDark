//
//  SoundFeedback.swift
//  TrollInstallerX
//
//  Created by OpenAI on 19/08/2026.
//

import AudioToolbox
import Foundation

enum SoundFeedback {
    private static let subtleTapSound: SystemSoundID = 1104
    private static let successSound: SystemSoundID = 1025
    private static let errorSound: SystemSoundID = 1053

    private static var isEnabled: Bool {
        TIXDefaults().bool(forKey: "subtleSounds")
    }

    static func playTap() {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(subtleTapSound)
    }

    static func playCompletion(success: Bool) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(success ? successSound : errorSound)
    }
}
