import Foundation
import JSONSchema

extension JSONValue {
    /// Decode a schema fragment into the fields this generator needs to modify.
    func decoded<T: Decodable>(as type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: JSONEncoder().encode(self))
    }
}
