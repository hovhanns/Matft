import XCTest
//@testable import Matft
import Matft

final class IndexingPefTests: XCTestCase {
    
    func testPeformanceBooleanIndexing1() {
        do{
            let a = Matft.arange(start: -10*10*10*10*10*5, to: 10*10*10*10*10*5, by: 1, shape: [10,10,10,10,10,10])
            
            self.measure {
                let _ = a[a>0]
            }
            /*
             '-[PerformanceTests.IndexingPefTests testPeformanceBooleanIndexing1]' measured [Time, seconds] average: 0.004, relative standard deviation: 50.409%, values: [0.008761, 0.003488, 0.002775, 0.002847, 0.002846, 0.002844, 0.002943, 0.002825, 0.002906, 0.002772]
            3.50ms
             */
        }
    }
    
    func testPeformanceBooleanIndexing2() {
        do{
            let a = Matft.arange(start: -10*10*10*10*10*5, to: 10*10*10*10*10*5, by: 1, shape: [10,10,10,10,10,10])
            let b = Matft.arange(start: 10*10*10*10*10*10, to: -10*10*10*10*10*10, by: -2, shape: [10,10,10,10,10,10])
            
            self.measure {
                let _ = a[a>b]
            }
            /*
             '-[PerformanceTests.IndexingPefTests testPeformanceBooleanIndexing2]' measured [Time, seconds] average: 0.007, relative standard deviation: 23.077%, values: [0.010261, 0.006136, 0.006031, 0.005470, 0.005826, 0.005804, 0.005430, 0.005504, 0.005319, 0.005328]
            6.11ms
             */
        }
    }
}

