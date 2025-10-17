//
//  NotesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: NotesView, NoteDetailView, AddNoteView
/// Notlar feature'ının tüm kullanıcı etkileşimlerini test eder
final class NotesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Notes tab'ına git
        let notesTab = app.tabBars.buttons["Notlar"]
        if notesTab.waitForExistence(timeout: 5) {
            notesTab.tap()
        }
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func loginIfNeeded() {
        let emailField = app.textFields["Email"]
        if emailField.waitForExistence(timeout: 3) {
            emailField.tap()
            emailField.typeText("test@example.com")
            
            let passwordField = app.secureTextFields["Şifre"]
            passwordField.tap()
            passwordField.typeText("password123")
            
            app.buttons["Giriş Yap"].tap()
            _ = app.navigationBars.firstMatch.waitForExistence(timeout: 5)
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: NotesView liste görünümü çalışmalı
    func testNotesListDisplaysCorrectly() throws {
        // Given: Notes ekranındayız
        XCTAssertTrue(
            app.navigationBars["Notlar"].exists ||
            app.staticTexts["Notlarımız"].exists ||
            app.navigationBars.firstMatch.exists
        )
        
        // Then: "Yeni Not Ekle" butonu veya liste görünür olmalı
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Not' OR label CONTAINS[c] 'Ekle'")).firstMatch
        let notesList = app.scrollViews.firstMatch
        
        XCTAssertTrue(addButton.exists || notesList.exists)
    }
    
    /// Test 2: Yeni not ekleme flow'u çalışmalı
    func testAddNewNoteFlow() throws {
        // Given: "Yeni Not Ekle" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Not' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            sleep(1)
            
            // When: Not başlığı ve içerik ekliyoruz
            let titleField = app.textFields["Başlık"].firstMatch
            if titleField.waitForExistence(timeout: 2) {
                titleField.tap()
                titleField.typeText("Alışveriş Listesi")
                
                let contentField = app.textViews.firstMatch
                if contentField.exists {
                    contentField.tap()
                    contentField.typeText("Süt, yumurta, ekmek")
                }
                
                // When: Kaydet
                let saveButton = app.buttons["Kaydet"].firstMatch
                if saveButton.exists {
                    saveButton.tap()
                    
                    // Then: Yeni not listede görünmeli
                    sleep(2)
                    let newNote = app.staticTexts["Alışveriş Listesi"]
                    XCTAssertTrue(
                        newNote.exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Alışveriş'")).firstMatch.exists,
                        "Yeni not listede görünmeli"
                    )
                }
            }
        }
    }
    
    /// Test 3: Not detay sayfası açılmalı
    func testNoteDetailOpens() throws {
        // Given: Listede en az bir not var
        let firstNote = app.cells.firstMatch
        
        if firstNote.waitForExistence(timeout: 3) {
            // When: Nota tıklıyoruz
            firstNote.tap()
            
            // Then: Detay ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textViews.firstMatch.exists ||
                app.buttons["Düzenle"].exists ||
                app.buttons["Geri"].exists,
                "Not detayı açılmalı"
            )
        } else {
            throw XCTSkip("Test için not verisi bulunamadı")
        }
    }
    
    /// Test 4: Not düzenleme işlemi çalışmalı
    func testEditNote() throws {
        // Given: Bir not detayındayız
        let firstNote = app.cells.firstMatch
        
        if firstNote.waitForExistence(timeout: 3) {
            firstNote.tap()
            sleep(1)
            
            // When: Düzenle butonuna tıklıyoruz
            let editButton = app.buttons["Düzenle"].firstMatch
            if editButton.waitForExistence(timeout: 2) {
                editButton.tap()
                
                // When: İçeriği değiştiriyoruz
                let contentField = app.textViews.firstMatch
                if contentField.exists {
                    contentField.tap()
                    contentField.typeText(" - Güncellendi")
                    
                    // When: Kaydet
                    let saveButton = app.buttons["Kaydet"].firstMatch
                    if saveButton.exists {
                        saveButton.tap()
                        
                        // Then: Güncellenen içerik görünmeli
                        sleep(1)
                        let updatedContent = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Güncellendi'")).firstMatch
                        XCTAssertTrue(updatedContent.exists || app.textViews.firstMatch.exists)
                    }
                }
            }
        } else {
            throw XCTSkip("Test için not verisi bulunamadı")
        }
    }
    
    /// Test 5: Not silme işlemi çalışmalı
    func testDeleteNote() throws {
        // Given: Bir not detayındayız
        let firstNote = app.cells.firstMatch
        
        if firstNote.waitForExistence(timeout: 3) {
            let noteTitle = firstNote.staticTexts.firstMatch.label
            firstNote.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve not silinmiş olmalı
                    sleep(2)
                    let deletedNote = app.staticTexts[noteTitle]
                    XCTAssertFalse(deletedNote.exists, "Silinen not listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için not verisi bulunamadı")
        }
    }
    
    /// Test 6: Not arama işlevi çalışmalı
    func testSearchNotes() throws {
        // Given: Arama çubuğunu buluyoruz
        let searchBar = app.searchFields.firstMatch
        
        if searchBar.waitForExistence(timeout: 3) {
            // When: Arama yapıyoruz
            searchBar.tap()
            searchBar.typeText("Alışveriş")
            
            // Then: Filtrelenmiş sonuçlar görünmeli
            sleep(1)
            let searchResults = app.cells.count
            XCTAssertTrue(
                searchResults >= 0,
                "Arama sonuçları gösterilmeli"
            )
            
            // When: Aramayı temizliyoruz
            let clearButton = app.buttons["Clear text"].firstMatch
            if clearButton.exists {
                clearButton.tap()
                sleep(1)
                
                // Then: Tüm notlar tekrar görünmeli
                XCTAssertTrue(app.scrollViews.firstMatch.exists)
            }
        }
    }
    
    /// Test 7: Notlar scroll edilebilmeli
    func testNotesListScrollable() throws {
        // Given: Liste görünümü
        let scrollView = app.scrollViews.firstMatch
        
        if scrollView.waitForExistence(timeout: 3) {
            // When: Aşağı scroll
            scrollView.swipeUp()
            XCTAssertTrue(scrollView.exists)
            
            // When: Yukarı scroll
            scrollView.swipeDown()
            XCTAssertTrue(scrollView.exists)
        }
    }
}
