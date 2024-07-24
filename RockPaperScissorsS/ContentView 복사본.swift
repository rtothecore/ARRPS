//
//  ContentView.swift
//  RockPaperScissorsS
//
//  Created by 김혁 on 7/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var debugText: String = "TOP 4 PROBABILITIES:"
    @State private var symbol: String = "❎"
    @State private var slotSymbol: String = "👊"
    @State private var isAnimating: Bool = false
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = false
    
    let slotSymbols = ["👊", "✌️", "🖐"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack {
                            Text(slotSymbol)
                                .font(.system(size: geometry.size.height * 0.05))
                                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                                .background(Color.gray.opacity(0.2))
                        }
                        Text(symbol)
                            .font(.system(size: geometry.size.height * 0.05))
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                            .background(Color.gray.opacity(0.2))
                    }
                    ARViewContainer(debugText: $debugText, symbol: $symbol)
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.42)
                    
                    Spacer()
                    
                    Button(action: {
                        startCountdown()
                    }) {
                        Text("가위, 바위, 보 시작!")
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.08)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                if showCountdown {
                    Text("\(countdown)")
                        .font(.system(size: geometry.size.height * 0.2))
                        .foregroundColor(.red)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    func startSlotMachine() {
        self.isAnimating = true
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
        }
    }
    
    func startCountdown() {
        self.countdown = 3
        self.showCountdown = true
        self.startSlotMachine() // Start slot machine animation when countdown starts
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.showCountdown = false
                self.isAnimating = false
            }
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
