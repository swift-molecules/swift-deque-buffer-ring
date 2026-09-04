public import Buffer_Primitive
public import Buffer_Ring_Bounded_Primitive
public import Buffer_Ring_Primitive
public import Index
public import Memory_Allocator
public import Memory_Allocator_Protocol
public import Memory
public import Ownership_Shared_Primitive
public import Deque
public import Queue_Primitive
public import Storage_Memory

extension __QueueDoubleEnded where S: ~Copyable {

    @inlinable
    public mutating func push<E: ~Copyable, Resource: Memory.Growable & ~Copyable>(
        _ element: consuming E,
        to position: Position
    )
    where S == Buffer<Storage::Storage<Memory.Allocator<Resource>>.Contiguous<E>>.Ring {
        switch position {
        case .front:
            store.pushFront(element)

        case .back:
            store.pushBack(element)
        }
    }

    @inlinable
    public mutating func push<E: ~Copyable>(_ element: consuming E, to position: Position)
    where
        S == Ownership.Shared<E, Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring>
    {
        store.withUnique(consuming: element) { ring, element in
            switch position {
            case .front:
                ring.pushFront(element)

            case .back:
                ring.pushBack(element)
            }
        }
    }

    @inlinable
    public mutating func push<E: ~Copyable>(
        _ element: consuming E,
        to position: Position
    ) throws(__Queue<S>.Error)
    where S == Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded {
        let rejected: E?
        switch position {
        case .front:
            rejected = store.push.front(element)

        case .back:
            rejected = store.push.back(element)
        }
        guard rejected == nil else {
            throw .full
        }
    }

    @inlinable
    public mutating func push<E: ~Copyable>(
        _ element: consuming E,
        to position: Position
    ) throws(__Queue<S>.Error)
    where
        S == Ownership.Shared<
            E, Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded
        >
    {
        let rejected = store.withUnique(consuming: element) { ring, element -> E? in
            switch position {
            case .front:
                return ring.push.front(element)

            case .back:
                return ring.push.back(element)
            }
        }
        guard rejected == nil else {
            throw .full
        }
    }
}

extension __QueueDoubleEnded where S: ~Copyable {

    @inlinable
    public mutating func clear<E: ~Copyable, Resource: Memory.Growable & ~Copyable>(
        keepingCapacity: Bool = true
    )
    where S == Buffer<Storage::Storage<Memory.Allocator<Resource>>.Contiguous<E>>.Ring {
        store.removeAll()
        if !keepingCapacity {
            store = S(minimumCapacity: .zero)
        }
    }

    @inlinable
    public mutating func clear<E: ~Copyable>()
    where S == Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded {
        store.remove.all()
    }

    @inlinable
    public mutating func clear<E>(keepingCapacity: Bool = true)
    where
        S == Ownership.Shared<E, Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring>
    {
        let capacity: Index.Index<E>.Count = keepingCapacity ? store.capacity : .zero
        self.store = Ownership.Shared(
            Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring(
                minimumCapacity: capacity
            )
        )
    }

    @inlinable
    public mutating func clear<E>()
    where
        S == Ownership.Shared<
            E, Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded
        >
    {
        self.store = Ownership.Shared(
            Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded(
                minimumCapacity: store.capacity
            )
        )
    }
}

extension __QueueDoubleEnded where S: ~Copyable {

    @inlinable
    public mutating func reserve<E: ~Copyable, Resource: Memory.Growable & ~Copyable>(
        _ minimumCapacity: Index.Index<E>.Count
    )
    where S == Buffer<Storage::Storage<Memory.Allocator<Resource>>.Contiguous<E>>.Ring {
        store.reserveCapacity(minimumCapacity)
    }

    @inlinable
    public mutating func reserve<E: ~Copyable>(_ minimumCapacity: Index.Index<E>.Count)
    where
        S == Ownership.Shared<E, Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring>
    {
        store.withUnique { ring in
            ring.reserveCapacity(minimumCapacity)
        }
    }
}

extension __QueueDoubleEnded where S: ~Copyable {

    @inlinable
    public func clone<E, Resource: Memory.Growable & ~Copyable>() -> Self
    where S == Buffer<Storage::Storage<Memory.Allocator<Resource>>.Contiguous<E>>.Ring {
        Self(store: store.clone())
    }

    @inlinable
    public func clone<E>() -> Self
    where S == Buffer<Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Ring.Bounded {
        Self(store: store.clone())
    }
}
