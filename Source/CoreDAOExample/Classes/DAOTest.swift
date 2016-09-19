//
//  DAOTest.swift
//  CoreDAO
//
//  Created by Igor Bulyga on 05.02.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import UIKit
import CoreDAO



@UIApplicationMain
class DAOTest: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print("\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first)")
        self.setupRealmdataBase()

        self.testRealmEntitiesDAO()
        self.testRealmMessageDAO()
        self.testRealmFoldersDAO()
        
//        testCoreDataEntitiesDAO()
        
        return true
    }
    
    func setupRealmdataBase() {
        RealmDAO.assignDatabaseVersion(1)
        RealmDAO.assignDatabaseFilename("DAOTest.realm")
    }
    
    func testRealmEntitiesDAO() {
        self.testRealmEntity_Hashable_Protocol()
        self.testRealmPersist_EntityWithId_returnYES()
        self.testRealmReadById_entityExist_returnExactlyEntity()
        self.testRealmEraseById_entityExists_entityErased()
    }
    
    func testRealmMessageDAO() {
        self.testRealmPersist_messageWithAllFields_returnsYES()
        self.testRealmReadById_messageExists_returnsExactMessage()
        self.testRealmEraseById_messageExists_messageErased()
    }
    
    func testRealmFoldersDAO() {
        self.testRealmPersist_folderWithAllFields_returnsYES()
        self.testRealmReadById_folderExists_returnsExactFolder()
        self.testRealmReadById_folderWithMessages_returnsExactFolder()
        self.testRealmEraseById_folderExists_folderErased()
        self.testRealmEraseByIdCascade_folderExists_folderErasedWithMessages()
    }
    
    /*func testCoreDataEntitiesDAO() {
        testCoreDataPersist_entityWithId_returnsYES()
        testCoreDataPersistAll_entityWithId_returnsYES()
        testCoreDataPersistInBackground_entityWithId_returnsYES()
        testCoreDataReadById_entityExists_returnsExactEntity()
        testCoreDataReadById_entitySavedInBackground_returnsExactEntity()
        testCoreDataEraseById_entityExists_entityErased()
    }*/
    
    
    func testRealmEntity_Hashable_Protocol()
    {
        let entityA = Entity(entityId: "1")
        let entityB = Entity(entityId: "1")
        let entityC = Entity(entityId: "2")
        
        print("\(#function) equals result: \(entityA != entityC && entityB != entityC && entityA == entityB)")
        
        let entitySet: Set = [entityA, entityB, entityC]
        print("\(#function) hashable result: \(entitySet.count == 2)")
    }
    
    func testRealmPersist_EntityWithId_returnYES() {
        let dao = self.entityRealmDAO()
        let entity: Entity = Entity(entityId: "1")
        do {
            try dao.persist(entity)
        } catch {
         print("[ERROR] in \(#function)")
        }
        print("\(#function) result:\(entity == dao.read(entity.entityId))")
    }
    
    func testRealmReadById_entityExist_returnExactlyEntity() {
        let dao = self.entityRealmDAO()
        let entity = Entity(entityId: "2")
        do {
            try dao.persist(entity)
        } catch {
            print("[ERROR] in \(#function)")
        }
        let savedEntity: Entity? = dao.read("2")
        print("\(#function) result:\(entity == savedEntity)")
    }
    
    func testRealmEraseById_entityExists_entityErased() {
        let dao = self.entityRealmDAO()
        let entity = Entity(entityId: "3")
        do {
            try dao.persist(entity)
            try dao.erase("3")
        } catch {
            print("[ERROR] in \(#function)")
        }
        
        let erasedEntity: Entity? = dao.read("3")
        print("\(#function) result:\(erasedEntity == nil)")
    }
    
    func testRealmPersist_messageWithAllFields_returnsYES() {
        let dao = self.messageDAO()
        let message = Message(entityId: "abc", text: "text")
        do {
            try dao.persist(message)
        } catch {
            print("[ERROR] in \(#function)")
        }
        print("\(#function) result:\(message == dao.read(message.entityId))")
    }
    
    func testRealmReadById_messageExists_returnsExactMessage() {
        let dao = self.messageDAO()
        let message = Message(entityId: "def", text: "text 2")
        do {
             try dao.persist(message)
        } catch {
            print("[ERROR] in \(#function)")
        }
        let savedMessage =  dao.read("def")
        print("\(#function) result:\(message == savedMessage)")
    }

    func testRealmEraseById_messageExists_messageErased() {
        let dao = self.entityRealmDAO()
        let message = Entity(entityId: "ghi")
        do {
            try dao.persist(message)
            try dao.erase("ghi")
            
        } catch {
            print("[ERROR] in \(#function)")
        }
        let erasedMessage = dao.read("ghi")
        print("\(#function) result:\(erasedMessage == nil)")
    }
    
    fileprivate func testRealmPersist_folderWithAllFields_returnsYES() {
        let dao = self.folderDAO()
        let folder = Folder.folderWithId("I", name: "INBOX", messages: [])
        do {
            try dao.persist(folder)
        } catch {
            print("[ERROR] in \(#function)")
        }
        print("\(#function) result: \(dao.read(folder.entityId) == folder)")
    }
    
    fileprivate func testRealmReadById_folderExists_returnsExactFolder() {
        let dao = self.folderDAO()
        let folderID = "II"
        let folder = Folder.folderWithId(folderID, name: "OUTBOX", messages: [])
        do {
            try dao.persist(folder)
        } catch {
            print("[ERROR] in \(#function)")
        }
        let savedFolder = dao.read(folderID)
        print("\(#function) result:\(folder == savedFolder)")
    }
    
    fileprivate func testRealmReadById_folderWithMessages_returnsExactFolder() {
        let dao = self.folderDAO()
        let folderID = "IV"
        let message1 = Message(entityId: "IV.1", text: "text IV.1")
        let message2 = Message(entityId: "IV.2", text: "text IV.2")
        
        let folder = Folder.folderWithId(folderID, name: "SPAM", messages: [message1, message2])
        do {
            try dao.persist(folder)
        } catch {
            print("[ERROR] in \(#function)")
        }
        let savedFolder = dao.read(folderID)
        
        print("\(#function) result:\(folder == savedFolder)")
    }
    
    fileprivate func testRealmEraseById_folderExists_folderErased() {
        let dao = self.folderDAO()
        let folderID = "III"
        
        let folder = Folder.folderWithId(folderID, name: "SENT", messages: [])
        do {
            try dao.persist(folder)
            try dao.erase(folderID)
            print("\(#function) result:\(dao.read(folderID) == nil)")
        } catch {
            print("[ERROR] in \(#function)")
        }
    }
    
    fileprivate func testRealmEraseByIdCascade_folderExists_folderErasedWithMessages() {
        let dao = self.folderDAO()
        
        let messageID = "V.message"
        let  message = Message.init(entityId: messageID, text: "V.message.text")
        
        let folderID = "V"
        let folder = Folder.folderWithId(folderID, name: "Delete", messages: [message])
        do {
            try dao.persist(folder)
        } catch {
            print("[ERROR] in \(#function)")
        }
        
        let  messageDAO = self.messageDAO()
        let savedMessage = messageDAO.read(messageID)
        if (savedMessage == nil) { fatalError() }
        
        do {
            try dao.erase(folderID)
            print("\(#function) result:\(messageDAO.read(messageID) == nil)")
        } catch {
            print("[ERROR] in \(#function)")
        }
    }
    
    // MARK: CoreData
    
    /*func testCoreDataPersist_entityWithId_returnsYES() {
        let dao = entityCoreDataDAO()
        let entity = Entity(entityId: "1")
        do {
            try dao.persist(entity)
            print("\(#function): true")
        } catch {
            print("[ERROR] in \(#function)")
        }
    }
    
    func testCoreDataPersistAll_entityWithId_returnsYES() {
        let dao = entityCoreDataDAO()
        let firstEntity = Entity(entityId: "1")
        let secondEntity = Entity(entityId: "2")
        do {
            try dao.persistAll([firstEntity, secondEntity])
            print("\(#function): true")
        } catch {
            print("[ERROR] in \(#function)")

        }
        
    }
    
    func testCoreDataPersistInBackground_entityWithId_returnsYES() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            let dao = self.entityCoreDataDAO()
            let entity = Entity(entityId: "1_back")
            do {
                try dao.persist(entity)
                print("\(#function): true")
            } catch {
                print("[ERROR] in \(#function)")

            }
        }
    }
    
    func testCoreDataReadById_entityExists_returnsExactEntity() {
        let dao = entityCoreDataDAO()
        let entityId = "2"
        let entity = Entity(entityId: entityId)
        
        var result = false
        do {
            try dao.persist(entity)
            if let savedEntity = dao.read(entityId) {
                result = savedEntity.entityId == entity.entityId
            }
            print("\(#function): \(result)")
        } catch {
            print("[ERROR] whe persis in \(#function)")
        }
    }
    
    func testCoreDataReadById_entitySavedInBackground_returnsExactEntity() {
        let dao = entityCoreDataDAO()
        let entityId = "2_back"
        let entity = Entity(entityId: entityId)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { () -> Void in
            do {
                try dao.persist(entity)
            } catch {
                print("[ERROR] When Persis entity in \(#function)")
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                var result = false
                if let savedEntity = dao.read(entityId) {
                    result = savedEntity.entityId == entity.entityId
                }
                print("\(#function): \(result)")
            })
        }
    }
    
    func testCoreDataEraseById_entityExists_entityErased() {
        let dao = entityCoreDataDAO()
        let entityId = "3"
        let entity = Entity(entityId: entityId)
        do {
            try dao.persist(entity)
            try dao.erase(entityId)
        } catch {
            print("[ERROR] Error whe try in \(#function)")
        }
        
        print("\(#function): \(dao.read(entityId) == nil)")
    }
    */
    // MARK: Инициализация DAO объектов
    
    fileprivate func entityRealmDAO() -> RealmDAO<Entity, DBEntity> {
        return RealmDAO(translator: RLMEntityTranslator())
    }
 
    fileprivate func messageDAO() -> RealmDAO<Message, DBMessage> {
        let a = RealmDAO(translator: RLMMessageTranslator())
        return a
    }
    
    fileprivate func folderDAO() -> RealmDAO<Folder, DBFolder> {
        return RealmDAO(translator: RLMFolderTranslator())
    }
    /*
    fileprivate func entityCoreDataDAO() -> CoreDataDAO<CDEntity, Entity> {
        return CoreDataDAO(translator: CDEntityTranslator.translator())
    }*/
}
