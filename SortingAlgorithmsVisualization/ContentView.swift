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
                    try await selectionSort()
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
    
    @MainActor // adding MainActor so that the sound is played on the main thread. Plays weirdly if played on a background thread.
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
    
    // This is also a comparison algorithm similar to the bubble sort:
    // but the number of swap operations is reduced.
    // it's also slow time complexity is O(n^2)
    // during each pass the algorithm will find the smallest unsorted value and swap it into place.
    // the first loop starts with a sorting index of 0 and will not iterate up until the last element, because the last element will be in place only until the other elements are in place.
    // take an example: [7, 4, 9, 1]
    // during each pass it will set the smallest element to be the same as the sorting index
    // then compare that smallest element (for now) to the next element. if next element is smaller than current element, that element will be smallest element.
    // in the example, 7 starts as the smallest element, 0 as the sorting index, it moves on and compares to 4, 4 being smaller will now be the smallest element.
    // then we do the next comparison of 4 (the new smallest element) with 9 the next element. 4 is smaller so we skip 9 unto the next one which is 1 and compare 4 to 1.
    // since 1 is smaller than 4 we will set the smallest element to be 1.
    // after passing the whole array, we will check that the smallest element is not equal to the sorting index in this case 1 is not equal to 7 (the element in the current sorting index - 0) so we will swap it.
    // we will now have [1, 4, 9, 7]
    // for our next iteration: we increment the sorting index which will now be 1 and we will set the smallest element to the element in that position which is now 4.
    // now compare 4 with the next element, 9. since 4 is smaller we skip 9 and move to the next element after 9 which is 7 and 4 is still our smallest element - so no need to do any swapping, we just leave it in place.
    // we still have array to be [1, 4, 9, 7]
    // next iteration we increment our sorting index whic will now be 2.
    // the element at this sorting index is now 9
    // we compare 9 with the next element which is 7, since 7 is smaller, 7 will now be the smallest element
    // now because the smallest element is not equals to the element at the sorting index 9 we will perform a swap.
    // we now have [1, 4, 7, 9] - a completely sorted array.
    @MainActor
    func selectionSort() async throws {
        guard data.count > 1 else { return }
        
        // the sorting doesn't have to include the last element:
        // after the first iteration the last element will already be in place.
        for i in 0..<data.count - 1 {
            var smallest = i // set smallest element to the sorting index.
            
            for j in i + 1..<data.count {
                if data[smallest] > data[j] {
                    activeValue = data[j]
                    
                    beep(data[j])
                    
                    smallest = j
                    
                    // sleep for visualisation purposes.
                    try await Task.sleep(until: .now.advanced(by: .milliseconds(20)), clock: .continuous)
                }
            }
            
            // check that the current smallest index is not equal to sorting index
            if smallest != i {
                activeValue = data[i]
                previousValue = data[smallest]
                beep(data[smallest])
                
                data.swapAt(smallest, i)
                
                try await Task.sleep(until: .now.advanced(by: .milliseconds(20)), clock: .continuous)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
