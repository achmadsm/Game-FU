//
//  GameProvider.swift
//  Game
//
//  Created by + on 2/21/1446 AH.
//

import CoreData

class GameProvider {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameFavorite")

        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil

        return container
    }()

    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.undoManager = nil

        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    func getAllGame(completion: @escaping (_ favorites: [FavoriteModel]) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorite")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var favorites: [FavoriteModel] = []
                for result in results {
                    let favorite = FavoriteModel(
                        id: result.value(forKeyPath: "id") as? Int16,
                        name: result.value(forKeyPath: "name") as? String,
                        released: result.value(forKeyPath: "released") as? String,
                        backgroundImage: result.value(forKeyPath: "backgroundImage") as? URL,
                        rating: result.value(forKeyPath: "rating") as? Double,
                        genres: result.value(forKeyPath: "genres") as? String,
                        descriptionRaw: result.value(forKeyPath: "descriptionRaw") as? String
                    )

                    favorites.append(favorite)
                }
                completion(favorites)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func isGameFavorite(_ id: Int, completion: @escaping (_ isFavorite: Bool) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorite")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            do {
                if let _ = try taskContext.fetch(fetchRequest).first {
                    completion(true)
                } else {
                    completion(false)
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }

    func createFavorite(
        _ id: Int,
        _ name: String,
        _ released: String,
        _ backgroundImage: URL,
        _ rating: Double,
        _ genres: String,
        _ descriptionRaw: String,
        completion: @escaping () -> Void
    ) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: taskContext) {
                let favorite = NSManagedObject(entity: entity, insertInto: taskContext)
                favorite.setValue(id, forKeyPath: "id")
                favorite.setValue(name, forKeyPath: "name")
                favorite.setValue(released, forKeyPath: "released")
                favorite.setValue(backgroundImage, forKeyPath: "backgroundImage")
                favorite.setValue(rating, forKeyPath: "rating")
                favorite.setValue(genres, forKeyPath: "genres")
                favorite.setValue(descriptionRaw, forKeyPath: "descriptionRaw")

                do {
                    try taskContext.save()
                    completion()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }

    func deleteFavorite(_ id: Int, completion: @escaping () -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
                if batchDeleteResult.result != nil {
                    completion()
                }
            }
        }
    }
}
