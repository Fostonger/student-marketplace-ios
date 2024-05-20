import Foundation
//import Starscream

class WebSocketService {
//    private var socket: WebSocket!
//    private var isConnected = false
//    private let serverURL: URL
//    
//    init(serverURL: URL) {
//        self.serverURL = serverURL
//    }
//    
//    func connect() {
//        var request = URLRequest(url: serverURL)
//        request.timeoutInterval = 5
//        socket = WebSocket(request: request)
//        socket.delegate = self
//        socket.connect()
//    }
//    
//    func disconnect() {
//        socket.disconnect()
//    }
//    
//    func sendMessage(_ message: String) {
//        if isConnected {
//            socket.write(string: message)
//        }
//    }
//    
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(let headers):
//            isConnected = true
//            print("WebSocket connected: \(headers)")
//        case .disconnected(let reason, let code):
//            isConnected = false
//            print("WebSocket disconnected: \(reason) with code: \(code)")
//        case .text(let string):
//            print("Received text: \(string)")
//        case .binary(let data):
//            print("Received data: \(data.count)")
//        case .ping(_):
//            break
//        case .pong(_):
//            break
//        case .viabilityChanged(_):
//            break
//        case .reconnectSuggested(_):
//            break
//        case .cancelled:
//            isConnected = false
//        case .error(let error):
//            isConnected = false
//            handleError(error)
//        }
//    }
//    
//    private func handleError(_ error: Error?) {
//        if let e = error as? WSError {
//            print("WebSocket encountered an error: \(e.message)")
//        } else if let e = error {
//            print("WebSocket encountered an error: \(e.localizedDescription)")
//        } else {
//            print("WebSocket encountered an unknown error")
//        }
//    }
}
