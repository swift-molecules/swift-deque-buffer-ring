public import Buffer_Primitive
public import Deque
public import Buffer_Ring_Primitive
public import Memory_Allocator_Primitive
public import Memory_Heap
public import Queue_Primitive
public import Storage_Contiguous
public import Store_Protocol

extension __Queue where S: Store.`Protocol` & ~Copyable {

    public typealias DoubleEnded =
        __QueueDoubleEnded<
            Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<S.Element>>.Ring
        >
}
