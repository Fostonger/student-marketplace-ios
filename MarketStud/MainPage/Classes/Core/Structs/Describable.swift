import Foundation

protocol Describable {
    var id: Int64 { get }
    var description: String { get }
}

protocol URLQueryRepresentable {
    func asQueryItem() -> URLQueryItem?
}
