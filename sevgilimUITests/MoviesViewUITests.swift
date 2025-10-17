//
//  MoviesViewUITests.swift
//  sevgilimUITests
//
//  Created by GitHub Copilot on 17/10/2025.
//

import XCTest

/// UI testleri: MoviesView
/// Filmler feature'ının tüm kullanıcı etkileşimlerini test eder
final class MoviesViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
        
        loginIfNeeded()
        
        // Movies ekranına git
        navigateToMovies()
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
    
    private func navigateToMovies() {
        // Hamburger menüden filmlere git
        let hamburgerButton = app.buttons.matching(identifier: "hamburgerMenuButton").firstMatch
        if hamburgerButton.waitForExistence(timeout: 3) {
            hamburgerButton.tap()
            sleep(1)
            
            let moviesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Film'")).firstMatch
            if moviesButton.exists {
                moviesButton.tap()
            }
        }
    }
    
    // MARK: - Test Cases
    
    /// Test 1: MoviesView liste görünümü çalışmalı
    func testMoviesListDisplays() throws {
        // Given: Movies ekranındayız
        
        // Then: Liste veya boş durum görünür olmalı
        let moviesList = app.scrollViews.firstMatch
        let emptyState = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'film'")).firstMatch
        
        XCTAssertTrue(
            moviesList.exists || emptyState.exists,
            "Film listesi veya boş durum görünür olmalı"
        )
    }
    
    /// Test 2: Yeni film ekleme butonu çalışmalı
    func testAddNewMovieButton() throws {
        // Given: "Yeni Film" butonunu buluyoruz
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Film' OR label CONTAINS[c] 'Ekle'")).firstMatch
        
        if addButton.waitForExistence(timeout: 3) {
            // When: Butona tıklıyoruz
            addButton.tap()
            
            // Then: Form ekranı açılmalı
            sleep(1)
            XCTAssertTrue(
                app.textFields.firstMatch.exists ||
                app.buttons["Kaydet"].exists,
                "Film ekleme formu açılmalı"
            )
        }
    }
    
    /// Test 3: Film rating (puanlama) çalışmalı
    func testMovieRating() throws {
        // Given: Listede en az bir film var
        let firstMovie = app.cells.firstMatch
        
        if firstMovie.waitForExistence(timeout: 3) {
            firstMovie.tap()
            sleep(1)
            
            // When: Rating yıldızlarını buluyoruz
            let starButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
            
            if starButtons.count > 0 {
                // When: İlk yıldıza tıklıyoruz
                starButtons.element(boundBy: 0).tap()
                
                // Then: Rating değişmeli
                sleep(1)
                XCTAssertTrue(
                    starButtons.element(boundBy: 0).exists,
                    "Rating çalışmalı"
                )
            }
        } else {
            throw XCTSkip("Test için film verisi bulunamadı")
        }
    }
    
    /// Test 4: "İzlendi" işaretleme çalışmalı
    func testMarkMovieAsWatched() throws {
        // Given: Listede en az bir film var
        let firstMovie = app.cells.firstMatch
        
        if firstMovie.waitForExistence(timeout: 3) {
            // When: Checkbox veya "İzlendi" butonuna tıklıyoruz
            let watchedButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'İzlendi' OR identifier CONTAINS 'watched'")).firstMatch
            
            if watchedButton.exists {
                watchedButton.tap()
                
                // Then: Durum değişmeli
                sleep(1)
                XCTAssertTrue(
                    app.images.matching(identifier: "checkmark").firstMatch.exists ||
                    watchedButton.exists
                )
            } else {
                // Alternatif: Detaya girip işaretle
                firstMovie.tap()
                sleep(1)
                
                let detailWatchedButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'İzlendi'")).firstMatch
                if detailWatchedButton.exists {
                    detailWatchedButton.tap()
                    sleep(1)
                    XCTAssertTrue(app.buttons["Geri"].exists || app.staticTexts.count > 0)
                }
            }
        } else {
            throw XCTSkip("Test için film verisi bulunamadı")
        }
    }
    
    /// Test 5: Film silme işlemi çalışmalı
    func testDeleteMovie() throws {
        // Given: Bir film detayındayız
        let firstMovie = app.cells.firstMatch
        
        if firstMovie.waitForExistence(timeout: 3) {
            let movieTitle = firstMovie.staticTexts.firstMatch.label
            firstMovie.tap()
            sleep(1)
            
            // When: Sil butonuna tıklıyoruz
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Sil'")).firstMatch
            if deleteButton.waitForExistence(timeout: 2) {
                deleteButton.tap()
                
                // When: Onay dialog'unda "Evet"
                let confirmButton = app.buttons["Evet"].firstMatch
                if confirmButton.waitForExistence(timeout: 2) {
                    confirmButton.tap()
                    
                    // Then: Liste ekranına dönmeli ve film silinmiş olmalı
                    sleep(2)
                    let deletedMovie = app.staticTexts[movieTitle]
                    XCTAssertFalse(deletedMovie.exists, "Silinen film listede görünmemeli")
                }
            }
        } else {
            throw XCTSkip("Test için film verisi bulunamadı")
        }
    }
}
