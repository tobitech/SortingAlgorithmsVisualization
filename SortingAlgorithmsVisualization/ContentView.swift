import SwiftUI
import Charts

struct ContentView: View {
    
    var input: [Int] {
        var array = [Int]()
        for i in 1...30 {
            array.append(i)
        }
        
        return array.shuffled()
    }
    
    @State var data = [Int]()
    @State var activeValue = 0
    @State var previousValue = 0
    @State var checkValue: Int?
    
    var body: some View {
        VStack {
            Chart {
                ForEach(
                    Array(zip(data.indices, data)), id: \.0
                ) { index, item in
                    BarMark(
                        x: .value("Position", index),
                        y: .value("Value", item))
                    .foregroundStyle(getColors(value: item).gradient)
                }
            }
            .frame(width: 280, height: 250)
            
            Button("Sort it!") {
                Task {
                    try await bubbleSort()
                    activeValue = 0
                    previousValue = 0
                    
                    for index in 0..<data.count {
                        beep(data[index])
                        
                        checkValue = data[index]
                        
                        // add a little delay
                        try await Task.sleep(until: .now.advanced(by: .milliseconds(20)), clock: .continuous)
                    }
                }
            }
        }
        .onAppear {
            data = input
        }
    }
    
    @MainActor
    func bubbleSort() async throws {
        // first check if it's just one element otherwise it's already sorted.
        guard data.count > 1 else { return }
        
        // now iterate over the array
        for i in 0..<data.count {
            for j in 0..<data.count - i - 1 {
                
                // also for visulatisation
                activeValue = data[j + 1]
                previousValue = data[j]
                
                if data[j] > data[j + 1] {
                    // for audio
                    beep(data[j + 1])
                    
                    data.swapAt(j + 1, j)
                    
                    // add a sleep just for visualisation purposes
                    try await Task.sleep(until: .now.advanced(by: .milliseconds(20)), clock: .continuous)
                }
            }
        }
    }
    
    func getColors(value: Int) -> Color {
        if let checkValue, value <= checkValue {
            return .green
        }
        
        if value == activeValue {
            return .green
        } else if value == previousValue {
            return .yellow
        }
        
        return .blue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
