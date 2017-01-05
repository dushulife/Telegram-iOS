import Foundation

private enum PeerOperationLogIndexNamespace: Int8 {
    case nextTagLocalIndex = 0
}

final class PeerOperationLogMetadataTable: Table {
    static func tableSpec(_ id: Int32) -> ValueBoxTable {
        return ValueBoxTable(id: id, keyType: .binary)
    }
    
    private func keyForNextLocalIndex(peerId: PeerId, tag: PeerOperationLogTag) -> ValueBoxKey {
        let key = ValueBoxKey(length: 1 + 8 + 1)
        key.setInt8(0, value: PeerOperationLogIndexNamespace.nextTagLocalIndex.rawValue)
        key.setInt64(1, value: peerId.toInt64())
        key.setInt8(9, value: tag.rawValue)
        return key
    }
    
    func getNextLocalIndex(peerId: PeerId, tag: PeerOperationLogTag) -> Int32 {
        if let value = self.valueBox.get(self.table, key: self.keyForNextLocalIndex(peerId: peerId, tag: tag)) {
            assert(value.length == 4)
            var index: Int32 = 0
            value.read(&index, offset: 0, length: 4)
            return index
        } else {
            return 0
        }
    }
    
    func setNextLocalIndex(peerId: PeerId, tag: PeerOperationLogTag, index: Int32) {
        var indexValue: Int32 = index
        self.valueBox.set(self.table, key: self.keyForNextLocalIndex(peerId: peerId, tag: tag), value: MemoryBuffer(memory: &indexValue, capacity: 4, length: 4, freeWhenDone: false))
    }
    
    func takeNextLocalIndex(peerId: PeerId, tag: PeerOperationLogTag) -> Int32 {
        let index = self.getNextLocalIndex(peerId: peerId, tag: tag)
        self.setNextLocalIndex(peerId: peerId, tag: tag, index: index)
        return index
    }
}
