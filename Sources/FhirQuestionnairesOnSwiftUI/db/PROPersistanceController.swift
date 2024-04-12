import Foundation
import CoreData
import CryptoKit
import KeychainAccess

internal struct PROPersistenceController
{
    static let shared = PROPersistenceController()
    
    let container: NSPersistentContainer

    private init()
    {
        guard let url = Bundle.module.url(forResource: "PROModel", withExtension: "momd") else
        {
            fatalError("Could not get URL for model: PROModel")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else
        {
            fatalError("Could not get MOM for model: PROModel")
        }
        
        container = NSPersistentContainer(name: "FhirQuestionnairesOnSwiftUI.PROModel", managedObjectModel: model)
        container.loadPersistentStores
        { description, error in
            if let error = error 
            {
                fatalError("Error loading persistent stores: \(error.localizedDescription)")
            }
        }
    }
    
    private func save()
    {
        let context = container.viewContext
       
        if (context.hasChanges)
        {
            try? context.save()
        }
    }
    
    internal func save(result: PROResultModelWrapper)
    {
        if let owner = result.owner, let task = result.task
        {
            let toSave = doLoad(owner: owner, task: task) ?? PROResultModel(context: container.viewContext)

            toSave.owner = result.owner
            toSave.task = result.task
            toSave.results = result.results?.encrypt(using: encryptionKey())
            toSave.completed = result.completed
            
            save()
        }
    }
    
    internal func load(for owner: String, and task: String) -> PROResultModelWrapper?
    {
        if let loaded = doLoad(owner: owner, task: task)
        {
            let decryptedResults = loaded.results?.decrypt(using: encryptionKey())
            return PROResultModelWrapper(owner: loaded.owner, task: loaded.task, results: decryptedResults, completed: loaded.completed)
        }
        
        return nil
    }
    
    private func doLoad(owner: String, task: String) -> PROResultModel?
    {
        let fetchRequest = PROResultModel.fetchRequest()
        fetchRequest.fetchLimit = 1

        let ownerPredicate = NSPredicate(format: "owner == %@", owner)
        let taskPredicate = NSPredicate(format: "task == %@", task)

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [ownerPredicate, taskPredicate])
        let loaded = try? container.viewContext.fetch(fetchRequest).first
        
        return loaded
    }
    
    internal func delete(for owner: String, and task: String)
    {
        if let task = doLoad(owner: owner, task: task)
        {
            container.viewContext.delete(task)
            save()
        }
    }
    
    private static let KEYCHAIN_ENCRYPTION_KEY_IDENTIFIER = "encryption-key"
    
    private func encryptionKey() -> SymmetricKey
    {
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        let keyString = keychain[string: PROPersistenceController.KEYCHAIN_ENCRYPTION_KEY_IDENTIFIER] ?? initializeKey(keychain: keychain)
        return SymmetricKey(data: SHA256.hash(data: keyString.data(using: .utf8)!))
    }
    
    private func initializeKey(keychain: Keychain) -> String
    {
        let keyString = UUID().uuidString
        keychain[string: PROPersistenceController.KEYCHAIN_ENCRYPTION_KEY_IDENTIFIER] = keyString
        return keyString
    }
}
