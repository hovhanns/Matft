import XCTest
//@testable import Matft
import Matft

final class ArithmeticTests: XCTestCase {
    
    func test_ms_sm() {
        do{

            let a = MfArray([[3, -19],
                             [-22, 4]])
            let b = MfArray([[2, 1177],
                             [5, -43]])
            
            XCTAssertEqual(a + 5, MfArray([[  8, -14],
                                           [-17,   9]]))
            
            XCTAssertEqual(a - 6, MfArray([[ -3, -25],
                                           [-28,  -2]]))
            XCTAssertEqual(a * 2, MfArray([[  6, -38],
                                           [-44,   8]]))
            XCTAssertEqual(a / 3, MfArray([[ 1.0        , -6.33333333],
                                           [-7.33333333,  1.33333333]], mftype: .Float))
            
            XCTAssertEqual(5 + b, MfArray([[   7, 1182],
                                           [  10,  -38]]))
            
            XCTAssertEqual(6 + b, MfArray([[   8, 1183],
                                           [  11,  -37]]))
            XCTAssertEqual(2 * b, MfArray([[   4, 2354],
                                           [  10,  -86]]))
            XCTAssertEqual(3 / b, MfArray([[ 1.5       ,  0.00254885],
                                           [ 0.6       , -0.06976744]], mftype: .Float))
        }

        do{
            
            let a = MfArray([[2, 1, -3, 0],
                             [3, 1, 4, -5]], mforder: .Column)


            XCTAssertEqual(a+2, MfArray([[ 4.0,  3.0, -1.0,  2.0],
                                         [ 5.0,  3.0,  6.0, -3.0]]))
            XCTAssertEqual(a-3.2, MfArray([[-1.2, -2.2, -6.2, -3.2],
                                           [-0.2, -2.2,  0.8, -8.2]]))


            XCTAssertEqual(a*UInt8(1.3), MfArray([[ 2.0,  1.0, -3.0,  0.0],
                                                  [ 3.0,  1.0,  4.0, -5.0]]))
            
            /*
            XCTAssertEqual(a/1.3, MfArray([[ 1.53846154,  0.76923077, -2.30769231,  0.0        ],
                                           [ 2.30769231,  0.76923077,  3.07692308, -3.84615385]]))
            */
        }
        
    }
    
    func testSameShape() {
        do{
            /*
            let a = MfArray([[3, -19],
                             [-22, 4]], mftype: .Float)
            let b = MfArray([[0.2, 1.177],
                             [5, -4.3]], mftype: .Float)
            
            XCTAssertEqual(a + b, MfArray([[  3.2  , -17.823],
                                           [-17.0   ,  -0.3  ]], mftype: .Float))*/
            let a = MfArray([[3, -19],
                             [-22, 4]])
            let b = MfArray([[2, 1177],
                             [5, -43]])
            
            XCTAssertEqual(a + b, MfArray([[   5, 1158],
                                           [ -17,  -39]]))
            
            XCTAssertEqual(a - b, MfArray([[    1, -1196],
                                           [  -27,    47]]))
            XCTAssertEqual(a * b, MfArray([[     6, -22363],
                                           [  -110,   -172]]))
            XCTAssertEqual(a / b, MfArray([[ 1.5       , -0.01614274],
                                           [-4.4       , -0.09302326]], mftype: .Float))
        }

        do{
            
            let a = MfArray([[2, 1, -3, 0],
                             [3, 1, 4, -5]], mftype: .Double, mforder: .Column)
            let b = MfArray([[-0.87, 1.2, 5.5134, -8.78],
                             [-0.0002, 2, 3.4, -5]], mftype: .Double, mforder: .Column)

            XCTAssertEqual(a+b, MfArray([[  1.13  ,   2.2   ,   2.5134,  -8.78  ],
                                       [  2.9998,   3.0    ,   7.4   , -10.0    ]]))
            XCTAssertEqual(a-b, MfArray([[ 2.87  , -0.2   , -8.5134,  8.78  ],
                                       [ 3.0002, -1.0    ,  0.6   ,  0.0    ]]))


            XCTAssertEqual(a*b, MfArray([[-1.74000e+00,  1.20000e+00, -1.65402e+01, -0.00000e+00],
                                         [-6.00000e-04,  2.00000e+00,  1.36000e+01,  2.50000e+01]]))
            /*
            //rounding error will be occurred
            XCTAssertEqual(a/b, MfArray([[-2.29885057e+00,  8.33333333e-01, -5.44128850e-01,
                                          -0.00000000e+00],
                                         [-1.50000000e+04,  5.00000000e-01,  1.17647059e+00,
                                          1.00000000e+00]]))*/
        }
        
        do{
            let a = Matft.arange(start: 0, to: 4*4, by: 1, shape: [4,4], mftype: .UInt8).T
            let b = MfArray([[-5, 3, 2, 4],
                             [-9, 3, 1, 1],
                             [22, 17, 0, -2],
                             [1, -7, 3, 3]], mftype: .UInt8, mforder: .Column)
            XCTAssertEqual(a+b, MfArray([[251,   7,  10,  16],
                                         [248,   8,  10,  14],
                                         [ 24,  23,  10,  12],
                                         [  4,   0,  14,  18]], mftype: .UInt8))
            XCTAssertEqual(a-b, MfArray([[  5,   1,   6,   8],
                                         [ 10,   2,   8,  12],
                                         [236, 245,  10,  16],
                                         [  2,  14,   8,  12]], mftype: .UInt8))
            XCTAssertEqual(a*b, MfArray([[  0,  12,  16,  48],
                                         [247,  15,   9,  13],
                                         [ 44, 102,   0, 228],
                                         [  3, 207,  33,  45]], mftype: .UInt8))
            /*
            //rounding error will be occurred
            XCTAssertEqual(a/b, MfArray([[0.00000000e+00, 1.33333333e+00, 4.00000000e+00, 3.00000000e+00],
                                         [4.04858300e-03, 1.66666667e+00, 9.00000000e+00, 1.30000000e+01],
                                         [9.09090909e-02, 3.52941176e-01, -Double.nan, 5.51181102e-02],
                                         [3.00000000e+00, 2.81124498e-02, 3.66666667e+00, 5.00000000e+00]], mftype: .Float))*/
        }
    }
    

    func testBroadcast(){
        do{
            let a = MfArray([[1, 3, 5],
                            [2, -4, -1]])
            let b = Matft.arange(start: 0, to: 2*3*3, by: 1, shape: [3, 2, 3])
            
            XCTAssertEqual(a+b, MfArray([[[ 1,  4,  7],
                                          [ 5,  0,  4]],

                                         [[ 7, 10, 13],
                                          [11,  6, 10]],

                                         [[13, 16, 19],
                                          [17, 12, 16]]]))
            XCTAssertEqual(a-b, MfArray([[[  1,   2,   3],
                                          [ -1,  -8,  -6]],

                                         [[ -5,  -4,  -3],
                                          [ -7, -14, -12]],

                                         [[-11, -10,  -9],
                                          [-13, -20, -18]]]))
            XCTAssertEqual(a*b, MfArray([[[  0,   3,  10],
                                          [  6, -16,  -5]],

                                         [[  6,  21,  40],
                                          [ 18, -40, -11]],

                                         [[ 12,  39,  70],
                                          [ 30, -64, -17]]]))
            XCTAssertEqual(b/a, MfArray([[[  0.0        ,   0.33333333,   0.4       ],
                                          [  1.5       ,  -1.0        ,  -5.0        ]],

                                         [[  6.0        ,   2.33333333,   1.6       ],
                                          [  4.5       ,  -2.5       , -11.0        ]],

                                         [[ 12.0        ,   4.33333333,   2.8       ],
                                          [  7.5       ,  -4.0        , -17.0        ]]], mftype: .Float))
        }
        
        do{
            
            let a = Matft.arange(start: 1, to: 7, by: 1, shape: [3, 2])
            let b = Matft.arange(start: 1, to: 5, by: 1, shape: [2, 1, 2])
            
            XCTAssertEqual(a-b, MfArray([[[ 0,  0],
                                          [ 2,  2],
                                          [ 4,  4]],

                                         [[-2, -2],
                                          [ 0,  0],
                                          [ 2,  2]]]))
            
            XCTAssertEqual(a+b, MfArray([[[ 2,  4],
                                          [ 4,  6],
                                          [ 6,  8]],

                                         [[ 4,  6],
                                          [ 6,  8],
                                          [ 8, 10]]]))
        }
        
        do{
            let a = Matft.arange(start: 0, to: 18, by: 1, shape: [3, 1, 3, 2])
            let b = Matft.arange(start: 0, to: 24, by: 1, shape: [4, 3, 2])
            
            XCTAssertEqual(a+b, MfArray([[[[ 0,  2],
                                           [ 4,  6],
                                           [ 8, 10]],

                                          [[ 6,  8],
                                           [10, 12],
                                           [14, 16]],

                                          [[12, 14],
                                           [16, 18],
                                           [20, 22]],

                                          [[18, 20],
                                           [22, 24],
                                           [26, 28]]],


                                         [[[ 6,  8],
                                           [10, 12],
                                           [14, 16]],

                                          [[12, 14],
                                           [16, 18],
                                           [20, 22]],

                                          [[18, 20],
                                           [22, 24],
                                           [26, 28]],

                                          [[24, 26],
                                           [28, 30],
                                           [32, 34]]],


                                         [[[12, 14],
                                           [16, 18],
                                           [20, 22]],

                                          [[18, 20],
                                           [22, 24],
                                           [26, 28]],

                                          [[24, 26],
                                           [28, 30],
                                           [32, 34]],

                                          [[30, 32],
                                           [34, 36],
                                           [38, 40]]]]))
        }
    }
    
    func testNegativeIndexing(){
        
        do{
            let a = Matft.arange(start: 0, to: 3*3*3*2, by: 2, shape: [3, 3, 3])
            let b = Matft.arange(start: 0, to: 3*3*3, by: 1, shape: [3, 3, 3])
            let c = a[~<<-1]
            let d = b[2, 1, ~<<-1]
            
            XCTAssertEqual(c+d, MfArray([[[59, 60, 61],
                                          [65, 66, 67],
                                          [71, 72, 73]],

                                         [[41, 42, 43],
                                          [47, 48, 49],
                                          [53, 54, 55]],

                                         [[23, 24, 25],
                                          [29, 30, 31],
                                          [35, 36, 37]]]))
            XCTAssertEqual(c-d, MfArray([[[ 13,  16,  19],
                                          [ 19,  22,  25],
                                          [ 25,  28,  31]],

                                         [[ -5,  -2,   1],
                                          [  1,   4,   7],
                                          [  7,  10,  13]],

                                         [[-23, -20, -17],
                                          [-17, -14, -11],
                                          [-11,  -8,  -5]]]))
            XCTAssertEqual(c*d, MfArray([[[ 828,  836,  840],
                                          [ 966,  968,  966],
                                          [1104, 1100, 1092]],

                                         [[ 414,  440,  462],
                                          [ 552,  572,  588],
                                          [ 690,  704,  714]],

                                         [[   0,   44,   84],
                                          [ 138,  176,  210],
                                          [ 276,  308,  336]]]))
            XCTAssertEqual(c/d, MfArray([[[1.56521739, 1.72727273, 1.9047619 ],
                                          [1.82608696, 2.0       , 2.19047619],
                                          [2.08695652, 2.27272727, 2.47619048]],

                                         [[0.7826087 , 0.90909091, 1.04761905],
                                          [1.04347826, 1.18181818, 1.33333333],
                                          [1.30434783, 1.45454545, 1.61904762]],

                                         [[0.0       , 0.09090909, 0.19047619],
                                          [0.26086957, 0.36363636, 0.47619048],
                                          [0.52173913, 0.63636364, 0.76190476]]], mftype: .Float))
        }
        
        do{
            let a = MfArray([[1.28, -3.2],[1.579, -0.82]])
            let b = MfArray([2,1])
            let c = a[-1~<-2~<-1]
            let d = b[~<<-1]

            XCTAssertEqual(c+d, MfArray([[2.579, 1.18 ]]))
            XCTAssertEqual(c-d, MfArray([[ 0.579, -2.82 ]]))
            XCTAssertEqual(c*d, MfArray([[ 1.579, -1.64 ]]))
            XCTAssertEqual(c/d, MfArray([[ 1.579, -0.41 ]]))
        }
    }
}
