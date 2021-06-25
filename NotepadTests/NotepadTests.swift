//
//  NotepadTests.swift
//  NotepadTests
//
//  Created by ahmed talaat on 25/06/2021.
//

import XCTest
@testable import Notepad

class NotepadTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        testSaveAndGetNote()
        testDeleteNote()
        testUpdateNote()
    }

    
    func testSaveAndGetNote(){
        let allNotesBefore = realmDB.shared.read()

        let _ = realmDB.shared.write(title: "note title", description: "note description", lat: 10, lng: 10, image: nil, id: Date(), address: "address")
        
        let allNotesAfter = realmDB.shared.read()
        XCTAssertEqual(allNotesAfter.count, allNotesBefore.count + 1)
    }
    
    func testDeleteNote(){
        let _ = realmDB.shared.write(title: "note title", description: "note description", lat: 10, lng: 10, image: nil, id: Date(), address: "address")

        let allNotesBefore = realmDB.shared.read()
        XCTAssertGreaterThan(allNotesBefore.count, 0)

        for note in allNotesBefore {
            let _ = realmDB.shared.delete(id: note.id!)
            break
        }
        
        let allNotesAfter = realmDB.shared.read()
        XCTAssertEqual(allNotesAfter.count, allNotesBefore.count - 1)
    }
    
    func testUpdateNote(){
        realmDB.shared.deleteAll()
        let allNotesAfterDelete = realmDB.shared.read()
        XCTAssertEqual(allNotesAfterDelete.count, 0)

        let _ = realmDB.shared.write(title: "note title", description: "note description", lat: 10, lng: 10, image: nil, id: Date(), address: "address")

        let allNotesAfterAdd = realmDB.shared.read()
        XCTAssertGreaterThan(allNotesAfterAdd.count, 0)
        
        let _ = realmDB.shared.update(newTitle: "note title updated", newDescription: allNotesAfterAdd[0].noteDescription, newLat: allNotesAfterAdd[0].lat, newLng: allNotesAfterAdd[0].lng, newImage: allNotesAfterAdd[0].image, newId: Date(), id: allNotesAfterAdd[0].id!, address: allNotesAfterAdd[0].address!)
        
        
        let allNotesAfterUpdate = realmDB.shared.read()
        XCTAssertGreaterThan(allNotesAfterUpdate.count, 0)
        
        XCTAssertEqual(allNotesAfterUpdate[0].title, "note title updated")
    }
    
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
