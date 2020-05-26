//
//  TodoController.swift
//  WunderList
//
//  Created by Joe Veverka on 5/26/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation
import CoreData

// Helper Properties
enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
let baseURL = URL(string: "https://google.com/")!

class TodoController {

    var networkService: NetworkService?
//    
//    init() {
//        fetchTodosFromServer()
//    }
    
    //MARK: - Methods
//
//    func fetchTodosFromServer(completion: @escaping CompletionHandler = { _ in }) {
//        let requestURL = baseURL.appendingPathComponent("json")
//
//        URLSession.shared.dataTask(with: requestURL) { data, _, error in
//            if let error = error {
//                NSLog("Error fetching tasks: \(error)")
//                completion(.failure(.otherError))
//                return
//            }
//
//            guard let data = data else {
//                NSLog("No data returned from request")
//                completion(.failure(.noData))
//                return
//            }
//
//            do {
//                let todoRepresentations = Array(try JSONDecoder().decode([String : TodoRepresentation].self, from: data).values)
//                try self.updateTodos(with: todoRepresentations)
//            } catch {
//                NSLog("Error decoding todos: \(error)")
//            }
//        }.resume()
//    }
    
    func sendTodosToServer(todo: Todo, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = todo.identifier else {
            completion(.failure(.noIdentifier))
            return
        }

// MARK: For Kenny: proper use of your helper methods was unclear to me. We can discuss when convenient

        //networkService?.createRequest(url: requestURL, method: .put) ???
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathComponent("json")
        var request = URLRequest(url: requestURL)

        do {
            guard let representation = todo.todoRepresentation else {
                completion(.failure(.noEncode))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding todo \(todo): \(error)")
            completion(.failure(.noEncode))
            return
        }
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error sending task to server \(todo): \(error)")
                completion(.failure(.otherError))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
//    func updateTodos(with representations: [TodoRepresentation]) throws {
//
//        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier)}
//        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
//        var todosToCreate = representationsByID
//        let fetchRequest:NSFetchRequest<Todo> = Todo.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
//
//        let context = CoreDataStack.shared.container.newBackgroundContext()
//        var error: Error?
//
//            context.performAndWait {
//                do {
//                    let existingTodos = try context.fetch(fetchRequest)
//
//                    for todo in existingTodos {
//                        guard let id = todo.identifier,
//                            let representation = representationsByID[id] else { continue }
//                        self.updateTodoRep(todo: todo, with: representation)
//                        todosToCreate.removeValue(forKey: id)
//                    }
//                } catch let fetchError {
//                    error = fetchError
//                }
//                for representation in todosToCreate.values {
//                    Todo(todoRepresentation: representation, context: context)
//                }
//            }
//            if let error = error { throw error }
//            try CoreDataStack.shared.save(context: context)
//        }
    
    func deleteTodosFromServer(todo: Todo, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = todo.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error deleting entry from server \(todo): \(error)")
                completion(.failure(.otherError))
                return
            }
            completion(.success(true))
        }.resume()
    }

    private func updateTodoRep(todo: Todo, with representation: TodoRepresentation) {
        todo.title = representation.title
        todo.body = representation.body
        todo.recurring = representation.recurring.rawValue
        todo.complete = representation.complete
        todo.dueDate = representation.dueDate
    }
}
