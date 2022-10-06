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
    
    var body: some View {
        VStack {
            Chart {
                ForEach(
                    Array(zip(data.indices, data)), id: \.0
                ) { index, item in
                    BarMark(
                        x: .value("Position", index),
                        y: .value("Value", item))
                }
            }
            .frame(width: 280, height: 250)
            
            Button("Sort it!") {
                Task {
                    try await bubbleSort()
                }
            }
        }
        .onAppear {
            data = input
        }
    }
    
    func bubbleSort() async throws {
        // first check if it's just one element otherwise it's already sorted.
        guard data.count > 1 else { return }
        
        // now iterate over the array
        for i in 0..<data.count {
            for j in 0..<data.count - i - 1 {
                if data[j] > data[j + 1] {
                    data.swapAt(j + 1, j)
                    // add a sleep just for visualisation purposes
                    try await Task.sleep(until: .now.advanced(by: .milliseconds(500)), clock: .continuous)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
