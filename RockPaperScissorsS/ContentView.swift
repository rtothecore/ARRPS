//
//  ContentView.swift
//  RockPaperScissorsS
//
//  Created by 김혁 on 7/20/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var debugText: String = "TOP 4 PROBABILITIES:"
    @State private var symbol: String = "❎"
    @State private var slotSymbol: String = "👊"
    @State private var isAnimating: Bool = false
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = false
    @State private var showSymbol: Bool = false
    @State private var showResult: Bool = false
    @State private var resultText: String = ""
    @State private var isButtonDisabled: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    
    let slotSymbols = ["👊", "✌️", "🖐"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack {
                            Text(slotSymbol)
                                .font(.system(size: geometry.size.height * 0.1))
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        Text(symbol)
                            .font(.system(size: geometry.size.height * 0.1))
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.2)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .background(
                        ZStack {
                            Text("CPU")
                                .font(.system(size: geometry.size.height * 0.1))
                                .foregroundColor(Color.gray.opacity(0.3))
                                .rotationEffect(.degrees(0))
                                .offset(x: -geometry.size.width * 0.25, y: geometry.size.height * 0.05)
                            Text("PLAYER")
                                .font(.system(size: geometry.size.height * 0.05))
                                .foregroundColor(Color.gray.opacity(0.3))
                                .rotationEffect(.degrees(0))
                                .offset(x: geometry.size.width * 0.25, y: geometry.size.height * 0.05)
                        }
                    )
                    
                    ARViewContainer(debugText: $debugText, symbol: $symbol)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.68)
                    
                    Spacer()
                    
                    Button(action: {
                        startCountdown()
                    }) {
                        Text("가위, 바위, 보 시작!")
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.08)
                            .background(isButtonDisabled ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(isButtonDisabled)
                    .padding(.bottom, 20)
                }
                
                if showCountdown {
                    Text("\(countdown)")
                        .font(.system(size: geometry.size.height * 0.2))
                        .foregroundColor(.red)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.opacity)
                }
                
                if showSymbol {
                    Text(symbol)
                        .font(.system(size: geometry.size.height * 0.5))
                        .transition(.opacity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                if showResult {
                    Text(resultText)
                        .font(.system(size: geometry.size.height * 0.1))
                        .transition(.opacity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.1)
                }
            }
        }
    }
    
    func startSlotMachine() {
        self.isAnimating = true
        playSlotMachineSound()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation {
                if self.isAnimating {
                    self.slotSymbol = self.slotSymbols.randomElement()!
                } else {
                    timer.invalidate()
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            self.isAnimating = false
            self.stopSlotMachineSound()
        }
    }
    
    func startCountdown() {
        self.isButtonDisabled = true
        self.countdown = 3
        self.showCountdown = true
        self.startSlotMachine()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.showCountdown = false
                self.isAnimating = false
                showSymbolAndEvaluate()
                playFightSound()
            }
        }
    }
    
    func showSymbolAndEvaluate() {
        self.showSymbol = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.showSymbol = false
            }
            self.evaluateResult()
        }
    }
    
    func evaluateResult() {
        let result: String
        if (symbol == "👊" && slotSymbol == "✌️") ||
           (symbol == "✌️" && slotSymbol == "🖐") ||
           (symbol == "🖐" && slotSymbol == "👊") {
            result = "승리!"
            playWinSound()
        } else if symbol == slotSymbol {
            result = "무승부"
            playDrawSound()
        } else {
            result = "패배"
            playLoseSound()
        }
        
        self.resultText = result
        self.showResult = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.showResult = false
            }
            self.isButtonDisabled = false
        }
    }
    
    func playSlotMachineSound() {
        guard let url = Bundle.main.url(forResource: "Countdown", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
    
    func stopSlotMachineSound() {
        audioPlayer?.stop()
    }
    
    func playLoseSound() {
        guard let url = Bundle.main.url(forResource: "Lose", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
    
    func playWinSound() {
        guard let url = Bundle.main.url(forResource: "Win", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
    
    func playFightSound() {
        guard let url = Bundle.main.url(forResource: "Fight", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
    
    func playDrawSound() {
        guard let url = Bundle.main.url(forResource: "Draw", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
#Preview {
    ContentView()
}
*/
