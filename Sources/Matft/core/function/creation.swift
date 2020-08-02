//
//  creation.swift
//  Matft
//
//  Created by Junnosuke Kado on 2020/02/26.
//  Copyright © 2020 jkado. All rights reserved.
//

import Foundation
import Accelerate

extension Matft{
    /**
       Create shallow copy of mfarray. Shallow means copied mfarray will be  sharing data with original one
       - parameters:
           - mfarray: mfarray
    */
    static public func shallowcopy<T: MfTypable>(_ mfarray: MfArray<T>) -> MfArray<T>{
        let newstructure = copy_mfstructure(mfarray.mfstructure)
        
        return MfArray(base: mfarray, mfstructure: newstructure, offset: mfarray.offsetIndex)
    }
    /**
       Create deep copy of mfarray. Deep means copied mfarray will be different object from original one
       - parameters:
            - mfarray: mfarray
            - order: (Optional) order, default is nil, which means close to either row or column major if possibe.
    */
    static public func deepcopy<T: MfTypable>(_ mfarray: MfArray<T>, order: MfOrder? = nil) -> MfArray<T>{
        if let order = order{
            switch order {
            case .Row:
                return to_row_major(mfarray)
            case .Column:
                return to_column_major(mfarray)
            }
        }
        else{
            if mfarray.mfflags.column_contiguous || mfarray.mfflags.row_contiguous{// all including strides will be copied
                return copyAll(mfarray)
            }
            if !(mfarray.withStridesUnsafeMBPtr{ isReverse($0) }) && !mfarray.mfdata._isView{// not contain reverse and is not view, copy all
                return copyAll(mfarray)
            }
            else{//close to row major
                return to_row_major(mfarray)
            }

        }
        
        /*
        let newdata = Matft.mfdata.deepcopy(mfarray.mfdata)
        let newarray = MfArray(mfdata: newdata)
        return newarray*/
    }
    /**
       Create same value's mfarray
       - parameters:
            - value: the value of T, which must conform to MfTypable protocol
            - shape: shape
            - mftype: (Optional) the type of mfarray
            - order: (Optional) order, default is nil, which means close to row major
    */
    static public func nums<T: MfTypable>(_ value: T, shape: [Int], mforder: MfOrder = .Row) -> MfArray<T>{
        var shape = shape
        let size = shape.withUnsafeMutableBufferPointer{
            shape2size($0)
        }
        
        let newmfdata = withDummyDataMRPtr(T.self, storedSize: size){
            ptr in
            switch MfType.storedType(T.self){
            case .Float:
                var arr = Array(repeating: Float.from(value), count: size)
                let ptrF = ptr.bindMemory(to: Float.self, capacity: size)
                arr.withUnsafeMutableBufferPointer{
                    ptrF.moveAssign(from: $0.baseAddress!, count: size)
                }
            case .Double:
                var arr = Array(repeating: Double.from(value), count: size)
                let ptrD = ptr.bindMemory(to: Double.self, capacity: size)
                arr.withUnsafeMutableBufferPointer{
                    ptrD.moveAssign(from: $0.baseAddress!, count: size)
                }
            }

        }
        
        let newmfstructure = create_mfstructure(&shape, mforder: mforder)
        
        return MfArray(mfdata: newmfdata, mfstructure: newmfstructure)
    }
    /**
       Create same value with passed mfarray's structure
       - parameters:
            - value: the value of T, which must conform to MfTypable protocol
            - mfarray: mfarray
    */
    static public func nums_like<T: MfTypable>(_ value: T, mfarray: MfArray<T>, mforder: MfOrder = .Row) -> MfArray<T>{
        return Matft.nums(value, shape: mfarray.shape, mforder: mforder)
    }
    /**
       Create arithmetic sequence mfarray
       - parameters:
            - start: the start term of arithmetic sequence
            - stop: the end term of arithmetic sequence, which is not included.
            - shape: (Optional) shape
            - mftype: (Optional) the type of mfarray
            - order: (Optional) order, default is nil, which means close to row major
    */
    static public func arange<T: MfNumeric>(start: T, to: T, by: T.Stride, shape: [Int]? = nil, mforder: MfOrder = .Row) -> MfArray<T>{
        return MfArray(Array(stride(from: start, to: to, by: by)), shape: shape, mforder: mforder)
    }
    /**
       Create identity matrix. The size is (dim, dim)
       - parameters:
            - dim: the dimension, returned mfarray's shape is (dim, dim)
            - mftype: (Optional) the type of mfarray
            - order: (Optional) order, default is nil, which means close to row major
    */
    static public func eye<T: MfNumeric>(dim: Int, mforder: MfOrder = .Row) -> MfArray<T>{
        var eye = Array(repeating: Array(repeating: 0, count: dim), count: dim)
        for i in 0..<dim{
            eye[i][i] = 1
        }
        return MfArray(eye, mforder: mforder)
    }
    /**
       Create diagonal matrix. The size is (dim, dim)
       - parameters:
            - v: the diagonal values, returned mfarray's shape is (dim, dim), whose dim is length of v
            - mftype: (Optional) the type of mfarray
            - order: (Optional) order, default is nil, which means close to row major
    */
    static public func diag<T: MfNumeric>(v: [T], mforder: MfOrder = .Row) -> MfArray<T>{
        let dim = v.count
        var d = Array(repeating: Array(repeating: T.zero, count: dim), count: dim)
        for i in 0..<dim{
            d[i][i] = v[i]
        }
        return MfArray(d, mforder: mforder)
    }
    static public func diag<T: MfTypable>(v: MfArray<T>, mforder: MfOrder = .Row) -> MfArray<T>{
        precondition(v.ndim == 1, "must be 1d")
        let dim = v.size
        let size = dim*dim
        var shape = [dim, dim]
        
        let newmfdata = withDummyDataMRPtr(T.self, storedSize: size){
            ptr in
            switch MfType.storedType(T.self){
            case .Float:
                let ptrF = ptr.bindMemory(to: Float.self, capacity: size)
                var d = Array(repeating: Float.zero, count: size)
                v.withDataUnsafeMBPtrT(datatype: Float.self){
                    for i in 0..<dim{
                        d[i*dim+i] = $0[i]
                    }
                }
                d.withUnsafeMutableBufferPointer{
                    ptrF.moveAssign(from: $0.baseAddress!, count: size)
                }
            case .Double:
                let ptrD = ptr.bindMemory(to: Double.self, capacity: size)
                var d = Array(repeating: Double.zero, count: size)
                v.withDataUnsafeMBPtrT(datatype: Double.self){
                    for i in 0..<dim{
                        d[i*dim+i] = $0[i]
                    }
                }
                d.withUnsafeMutableBufferPointer{
                    ptrD.moveAssign(from: $0.baseAddress!, count: size)
                }
            }

        }
        
        let newmfstructure = create_mfstructure(&shape, mforder: mforder)
        
        return MfArray(mfdata: newmfdata, mfstructure: newmfstructure)
        
    }
    /**
       Concatenate given arrays vertically(for row)
       - parameters:
            - mfarrays: the array of MfArray.
    */
    static public func vstack<T: MfTypable>(_ mfarrays: [MfArray<T>]) -> MfArray<T> {
        if mfarrays.count == 1{
            return mfarrays[0].deepcopy()
        }
        
        var retShape = mfarrays.first!.shape // shape except for given axis first, return shape later
        var concatDim = retShape.remove(at: 0)
        
        //check if argument is valid or not
        for i in 1..<mfarrays.count{
            var shapeExceptAxis = mfarrays[i].shape
            concatDim += shapeExceptAxis.remove(at: 0)
            
            precondition(retShape == shapeExceptAxis, "all the input array dimensions except for the concatenation axis must match exactly")
        }
        
        retShape.insert(concatDim, at: 0)// return shape
        
        let rmajorArrays = mfarrays.map{ Matft.conv_order($0, mforder: .Row) }
        let retSize = shape2size(&retShape)
        
        let newmfdata = withDummyDataMRPtr(T.self, storedSize: retSize){
            dstptr in
            switch MfType.storedType(T.self){
            case .Float:
                let dstptrF = dstptr.bindMemory(to: Float.self, capacity: retSize)
                var offset = 0
                for array in rmajorArrays{
                    array.withDataUnsafeMBPtrT(datatype: Float.self){
                        [unowned array] in
                        copy_unsafeptrT(array.storedSize, $0.baseAddress!, 1, dstptrF + offset, 1, cblas_scopy)
                    }
                    offset += array.storedSize
                }
                
            case .Double:
                let dstptrD = dstptr.bindMemory(to: Double.self, capacity: retSize)
                var offset = 0
                for array in rmajorArrays{
                    array.withDataUnsafeMBPtrT(datatype: Double.self){
                        [unowned array] in
                        copy_unsafeptrT(array.storedSize, $0.baseAddress!, 1, dstptrD + offset, 1, cblas_dcopy)
                    }
                    offset += array.storedSize
                }
            }
        }
        
        let newmfstructure = create_mfstructure(&retShape, mforder: .Row)
        
        return MfArray(mfdata: newmfdata, mfstructure: newmfstructure)
    }
    /**
       Concatenate given arrays horizontally(for column)
       - parameters:
            - mfarrays: the array of MfArray.
    */
    static public func hstack<T: MfTypable>(_ mfarrays: [MfArray<T>]) -> MfArray<T> {
        if mfarrays.count == 1{
            return mfarrays[0].deepcopy()
        }
        
        var retShape = mfarrays.first!.shape // shape except for given axis first, return shape later
        var concatDim = retShape.remove(at: retShape.count - 1)
        
        //check if argument is valid or not
        for i in 1..<mfarrays.count{
            var shapeExceptAxis = mfarrays[i].shape
            concatDim += shapeExceptAxis.remove(at: shapeExceptAxis.count - 1)
            
            precondition(retShape == shapeExceptAxis, "all the input array dimensions except for the concatenation axis must match exactly")
        }
        
        retShape.insert(concatDim, at: retShape.endIndex)// return shape
        
        let cmajorArrays = mfarrays.map{ Matft.conv_order($0, mforder: .Column) }
        let retSize = shape2size(&retShape)
        
        let newmfdata = withDummyDataMRPtr(T.self, storedSize: retSize){
            dstptr in
            switch MfType.storedType(T.self){
            case .Float:
                let dstptrF = dstptr.bindMemory(to: Float.self, capacity: retSize)
                var offset = 0
                for array in cmajorArrays{
                    array.withDataUnsafeMBPtrT(datatype: Float.self){
                        [unowned array] in
                        copy_unsafeptrT(array.storedSize, $0.baseAddress!, 1, dstptrF + offset, 1, cblas_scopy)
                    }
                    offset += array.storedSize
                }
                
            case .Double:
                let dstptrD = dstptr.bindMemory(to: Double.self, capacity: retSize)
                var offset = 0
                for array in cmajorArrays{
                    array.withDataUnsafeMBPtrT(datatype: Double.self){
                        [unowned array] in
                        copy_unsafeptrT(array.storedSize, $0.baseAddress!, 1, dstptrD + offset, 1, cblas_dcopy)
                    }
                    offset += array.storedSize
                }
            }
        }
        
        let newmfstructure = create_mfstructure(&retShape, mforder: .Column)
        
        return MfArray(mfdata: newmfdata, mfstructure: newmfstructure)
    }
    /**
       Concatenate given arrays for arbitrary axis
       - parameters:
            - mfarrays: the array of MfArray.
            - axis: the axis to concatenate
    */
    static public func concatenate<T: MfTypable>(_ mfarrays: [MfArray<T>], axis: Int = 0) -> MfArray<T>{
        if mfarrays.count == 1{
            return mfarrays[0].deepcopy()
        }
        
        var retShape = mfarrays.first!.shape // shape except for given axis first, return shape later
        let retndim = mfarrays.first!.ndim
        let axis = get_axis(axis, ndim: retndim)
        
        if axis == 0{// vstack is faster than this function
            return Matft.vstack(mfarrays)
        }
        else if axis == retndim - 1{// hstack is faster than this function
            return Matft.hstack(mfarrays)
        }
    
        
        var concatDim = retShape.remove(at: axis)
        
        //check if argument is valid or not
        for i in 1..<mfarrays.count{
            var shapeExceptAxis = mfarrays[i].shape
            concatDim += shapeExceptAxis.remove(at: axis)
            
            precondition(retShape == shapeExceptAxis, "all the input array dimensions except for the concatenation axis must match exactly")
        }
        
        retShape.insert(concatDim, at: axis)// return shape
        
        var columnShape = retShape // the left side shape splited by axis, must have more than one elements
        columnShape.removeSubrange(axis..<retShape.count)
        let columnSize = shape2size(&columnShape)
        var rowShape = retShape// the right side shape splited by axis, must have more than one elements
        rowShape.removeSubrange(0...axis)
        let rowSize = shape2size(&rowShape)
        
        let fasterOrder = rowSize >= columnSize ? MfOrder.Row : MfOrder.Column
        let fasterBlockSize = rowSize >= columnSize ? rowSize : columnSize
        let slowerBlockSize = rowSize >= columnSize ? columnSize : rowSize
        
        let majorArrays = mfarrays.map{ Matft.conv_order($0, mforder: fasterOrder) }
        let retSize = shape2size(&retShape)
        
        let newmfdata = withDummyDataMRPtr(T.self, storedSize: retSize){
            dstptr in
            switch MfType.storedType(T.self){
            case .Float:
                let dstptrF = dstptr.bindMemory(to: Float.self, capacity: retSize)
    
                var dst_offset = 0
                for sb in 0..<slowerBlockSize{
                    for array in majorArrays{
                        let concatSize = array.shape[axis]
                        
                        array.withDataUnsafeMBPtrT(datatype: Float.self){
                            copy_unsafeptrT(fasterBlockSize * concatSize, $0.baseAddress! + sb * fasterBlockSize * concatSize, 1, dstptrF + dst_offset, 1, cblas_scopy)
                        }
                        dst_offset += fasterBlockSize * concatSize
                    }
                }
                
            case .Double:
                let dstptrD = dstptr.bindMemory(to: Double.self, capacity: retSize)
                var dst_offset = 0
                for sb in 0..<slowerBlockSize{
                    for array in majorArrays{
                        let concatSize = array.shape[axis]
                        
                        array.withDataUnsafeMBPtrT(datatype: Double.self){
                            copy_unsafeptrT(fasterBlockSize * concatSize, $0.baseAddress! + sb * fasterBlockSize * concatSize, 1, dstptrD + dst_offset, 1, cblas_dcopy)
                        }
                        dst_offset += fasterBlockSize * concatSize
                    }
                }
            }
        }
        
        let newmfstructure = create_mfstructure(&retShape, mforder: fasterOrder)
        
        return MfArray(mfdata: newmfdata, mfstructure: newmfstructure)
    }
}
/*
extension Matft.mfdata{
    /**
       Create deep copy of mfdata. Deep means copied mfdata will be different object from original one
       - parameters:
            - mfdata: mfdata
    */
    static public func deepcopy(_ mfdata: MfData) -> MfData{

        //copy shape
        let shapeptr = create_unsafeMPtrT(type: Int.self, count: mfdata._ndim)
        shapeptr.assign(from: mfdata._shape, count: mfdata._ndim)
        
        //copy strides
        let stridesptr = create_unsafeMPtrT(type: Int.self, count: mfdata._ndim)
        stridesptr.assign(from: mfdata._strides, count: mfdata._ndim)
        
        //copy data
        switch mfdata._storedType {
        case .Float:
            let dataptr = create_unsafeMRPtr(type: Float.self, count: mfdata._size)
            dataptr.assumingMemoryBound(to: Float.self).assign(from: mfdata._data.assumingMemoryBound(to: Float.self), count: mfdata._storedSize)
            return MfData(dataptr: dataptr, storedSize: mfdata._storedSize, shapeptr: shapeptr, mftype: mfdata._mftype, ndim: mfdata._ndim, stridesptr: stridesptr)
        case .Double:
            let dataptr = create_unsafeMRPtr(type: Double.self, count: mfdata._size)
            dataptr.assumingMemoryBound(to: Double.self).assign(from: mfdata._data.assumingMemoryBound(to: Double.self), count: mfdata._storedSize)
            return MfData(dataptr: dataptr, storedSize: mfdata._storedSize, shapeptr: shapeptr, mftype: mfdata._mftype, ndim: mfdata._ndim, stridesptr: stridesptr)
        }
    }
    /**
       Create shallow copy of mfdata. Shallow means copied mfdata will be  sharing data with original one
       - parameters:
           - mfdata: mfdata
    */
    static public func shallowcopy(_ mfdata: MfData) -> MfData{
        //copy shape
        let shapeptr = create_unsafeMPtrT(type: Int.self, count: mfdata._ndim)
        shapeptr.assign(from: mfdata._shape, count: mfdata._ndim)
        
        //copy strides
        let stridesptr = create_unsafeMPtrT(type: Int.self, count: mfdata._ndim)
        stridesptr.assign(from: mfdata._strides, count: mfdata._ndim)
        
        let newmfdata = MfData(refdata: mfdata, offset: 0, shapeptr: shapeptr, ndim: mfdata._ndim, mforder: mfdata._order, stridesptr: stridesptr)
        
        return newmfdata
    }
}
*/
