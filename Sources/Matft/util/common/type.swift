//
//  File.swift
//  
//
//  Created by AM19A0 on 2020/05/20.
//

import Foundation
import Accelerate

internal func to_Bool(_ mfarray: MfArray, thresholdF: Float = 1e-5, thresholdD: Double = 1e-10) -> MfArray{
    //convert float and contiguous
    let ret = mfarray.astype(.Float)
    // TODO: use vDSP_vthr?
    switch ret.storedType {
    case .Float:
        ret.withDataUnsafeMBPtrT(datatype: Float.self){
            [unowned ret] (dataptr) in
            var newptr = dataptr.map{ abs($0) <= thresholdF ? Float.zero : Float(1) }
            newptr.withUnsafeMutableBufferPointer{
                dataptr.baseAddress!.moveAssign(from: $0.baseAddress!, count: ret.storedSize)
            }
        }
    case .Double:
        fatalError("Bug was occurred. Bool's storedType is not double.")
    }
    
    ret.mfdata._mftype = .Bool
    return ret
}

internal func to_Bool_mm_op<U: MfStorable>(l_mfarray: MfArray, r_mfarray: MfArray, op: (U, U) -> Bool) -> MfArray{
    assert(l_mfarray.shape == r_mfarray.shape, "call biop_broadcast_to first!")
    var retShape = l_mfarray.shape
    var i = 0
    let newdata = withDummyDataMRPtr(.Bool, storedSize: l_mfarray.size){
        dstptr in
        let dstptrT = dstptr.bindMemory(to: Float.self, capacity: l_mfarray.size)
        withDataMBPtr_multi(datatype: U.self, l_mfarray, r_mfarray){
            lptr, rptr in
            var val = op(lptr.baseAddress!.pointee, rptr.baseAddress!.pointee) ? Float(1) : Float.zero
            (dstptrT + i).assign(from: &val, count: 1)
            i += 1
        }
    }
    let newmfstructure = create_mfstructure(&retShape, mforder: .Row)
    
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}
/**
    - Important: Note that exchange l_mfarray and r_mfarray when use less
 */
internal func to_Bool_mm_greater<U: MfStorable>(l_mfarray: MfArray, r_mfarray: MfArray, dummyU: U, lesseq: Bool = false) -> MfArray{
    assert(l_mfarray.shape == r_mfarray.shape, "call biop_broadcast_to first!")
    let l_mfarray = check_contiguous(l_mfarray, .Row)
    let r_mfarray = check_contiguous(r_mfarray, .Row)
    var retShape = l_mfarray.shape
    let retSize = l_mfarray.size
    let newdata = withDummyDataMRPtr(.Bool, storedSize: l_mfarray.size){
        dstptr in
        let dstptrT = dstptr.bindMemory(to: Float.self, capacity: l_mfarray.size)
        l_mfarray.withDataUnsafeMBPtrT(datatype: U.self){
            lptr in
            r_mfarray.withDataUnsafeMBPtrT(datatype: U.self){
                rptr in
                var newptr = lesseq ? zip(lptr, rptr).map{$0 <= $1 ? Float.zero : Float(1)} : zip(lptr, rptr).map{$0 > $1 ? Float.zero : Float(1)}
                newptr.withUnsafeMutableBufferPointer{
                    dstptrT.moveAssign(from: $0.baseAddress!, count: retSize)
                }
            }
        }
        
    }
    let newmfstructure = create_mfstructure(&retShape, mforder: .Row)
    
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}
// I don't know why this function is 2 times slower than below to_Bool_ms_greater...
internal func to_Bool_ms_op<U: MfStorable>(mfarray: MfArray, scalar: U, op: (U, U) -> Bool) -> MfArray{
    let scalar = U.from(scalar)
    
    //let mfarray = check_contiguous(mfarray)
    var shape = mfarray.shape
    var strides = mfarray.strides
    
    let newdata = withDummyDataMRPtr(.Bool, storedSize: mfarray.storedSize){
        dstptr in
        let dstptrT = dstptr.bindMemory(to: Float.self, capacity: mfarray.size)
        mfarray.withDataUnsafeMBPtrT(datatype: U.self){
            [unowned mfarray](srcptr) in
            var newptr = srcptr.map{ op($0, scalar) ? Float.zero : Float(1) }
            newptr.withUnsafeMutableBufferPointer{
                dstptrT.moveAssign(from: $0.baseAddress!, count: mfarray.storedSize)
            }
            
        }
    }
    
    let newmfstructure = create_mfstructure(&shape, &strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}
/**
    - Important: if lesseq is true, <=
 */
internal func to_Bool_ms_greater<U: MfStorable>(l_mfarray: MfArray, r_scalar: U, lesseq: Bool = false) -> MfArray{
    let scalar = U.from(r_scalar)
    
    //let mfarray = check_contiguous(mfarray)
    var shape = l_mfarray.shape
    var strides = l_mfarray.strides
    
    let newdata = withDummyDataMRPtr(.Bool, storedSize: l_mfarray.storedSize){
        dstptr in
        let dstptrT = dstptr.bindMemory(to: Float.self, capacity: l_mfarray.size)
        l_mfarray.withDataUnsafeMBPtrT(datatype: U.self){
            [unowned l_mfarray](srcptr) in
            var newptr = lesseq ? srcptr.map{ $0 <= scalar ? Float.zero : Float(1) } : srcptr.map{ $0 > scalar ? Float.zero : Float(1) }
            newptr.withUnsafeMutableBufferPointer{
                dstptrT.moveAssign(from: $0.baseAddress!, count: mfarray.storedSize)
            }
            
        }
    }
    
    let newmfstructure = create_mfstructure(&shape, &strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}
/**
    - Important: if greatereq is true, >=
 */
internal func to_Bool_ms_less<U: MfStorable>(l_mfarray: MfArray, r_scalar: U, greatereq: Bool = false) -> MfArray{
    let scalar = U.from(r_scalar)
    
    //let mfarray = check_contiguous(mfarray)
    var shape = l_mfarray.shape
    var strides = l_mfarray.strides
    
    let newdata = withDummyDataMRPtr(.Bool, storedSize: l_mfarray.storedSize){
        dstptr in
        let dstptrT = dstptr.bindMemory(to: Float.self, capacity: l_mfarray.size)
        l_mfarray.withDataUnsafeMBPtrT(datatype: U.self){
            [unowned l_mfarray](srcptr) in
            var newptr = greatereq ? srcptr.map{ $0 >= scalar ? Float.zero : Float(1) } : srcptr.map{ $0 < scalar ? Float.zero : Float(1) }
            newptr.withUnsafeMutableBufferPointer{
                dstptrT.moveAssign(from: $0.baseAddress!, count: mfarray.storedSize)
            }
            
        }
    }
    
    let newmfstructure = create_mfstructure(&shape, &strides)
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}

/**
   - Important: this function creates copy bool mfarray, not view!
 */
internal func bool_broadcast_to(_ mfarray: MfArray, shape: [Int]) -> MfArray{
    assert(mfarray.mftype == .Bool, "must be bool")
    var mfarray = mfarray
    
    let origSize = mfarray.size
    
    let new_ndim = shape.count
    var retShape = shape
    let retSize = shape2size(&retShape)
    
    
    let idim_start = new_ndim  - mfarray.ndim
    
    precondition(idim_start >= 0, "can't broadcast to fewer dimensions")
    
    // broadcast for common part's shape
    let commonShape = Array(shape[0..<mfarray.ndim])
    mfarray = mfarray.broadcast_to(shape: commonShape)
    
    // convert row contiguous
    let rowc_mfarray = check_contiguous(mfarray, .Row)

    if idim_start == 0{
        return rowc_mfarray
    }
    var newerShape = Array(shape[mfarray.ndim..<new_ndim])
    let offset = shape2size(&newerShape)
    
    let newdata = withDummyDataMRPtr(.Bool, storedSize: retSize){
        var dstptrF = $0.bindMemory(to: Float.self, capacity: retSize)
        
        rowc_mfarray.withDataUnsafeMBPtrT(datatype: Float.self){
            srcptr in
            for i in 0..<origSize{
                dstptrF.assign(repeating: (srcptr.baseAddress! + i).pointee, count: offset)
                dstptrF += offset
            }
        }
        
    }
    let newmfstructure = create_mfstructure(&retShape, mforder: .Row)
    
    return MfArray(mfdata: newdata, mfstructure: newmfstructure)
}

internal func boolean2float(_ mfarray: MfArray) -> MfArray{
    if mfarray.mftype == .Bool{
        mfarray.mfdata._mftype = .Float
    }
    return mfarray
}
