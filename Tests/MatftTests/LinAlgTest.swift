import XCTest
//@testable import Matft
import Matft

final class LinAlgTests: XCTestCase {
    
    func testSolve() {
        do{
            let coef = MfArray<Int>([[3,2],[1,2]])
            let b = MfArray<Int>([7,1])
            
            XCTAssertEqual(try Matft.linalg.solve(coef, b: b), MfArray<Float>([ 3.0, -1.0]))
        }

        do{
            let coef = MfArray<Int>([[3,1],[1,2]])
            let b = MfArray<Int>([9,8])
            
            XCTAssertEqual(try Matft.linalg.solve(coef, b: b), MfArray<Float>([ 2.0, 3.0]))
        }
        
        do{
            let coef = MfArray<Int>([[1,2],[2,4]])
            let b = MfArray<Int>([-1,-2])
            
            XCTAssertThrowsError(try Matft.linalg.solve(coef, b: b))
        }
        
        do{
            let coef = MfArray<Int>([[1,2],[2,4]])
            let b = MfArray<Int>([-1,-3])
            
            XCTAssertThrowsError(try Matft.linalg.solve(coef, b: b))
        }
    }
    

    func testInv(){
        do{
            let a = MfArray<Int>([[1, 2], [3, 4]])
            XCTAssertEqual(try Matft.linalg.inv(a), MfArray<Float>([[-2.0 ,  1.0 ],
                                                                     [ 1.5, -0.5]]))
        }
        do{
            let a = MfArray<Int>([[[1.0, 2.0],
                              [3.0, 4.0]],
                             
                             [[1.0, 3.0],
                              [3.0, 5.0]]])
            XCTAssertEqual(try Matft.linalg.inv(a), MfArray<Float>([[[-2.0  ,  1.0  ],
                                                                     [ 1.5 , -0.5 ]],
                                                                     [[-1.25,  0.75],
                                                                      [ 0.75, -0.25]]]))
        }
    }
    
    func testDet(){
        
        do{
            let a = MfArray<Int>([[1, 2], [3, 4]])
            XCTAssertEqual(try Matft.linalg.det(a), MfArray<Int>([-2]))
        }
        
        do{
            let a = MfArray<Float>([[[1.0, 2.0],
                              [3.0, 4.0]],
                             
                             [[1.0, 3.0],
                              [3.0, 5.0]]])
            XCTAssertEqual(try Matft.linalg.det(a), MfArray<Float>([-2.0, -4.0]))
        }
    }
    
    func testEigen(){
        do{
            let a = MfArray<Int>([[1, -1], [1, 1]])
            let ret = try! Matft.linalg.eigen(a)
            // value
            XCTAssertEqual(ret.valRe, MfArray<Float>([1, 1]))
            XCTAssertEqual(ret.valIm, MfArray<Float>([1, -1]))
            // vector-left
            XCTAssertEqual(ret.lvecRe, MfArray<Float>([[-0.70710677, -0.70710677],
                                                [0.0, 0.0]]))
            XCTAssertEqual(ret.lvecIm, MfArray<Float>([[0.0, 0.0],
                                                [0.70710677, -0.70710677]]))
            // vector-right
            XCTAssertEqual(ret.rvecRe, MfArray<Float>([[0.70710677, 0.70710677],
                                                [0.0, 0.0]]))
            XCTAssertEqual(ret.rvecIm, MfArray<Float>([[0.0, 0.0],
                                                [-0.70710677, 0.70710677]]))
            
        }
        do{
            let a = MfArray<Int>([[[1,0,0],
                              [0,2,0],
                              [0,0,3]]])
            let ret = try! Matft.linalg.eigen(a)
            // value
            XCTAssertEqual(ret.valRe, MfArray<Float>([[1, 2, 3]]))
            XCTAssertEqual(ret.valIm, MfArray<Float>([[0, 0, 0]]))
            // vector-left
            XCTAssertEqual(ret.lvecRe, MfArray<Float>([[[1.0, 0.0, 0.0],
                                                [0.0, 1.0, 0.0],
                                                [0.0, 0.0, 1.0]]]))
            XCTAssertEqual(ret.lvecIm, MfArray<Float>([[[0.0, 0.0, 0.0],
                                                 [0.0, 0.0, 0.0],
                                                 [0.0, 0.0, 0.0]]]))
            // vector-right
            XCTAssertEqual(ret.rvecRe, MfArray<Float>([[[1.0, 0.0, 0.0],
                                                [0.0, 1.0, 0.0],
                                                [0.0, 0.0, 1.0]]]))
            XCTAssertEqual(ret.rvecIm, MfArray<Float>([[[0.0, 0.0, 0.0],
                                                 [0.0, 0.0, 0.0],
                                                 [0.0, 0.0, 0.0]]]))
            
        }
        do{
            let a = MfArray<Int>([[0, -1],
                             [1, 0]])
            let ret = try! Matft.linalg.eigen(a)
            // value
            XCTAssertEqual(ret.valRe, MfArray<Float>([0, 0]))
            XCTAssertEqual(ret.valIm, MfArray<Float>([1, -1]))
            // vector-left
            XCTAssertEqual(ret.lvecRe, MfArray<Float>([[-0.707106781186547, -0.707106781186547],
                                                [0.0, 0.0]]))
            XCTAssertEqual(ret.lvecIm, MfArray<Float>([[0.0, 0.0],
                                                [0.707106781186547, -0.707106781186547]]))
            // vector-right
            XCTAssertEqual(ret.rvecRe, MfArray<Float>([[0.707106781186547, 0.707106781186547],
                                                [0.0, 0.0]]))
            XCTAssertEqual(ret.rvecIm, MfArray<Float>([[0.0, 0.0],
                                                [-0.707106781186547, 0.707106781186547]]))
            
        }
    }
    
    func testSVD(){
        do{
            let a = MfArray<Int>([[2, 4, 1, 3],
                             [1, 5, 3, 2],
                             [5, 7, 0, 7]])
            let ret = try! Matft.linalg.svd(a)
            //astype is for avoiding minute error
            //XCTAssertEqual(ret.v.astype(.Float), MfArray<Int>([[-0.40783698, -0.12444751,  0.90453403],
            //                                              [-0.40538262, -0.86299238, -0.30151134],
            //                                              [-0.81812831,  0.48964985, -0.30151134]]))
            XCTAssertEqual(ret.s, MfArray<Float>([1.33853840e+01, 3.58210781e+00, 5.07054122e-16]))
            /*
             below assertion is failure... I don't know the reason...
             */
            //XCTAssertEqual(ret.rt.astype(.Float), MfArray<Int>([[-0.39682822, -0.70114979, -0.12132523, -0.57982456],
            //                                               [ 0.37306578, -0.38670052, -0.75749385,  0.37079333],
            //                                               [-0.67701194,  0.46970832, -0.56642431,  0.01387163],
            //                                               [-0.49497891, -0.37178726,  0.30107599,  0.72534362]]))
            //print(ret.v *& Matft.diag(v: ret.s) *& ret.rt)
            //print(ret.rt *& ret.rt.T)
            
            let ret_nofull = try! Matft.linalg.svd(a, full_mtrices: false)
            
            XCTAssertEqual((ret_nofull.v *& Matft.diag(v: ret_nofull.s) *& ret_nofull.rt).nearest(), a.astype(Int32.self))
        }
        
        do{
            let a = MfArray<Int>([[1, 2],
                             [3, 4]])
            let ret = try! Matft.linalg.svd(a)
            XCTAssertEqual(ret.v, MfArray<Float>([[-0.40455358, -0.9145143 ],
                                           [-0.9145143 ,  0.40455358]]))
            XCTAssertEqual(ret.s, MfArray<Float>([ 5.4649857 ,  0.36596619]))
            XCTAssertEqual(ret.rt, MfArray<Float>([[-0.57604844, -0.81741556],
                                            [ 0.81741556, -0.57604844]]))
            
            //XCTAssertEqual((ret.v *& Matft.diag(v: ret.s) *& ret.rt).nearest(), a)
        }
        
    }
    
    func testPolar(){
        do{
            let a = MfArray<Int>([[1, -1],
                             [2, 4]])
            let retR = try! Matft.linalg.polar_right(a)
            XCTAssertEqual(retR.u, MfArray<Float>([[ 0.85749293, -0.51449576],
                                           [ 0.51449576,  0.85749293]]))
            XCTAssertEqual(retR.p, MfArray<Float>([[ 1.88648444,  1.2004901 ],
                                           [ 1.2004901 ,  3.94446746]]))
            
            let retL = try! Matft.linalg.polar_left(a)
            XCTAssertEqual(retL.l, MfArray<Float>([[ 0.85749293, -0.51449576],
                                            [ 0.51449576,  0.85749293]]))
            XCTAssertEqual(retL.p, MfArray<Float>([[ 1.37198868, -0.34299717],
                                            [-0.34299717,  4.45896321]]))
            
        }
        do{
            let a = MfArray<Float>([[0.5, 1, 2],
                             [1.5, 3, 4],
                             [2, 3.5, 1]])
            let retR = try! Matft.linalg.polar_right(a)
            XCTAssertEqual(retR.u, MfArray<Float>([[ 0.72794019, -0.42246022,  0.54002819],
                                                          [-0.28527167,  0.52959999,  0.79883911],
                                                          [ 0.62347667,  0.73556183, -0.26500119]]))
            XCTAssertEqual(retR.p, MfArray<Float>([[1.18301594, 2.05429354, 0.93827039],
                                                           [2.05429354, 3.74080617, 2.00904136],
                                                           [0.93827039, 2.00904136, 4.01041163]]))
            let retL = try! Matft.linalg.polar_left(a)
            XCTAssertEqual(retL.l, MfArray<Float>([[ 0.72794019, -0.42246022,  0.54002819],
                                                           [-0.28527167,  0.52959999,  0.79883911],
                                                           [ 0.62347667,  0.73556183, -0.26500119]]))
            XCTAssertEqual(retL.p, MfArray<Float>([[1.02156625, 1.98464238, 0.51729779],
                                                           [1.98464238, 4.35624892, 2.08189576],
                                                           [0.51729779, 2.08189576, 3.55641857]]))
            
        }
    }
    
    func testNorm_vec(){
        do{
            let a = Matft.arange(start: 0, to: 16, by: 1, shape: [2,2,2,2])
            
            XCTAssertEqual(Matft.linalg.normlp_vec(a, ord: 2, axis: 3).round(decimals: 4),
                           MfArray<Float>([[[ 1.0        ,  3.60555128],
                                     [ 6.40312424,  9.21954446]],

                                    [[12.04159458, 14.86606875],
                                     [17.69180601, 20.51828453]]]).round(decimals: 4))
            XCTAssertEqual(Matft.linalg.normlp_vec(a, ord: 2, axis: 0).round(decimals: 4),
                           MfArray<Float>([[[ 8.0        ,  9.05538514],
                                     [10.19803903, 11.40175425]],

                                    [[12.64911064, 13.92838828],
                                     [15.23154621, 16.55294536]]]).round(decimals: 4))
            
            XCTAssertEqual(Matft.linalg.normlp_vec(a, ord: 0, axis: 0).round(decimals: 4),
            MfArray<Float>([[[1.0, 2.0],
                      [2.0, 2.0]],

                     [[2.0, 2.0],
                      [2.0, 2.0]]]).round(decimals: 4))
            
            XCTAssertEqual(Matft.linalg.normlp_vec(a, ord: Float.infinity, axis: -1).round(decimals: 4),
            MfArray<Float>([[[ 1.0,  3.0],
                      [ 5.0,  7.0]],

                     [[ 9.0, 11.0],
                      [13.0, 15.0]]]).round(decimals: 4))
        }
        
    }
    
    func testNormlp_mat(){
        do{
            let a = Matft.arange(start: 0, to: 16, by: 1, shape: [2,2,2,2])
            XCTAssertEqual(Matft.linalg.normlp_mat(a, ord: 2, axes: (3, 1)).round(decimals: 4),
                           MfArray<Float>([[ 6.45100985,  9.89123156],
                                    [21.40011829, 25.3372271 ]]).round(decimals: 4))
            XCTAssertEqual(Matft.linalg.normlp_mat(a, ord: 2, axes: (0, -1)).round(decimals: 4),
                           MfArray<Float>([[12.06483816, 15.28810568],
                                    [18.81008019, 22.49163147]]).round(decimals: 4))
            
            XCTAssertEqual(Matft.linalg.normlp_mat(a, ord: -1, axes: (2, 3)).round(decimals: 4),
            MfArray<Float>([[ 2.0, 10.0],
                     [18.0, 26.0]]).round(decimals: 4))
            
            XCTAssertEqual(Matft.linalg.normlp_mat(a, ord: Float.infinity, axes: (-1, 0)).round(decimals: 4),
            MfArray<Float>([[10.0, 14.0],
                     [18.0, 22.0]]).round(decimals: 4))
        }
        
    }
    
    func testNormFro_mat(){
        
        do{
            let a = Matft.arange(start: 0, to: 16, by: 1, shape: [2,2,2,2])
            
            XCTAssertEqual(Matft.linalg.normfro_mat(a, axes: (2, 0), keepDims: false).round(decimals: 4),
                           MfArray<Float>([[12.9614814 , 14.56021978],
                                    [19.79898987, 21.63330765]]).round(decimals: 4))
            XCTAssertEqual(Matft.linalg.normfro_mat(a, axes: (-2, 1), keepDims: false).round(decimals: 4),
                           MfArray<Float>([[ 7.48331477,  9.16515139],
                                    [22.44994432, 24.41311123]]).round(decimals: 4))
            
        }
    }
    
    func testNormNuc_mat(){
        do{
            let a = Matft.arange(start: 0, to: 16, by: 1, shape: [2,2,2,2])
            
            XCTAssertEqual(Matft.linalg.normnuc_mat(a, axes: (2, 0), keepDims: false).round(decimals: 4),
                           MfArray<Float>([[14.14213562, 15.62049935],
                                    [20.59126028, 22.36067977]]).round(decimals: 4))
            XCTAssertEqual(Matft.linalg.normnuc_mat(a, axes: (-2, 1), keepDims: false).round(decimals: 4),
                           MfArray<Float>([[ 8.48528137, 10.0        ],
                                    [22.8035085 , 24.73863375]]).round(decimals: 4))
            
        }
    }
}

