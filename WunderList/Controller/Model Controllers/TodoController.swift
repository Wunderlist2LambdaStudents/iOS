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
private let baseURL = URL(string: "https://bw-wunderlist2.firebaseio.com/")!

class TodoController {

    // MARK: - Properties -
    private let networkService = NetworkService()
    //As soon as class is initialized, get Todos
    init() {
        if AuthService.activeUser != nil {
            fetchTodosFromServer()
        }
    }

    // MARK: - Get -
    func fetchTodosFromServer(completion: @escaping CompletionHandler = { _ in }) {
        //#error("Need to provide authentication information (token)")
        let requestURL = baseURL.appendingPathComponent(AuthService.activeUser?.identifier?.uuidString ?? "")
        guard var request = networkService.createRequest(url: requestURL, method: .get) else {
            print("bad request")
            completion(.failure(.otherError))
            return
        }
        request.addValue(AuthService.activeUser?.token ?? "", forHTTPHeaderField: "Authorization")
        networkService.dataLoader.loadData(using: request) { data, _, error in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }

            guard let data = data else {
                NSLog("No data returned from request")
                completion(.failure(.noData))
                return
            }

            //decode representations
            let reps = self.networkService.decode(to: [TodoRepresentation].self, data: data)
            guard let unwrappedReps = reps else {
                print("Error decoding Todos")
                completion(.failure(.noDecode))
                return
            }
            //update Todos
            do {
                try self.updateTodos(with: unwrappedReps)
            } catch {
                completion(.failure(.otherError))
                NSLog("Error updating todos: \(error)")
            }

        }
    }

    func sendTodosToServer(todo: TodoRepresentation, completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathComponent(
            AuthService.activeUser?.identifier?.uuidString ?? "c4e718c2-9fce-11ea-bb37-0242ac130002"
        ).appendingPathExtension("json")
        guard var request = networkService.createRequest(url: requestURL, method: .put) else { return }
        let identity = todo.identifier.uuidString ?? "c4e718c2-9fce-11ea-bb37-0242ac130002"
        networkService.encode(from: [identity: todo], request: &request)
        networkService.dataLoader.loadData(using: request) { _, response, error in
            if let error = error {
                NSLog("Error sending task to server \(todo): \(error)")
                completion(.failure(.otherError))
                return
            }
            print(response?.statusCode)
            completion(.success(true))
        }
    }

    func updateTodos(with representations: [TodoRepresentation]) throws {

        let identifiersToFetch = representations.compactMap {$0.identifier}
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var todosToCreate = representationsByID
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)

        let context = CoreDataStack.shared.container.newBackgroundContext()
        var error: Error?
        guard let activeUser = AuthService.activeUser else { return }
            context.performAndWait {
                do {
                    let existingTodos = try context.fetch(fetchRequest)

                    for todo in existingTodos {                        
                        guard let identifier = todo.identifier,
                            let representation = representationsByID[identifier] else { continue }
                        self.updateTodoRep(todo: todo, with: representation)
                        todosToCreate.removeValue(forKey: identifier)
                    }
                } catch let fetchError {
                    error = fetchError
                }

                for representation in todosToCreate.values {
                    guard let userRep = AuthService.activeUser else { return }
                    Todo(todoRepresentation: representation, context: context, userRep: userRep )
                }
            }
            if let error = error { throw error }
            try CoreDataStack.shared.save(context: context)
        }

    func deleteTodosFromServer(todo: Todo, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = todo.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        guard let request = networkService.createRequest(url: requestURL, method: .delete) else { return }
        networkService.dataLoader.loadData(using: request) { _, _, error in
            if let error = error {
                NSLog("Error deleting entry from server \(todo): \(error)")
                completion(.failure(.otherError))
                return
            }
            completion(.success(true))
        }
    }

    private func updateTodoRep(todo: Todo, with representation: TodoRepresentation) {
        todo.title = representation.title
        todo.body = representation.body
        todo.recurring = representation.recurring.rawValue
        todo.complete = representation.complete
        todo.dueDate = representation.dueDate
    }

    func loadMockUser() -> UserRepresentation? {
        let data = Data.mockData(with: .goodUserData)
        let response = HTTPURLResponse(
            url: URL(string: "https://www.google.com")!,
            statusCode: 200, httpVersion: nil,
            headerFields: nil
        )
        let mockDataLoader = MockDataLoader(data: data, response: response, error: nil)
        let networkService = NetworkService(dataLoader: mockDataLoader)
        guard let user = networkService.decode(to: UserRepresentation.self, data: data) else {
            print("Couldn't Mock user, check for decode errors")
            return nil
        }
        return user
    }

    func loadMockTodos(from mockUser: inout UserRepresentation) {
        let networkService = NetworkService()
        guard let todos = networkService.decode(
            to: [TodoRepresentation].self,
            data: Data.mockData(with: .goodTodoData),
            dateFormatter: NetworkService.dateFormatter
        ) else {
            print("error decoding todos while adding todos to mockUser, check for decode errors.")
            return
        }
        mockUser.todos = todos
    }
}
