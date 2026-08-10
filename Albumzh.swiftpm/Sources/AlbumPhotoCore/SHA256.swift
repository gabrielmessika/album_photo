import Foundation

/// Size and SHA-256 digest observed while reading one physical file.
public struct SHA256FileFingerprint: Sendable, Equatable {
    public let contentHash: String
    public let byteCount: Int64

    public init(contentHash: String, byteCount: Int64) {
        self.contentHash = contentHash
        self.byteCount = byteCount
    }
}

/// Incremental, dependency-free SHA-256 state. `finalize()` takes a snapshot:
/// callers may inspect the digest and then append more bytes if needed.
public struct SHA256IncrementalHasher: Sendable {
    public private(set) var byteCount: UInt64

    private static let initialState: [UInt32] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ]

    private static let constants: [UInt32] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
        0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
        0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
        0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
        0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
        0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ]

    private var state: [UInt32]
    private var pendingBytes: [UInt8]

    public init() {
        self.byteCount = 0
        self.state = Self.initialState
        self.pendingBytes = []
        self.pendingBytes.reserveCapacity(64)
    }

    /// Adds bytes without retaining the supplied `Data` after this call.
    public mutating func update(_ data: Data) {
        guard !data.isEmpty else { return }
        byteCount &+= UInt64(data.count)

        // One bounded copy per caller-provided chunk keeps the compression
        // implementation portable across Linux and Apple Foundation.
        let bytes = [UInt8](data)
        var offset = 0
        var schedule = Array(repeating: UInt32(0), count: 64)

        if !pendingBytes.isEmpty {
            let count = min(64 - pendingBytes.count, bytes.count)
            pendingBytes.append(contentsOf: bytes[..<count])
            offset = count
            if pendingBytes.count == 64 {
                Self.compress(
                    pendingBytes,
                    offset: 0,
                    state: &state,
                    schedule: &schedule
                )
                pendingBytes.removeAll(keepingCapacity: true)
            }
        }

        while bytes.count - offset >= 64 {
            Self.compress(
                bytes,
                offset: offset,
                state: &state,
                schedule: &schedule
            )
            offset += 64
        }

        if offset < bytes.count {
            pendingBytes.append(contentsOf: bytes[offset...])
        }
    }

    /// Returns the current digest without consuming the hasher state.
    public func finalize() -> [UInt8] {
        var finalizedState = state
        var finalBlocks = pendingBytes
        let bitLength = byteCount &* 8
        finalBlocks.append(0x80)
        while finalBlocks.count % 64 != 56 {
            finalBlocks.append(0)
        }
        finalBlocks.append(UInt8((bitLength >> 56) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 48) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 40) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 32) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 24) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 16) & 0xff))
        finalBlocks.append(UInt8((bitLength >> 8) & 0xff))
        finalBlocks.append(UInt8(bitLength & 0xff))

        var schedule = Array(repeating: UInt32(0), count: 64)
        for offset in stride(from: 0, to: finalBlocks.count, by: 64) {
            Self.compress(
                finalBlocks,
                offset: offset,
                state: &finalizedState,
                schedule: &schedule
            )
        }

        return finalizedState.flatMap { value in
            [
                UInt8((value >> 24) & 0xff),
                UInt8((value >> 16) & 0xff),
                UInt8((value >> 8) & 0xff),
                UInt8(value & 0xff)
            ]
        }
    }

    public func hexDigest() -> String {
        Self.hexString(finalize())
    }

    private static func compress(
        _ bytes: [UInt8],
        offset: Int,
        state: inout [UInt32],
        schedule: inout [UInt32]
    ) {
        for index in 0..<16 {
            let start = offset + index * 4
            schedule[index] = UInt32(bytes[start]) << 24
                | UInt32(bytes[start + 1]) << 16
                | UInt32(bytes[start + 2]) << 8
                | UInt32(bytes[start + 3])
        }
        for index in 16..<64 {
            let s0 = rotateRight(schedule[index - 15], by: 7)
                ^ rotateRight(schedule[index - 15], by: 18)
                ^ (schedule[index - 15] >> 3)
            let s1 = rotateRight(schedule[index - 2], by: 17)
                ^ rotateRight(schedule[index - 2], by: 19)
                ^ (schedule[index - 2] >> 10)
            schedule[index] = schedule[index - 16]
                &+ s0 &+ schedule[index - 7] &+ s1
        }

        var a = state[0]
        var b = state[1]
        var c = state[2]
        var d = state[3]
        var e = state[4]
        var f = state[5]
        var g = state[6]
        var h = state[7]

        for index in 0..<64 {
            let bigS1 = rotateRight(e, by: 6)
                ^ rotateRight(e, by: 11)
                ^ rotateRight(e, by: 25)
            let choice = (e & f) ^ ((~e) & g)
            let temp1 = h &+ bigS1 &+ choice &+ constants[index] &+ schedule[index]
            let bigS0 = rotateRight(a, by: 2)
                ^ rotateRight(a, by: 13)
                ^ rotateRight(a, by: 22)
            let majority = (a & b) ^ (a & c) ^ (b & c)
            let temp2 = bigS0 &+ majority
            h = g
            g = f
            f = e
            e = d &+ temp1
            d = c
            c = b
            b = a
            a = temp1 &+ temp2
        }

        state[0] &+= a
        state[1] &+= b
        state[2] &+= c
        state[3] &+= d
        state[4] &+= e
        state[5] &+= f
        state[6] &+= g
        state[7] &+= h
    }

    private static func rotateRight(_ value: UInt32, by amount: UInt32) -> UInt32 {
        (value >> amount) | (value << (32 - amount))
    }

    private static func hexString(_ bytes: [UInt8]) -> String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }
}

/// Dependency-free SHA-256 used by the Linux core and the Apple adapter.
/// 3:LOC-007 — identical bytes always resolve to the same lowercase hash.
public enum SHA256 {
    public static let defaultFileChunkSize = 1_048_576

    public static func digest(_ data: Data) -> [UInt8] {
        var hasher = SHA256IncrementalHasher()
        hasher.update(data)
        return hasher.finalize()
    }

    public static func hexDigest(_ data: Data) -> String {
        var hasher = SHA256IncrementalHasher()
        hasher.update(data)
        return hasher.hexDigest()
    }

    /// Reads at most `chunkSize` bytes at a time and derives both physical
    /// length and digest from the same pass over the file.
    public static func fingerprint(
        fileAt url: URL,
        chunkSize: Int = defaultFileChunkSize
    ) throws -> SHA256FileFingerprint {
        guard chunkSize > 0 else {
            throw DomainValidationError.persistenceFailure(
                "taille de bloc SHA-256 invalide"
            )
        }

        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256IncrementalHasher()
        var byteCount: Int64 = 0

        while let chunk = try handle.read(upToCount: chunkSize), !chunk.isEmpty {
            let (nextByteCount, overflow) = byteCount.addingReportingOverflow(
                Int64(chunk.count)
            )
            guard !overflow else {
                throw DomainValidationError.persistenceFailure(
                    "taille de fichier SHA-256 hors limites"
                )
            }
            byteCount = nextByteCount
            hasher.update(chunk)
        }

        return SHA256FileFingerprint(
            contentHash: hasher.hexDigest(),
            byteCount: byteCount
        )
    }
}
