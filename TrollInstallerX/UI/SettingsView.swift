//
//  SettingsView.swift
//  TrollInstallerX
//
//  Created by Alfie on 26/03/2024.
//

import SwiftUI

struct SettingsView: View {
    
    let device: Device
    
    @AppStorage("exploitFlavour", store: TIXDefaults()) var exploitFlavour: String = ""
    @AppStorage("verbose", store: TIXDefaults()) var verbose: Bool = false
    @AppStorage("subtleSounds", store: TIXDefaults()) var subtleSounds: Bool = false
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                UIImpactFeedbackGenerator().impactOccurred()
                SoundFeedback.playTap()
                let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                try? FileManager.default.removeItem(atPath: docsDir.path + "/kernelcache")
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(maxWidth: 225)
                        .frame(maxHeight: 40)
                        .foregroundColor(.white.opacity(0.2))
                        .shadow(radius: 10)
                    Text("Clear cached kernel")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                }
            })
            .padding()
            if smith.supports(device) || physpuppet.supports(device) || darksword.supports(device) {
                Picker("Kernel exploit", selection: $exploitFlavour) {
                    if landa.supports(device) {
                        Text("landa").foregroundColor(.white).tag("landa")
                    }
                    if smith.supports(device) {
                        Text("smith").foregroundColor(.white).tag("smith")
                    }
                    if physpuppet.supports(device) {
                        Text("physpuppet").foregroundColor(.white).tag("physpuppet")
                    }
                    if darksword.supports(device) && !device.isArm64e && !(device.cpuFamily == .A8) {
                        Text("darksword").foregroundColor(.white).tag("darksword")
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(.white)
                .padding()
            }
            VStack {
                Toggle(isOn: $verbose, label: {
                    Text("Verbose logging")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                })
                Toggle(isOn: $subtleSounds, label: {
                    Text("Subtle sounds")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white)
                })
                .onChange(of: subtleSounds) { new in
                    if new {
                        SoundFeedback.playTap()
                    }
                }
            }
            .padding()
            
        }
        .onAppear {
            if exploitFlavour == "" {
                if physpuppet.supports(device) {
                    exploitFlavour = "physpuppet"
                } else if landa.supports(device) {
                    exploitFlavour = "landa"
                } else if darksword.supports(device) {
                    exploitFlavour = "darksword"
                }
            }
        }
    }
}
