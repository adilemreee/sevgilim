//
//  Tests2.swift
//  Tests2
//
//  Created by adil emre  on 17.10.2025.
//

import Testing

//
//  AuthenticationAndRelationshipTests.swift
//  sevgilim
//
//  Test dosyası - Giriş, Kayıt ve İlişki Kodu İşlemleri
//

import XCTest
import FirebaseAuth
import FirebaseFirestore
@testable import sevgilim

@MainActor
class AuthenticationAndRelationshipTests: XCTestCase {
    
    var authService: AuthenticationService!
    var relationshipService: RelationshipService!
    let db = Firestore.firestore()
    
    // Test kullanıcı bilgileri
    let testUser1Email = "test_user1_\(UUID().uuidString)@test.com"
    let testUser1Password = "Test123456!"
    let testUser1Name = "Test User 1"
    
    let testUser2Email = "test_user2_\(UUID().uuidString)@test.com"
    let testUser2Password = "Test123456!"
    let testUser2Name = "Test User 2"
    
    var testUser1Id: String?
    var testUser2Id: String?
    var testRelationshipId: String?
    
    override func setUp() async throws {
        try await super.setUp()
        authService = AuthenticationService()
        relationshipService = RelationshipService()
        
        print("\n" + "="*60)
        print("🧪 Test Başlatılıyor")
        print("="*60)
    }
    
    override func tearDown() async throws {
        // Test sonrası temizlik
        await cleanupTestData()
        try await super.tearDown()
        
        print("\n" + "="*60)
        print("🧹 Test Tamamlandı ve Temizlendi")
        print("="*60 + "\n")
    }
    
    // MARK: - Test 1: Kullanıcı Kayıt İşlemi
    
    func testUserRegistration() async throws {
        print("\n📝 Test 1: Kullanıcı Kayıt İşlemi")
        print("-" * 60)
        
        do {
            print("✅ Kullanıcı 1 kaydediliyor...")
            print("   Email: \(testUser1Email)")
            print("   İsim: \(testUser1Name)")
            
            try await authService.signUp(
                email: testUser1Email,
                password: testUser1Password,
                name: testUser1Name
            )
            
            XCTAssertNotNil(authService.currentUser, "❌ Kullanıcı kaydedilmedi!")
            XCTAssertEqual(authService.currentUser?.email, testUser1Email, "❌ Email eşleşmiyor!")
            XCTAssertEqual(authService.currentUser?.name, testUser1Name, "❌ İsim eşleşmiyor!")
            XCTAssertTrue(authService.isAuthenticated, "❌ Kullanıcı doğrulanmadı!")
            
            testUser1Id = authService.currentUser?.id
            
            print("✅ Kullanıcı başarıyla kaydedildi!")
            print("   User ID: \(testUser1Id ?? "N/A")")
            print("   Email: \(authService.currentUser?.email ?? "N/A")")
            print("   İsim: \(authService.currentUser?.name ?? "N/A")")
            
        } catch {
            XCTFail("❌ Kayıt hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Test 2: Kullanıcı Giriş İşlemi
    
    func testUserLogin() async throws {
        print("\n🔐 Test 2: Kullanıcı Giriş İşlemi")
        print("-" * 60)
        
        // Önce kullanıcıyı kaydet
        try await authService.signUp(
            email: testUser1Email,
            password: testUser1Password,
            name: testUser1Name
        )
        
        testUser1Id = authService.currentUser?.id
        
        print("✅ Test kullanıcısı oluşturuldu")
        
        // Çıkış yap
        authService.signOut()
        XCTAssertFalse(authService.isAuthenticated, "❌ Çıkış yapılamadı!")
        print("✅ Çıkış yapıldı")
        
        // Tekrar giriş yap
        do {
            print("🔑 Giriş yapılıyor...")
            print("   Email: \(testUser1Email)")
            
            try await authService.signIn(
                email: testUser1Email,
                password: testUser1Password
            )
            
            // Biraz bekle (Firebase'den veri gelsin diye)
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            XCTAssertNotNil(authService.currentUser, "❌ Giriş başarısız!")
            XCTAssertTrue(authService.isAuthenticated, "❌ Kullanıcı doğrulanmadı!")
            XCTAssertEqual(authService.currentUser?.email, testUser1Email, "❌ Email eşleşmiyor!")
            
            print("✅ Giriş başarılı!")
            print("   User ID: \(authService.currentUser?.id ?? "N/A")")
            print("   Email: \(authService.currentUser?.email ?? "N/A")")
            print("   İsim: \(authService.currentUser?.name ?? "N/A")")
            
        } catch {
            XCTFail("❌ Giriş hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Test 3: İlişki Daveti Gönderme
    
    func testSendInvitation() async throws {
        print("\n💌 Test 3: İlişki Daveti Gönderme")
        print("-" * 60)
        
        // Kullanıcı 1'i kaydet
        try await authService.signUp(
            email: testUser1Email,
            password: testUser1Password,
            name: testUser1Name
        )
        
        testUser1Id = authService.currentUser?.id
        
        guard let senderId = testUser1Id else {
            XCTFail("❌ Gönderen kullanıcı ID'si bulunamadı!")
            return
        }
        
        print("✅ Gönderen kullanıcı hazır")
        print("   ID: \(senderId)")
        print("   İsim: \(testUser1Name)")
        
        let startDate = Date()
        
        do {
            print("\n📤 Davet gönderiliyor...")
            print("   Gönderen: \(testUser1Email)")
            print("   Alıcı: \(testUser2Email)")
            
            try await relationshipService.sendInvitation(
                senderUserId: senderId,
                senderName: testUser1Name,
                senderEmail: testUser1Email,
                receiverEmail: testUser2Email,
                startDate: startDate
            )
            
            print("✅ Davet başarıyla gönderildi!")
            
            // Davetin veritabanında olduğunu kontrol et
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let invitations = try await db.collection("invitations")
                .whereField("receiverEmail", isEqualTo: testUser2Email)
                .whereField("status", isEqualTo: "pending")
                .getDocuments()
            
            XCTAssertFalse(invitations.documents.isEmpty, "❌ Davet veritabanında bulunamadı!")
            print("✅ Davet veritabanında doğrulandı")
            print("   Toplam bekleyen davet: \(invitations.documents.count)")
            
        } catch {
            XCTFail("❌ Davet gönderme hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Test 4: Tam İlişki Kurulumu (End-to-End)
    
    func testCompleteRelationshipFlow() async throws {
        print("\n💑 Test 4: Tam İlişki Kurulumu (End-to-End)")
        print("-" * 60)
        
        // Adım 1: İki kullanıcı kaydet
        print("\n👤 Adım 1: İlk kullanıcıyı kaydet")
        try await authService.signUp(
            email: testUser1Email,
            password: testUser1Password,
            name: testUser1Name
        )
        testUser1Id = authService.currentUser?.id
        print("✅ Kullanıcı 1 kaydedildi - ID: \(testUser1Id ?? "N/A")")
        
        // Çıkış yap
        authService.signOut()
        
        print("\n👤 Adım 2: İkinci kullanıcıyı kaydet")
        try await authService.signUp(
            email: testUser2Email,
            password: testUser2Password,
            name: testUser2Name
        )
        testUser2Id = authService.currentUser?.id
        print("✅ Kullanıcı 2 kaydedildi - ID: \(testUser2Id ?? "N/A")")
        
        guard let user1Id = testUser1Id, let user2Id = testUser2Id else {
            XCTFail("❌ Kullanıcı ID'leri alınamadı!")
            return
        }
        
        // Adım 2: Kullanıcı 1 olarak giriş yap ve davet gönder
        authService.signOut()
        print("\n💌 Adım 3: Kullanıcı 1 olarak giriş yap ve davet gönder")
        try await authService.signIn(email: testUser1Email, password: testUser1Password)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        
        try await relationshipService.sendInvitation(
            senderUserId: user1Id,
            senderName: testUser1Name,
            senderEmail: testUser1Email,
            receiverEmail: testUser2Email,
            startDate: startDate
        )
        print("✅ Davet gönderildi")
        
        // Adım 3: Kullanıcı 2 olarak giriş yap ve daveti dinle
        authService.signOut()
        print("\n📨 Adım 4: Kullanıcı 2 olarak giriş yap ve daveti kontrol et")
        try await authService.signIn(email: testUser2Email, password: testUser2Password)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        relationshipService.listenForInvitations(userEmail: testUser2Email)
        
        // Davet gelmesini bekle
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertFalse(relationshipService.pendingInvitations.isEmpty, "❌ Davet alınamadı!")
        print("✅ Davet alındı - Toplam: \(relationshipService.pendingInvitations.count)")
        
        guard let invitation = relationshipService.pendingInvitations.first else {
            XCTFail("❌ Davet bulunamadı!")
            return
        }
        
        print("   Gönderen: \(invitation.senderName)")
        print("   Alıcı Email: \(invitation.receiverEmail)")
        print("   İlişki Başlangıç: \(invitation.relationshipStartDate)")
        
        // Adım 4: Daveti kabul et
        print("\n💚 Adım 5: Daveti kabul et")
        do {
            let relationshipId = try await relationshipService.acceptInvitation(
                invitation,
                receiverUserId: user2Id,
                receiverName: testUser2Name
            )
            
            testRelationshipId = relationshipId
            
            print("✅ Davet kabul edildi!")
            print("   İlişki ID: \(relationshipId)")
            
            // Relationship'i dinle
            try await Task.sleep(nanoseconds: 2_000_000_000)
            relationshipService.listenToRelationship(relationshipId: relationshipId)
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Adım 5: İlişkiyi doğrula
            print("\n✨ Adım 6: İlişkiyi doğrula")
            XCTAssertNotNil(relationshipService.currentRelationship, "❌ İlişki bulunamadı!")
            XCTAssertEqual(relationshipService.currentRelationship?.id, relationshipId, "❌ İlişki ID eşleşmiyor!")
            
            print("✅ İlişki başarıyla kuruldu!")
            print("   ID: \(relationshipId)")
            print("   Kullanıcı 1: \(relationshipService.currentRelationship?.user1Name ?? "N/A")")
            print("   Kullanıcı 2: \(relationshipService.currentRelationship?.user2Name ?? "N/A")")
            print("   Başlangıç Tarihi: \(relationshipService.currentRelationship?.startDate ?? Date())")
            
            // Adım 6: Her iki kullanıcının da relationshipId'si güncellenmiş mi kontrol et
            print("\n🔍 Adım 7: Kullanıcı profilleri güncellendi mi kontrol et")
            
            let user1Doc = try await db.collection("users").document(user1Id).getDocument()
            let user2Doc = try await db.collection("users").document(user2Id).getDocument()
            
            XCTAssertEqual(user1Doc.data()?["relationshipId"] as? String, relationshipId, "❌ Kullanıcı 1'in relationshipId'si güncellenmemiş!")
            XCTAssertEqual(user2Doc.data()?["relationshipId"] as? String, relationshipId, "❌ Kullanıcı 2'nin relationshipId'si güncellenmemiş!")
            
            print("✅ Her iki kullanıcının profili de güncellendi")
            print("   Kullanıcı 1 relationshipId: \(user1Doc.data()?["relationshipId"] as? String ?? "N/A")")
            print("   Kullanıcı 2 relationshipId: \(user2Doc.data()?["relationshipId"] as? String ?? "N/A")")
            
        } catch {
            XCTFail("❌ Davet kabul etme hatası: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Test 5: Davet Reddetme
    
    func testRejectInvitation() async throws {
        print("\n❌ Test 5: Davet Reddetme")
        print("-" * 60)
        
        // Kullanıcı 1'i kaydet
        try await authService.signUp(
            email: testUser1Email,
            password: testUser1Password,
            name: testUser1Name
        )
        testUser1Id = authService.currentUser?.id
        
        guard let user1Id = testUser1Id else {
            XCTFail("❌ Kullanıcı ID'si alınamadı!")
            return
        }
        
        // Davet gönder
        print("📤 Davet gönderiliyor...")
        try await relationshipService.sendInvitation(
            senderUserId: user1Id,
            senderName: testUser1Name,
            senderEmail: testUser1Email,
            receiverEmail: testUser2Email,
            startDate: Date()
        )
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Daveti getir
        let invitations = try await db.collection("invitations")
            .whereField("receiverEmail", isEqualTo: testUser2Email)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        guard let invitationDoc = invitations.documents.first else {
            XCTFail("❌ Davet bulunamadı!")
            return
        }
        
        let data = invitationDoc.data()
        let invitation = PartnerInvitation(
            id: invitationDoc.documentID,
            senderUserId: data["senderUserId"] as? String ?? "",
            senderName: data["senderName"] as? String ?? "",
            senderEmail: data["senderEmail"] as? String ?? "",
            receiverEmail: data["receiverEmail"] as? String ?? "",
            relationshipStartDate: (data["relationshipStartDate"] as? Timestamp)?.dateValue() ?? Date(),
            status: .pending,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        print("✅ Davet bulundu")
        
        // Daveti reddet
        print("🚫 Davet reddediliyor...")
        try await relationshipService.rejectInvitation(invitation)
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Reddedildiğini doğrula
        let updatedDoc = try await db.collection("invitations").document(invitationDoc.documentID).getDocument()
        let status = updatedDoc.data()?["status"] as? String
        
        XCTAssertEqual(status, "rejected", "❌ Davet durumu 'rejected' olmalı!")
        print("✅ Davet başarıyla reddedildi!")
        print("   Davet durumu: \(status ?? "N/A")")
    }
    
    // MARK: - Yardımcı Fonksiyonlar
    
    func cleanupTestData() async {
        print("\n🧹 Test verileri temizleniyor...")
        
        do {
            // Kullanıcıları sil
            if let user1Id = testUser1Id {
                try? await db.collection("users").document(user1Id).delete()
                print("   ✅ Kullanıcı 1 silindi")
            }
            
            if let user2Id = testUser2Id {
                try? await db.collection("users").document(user2Id).delete()
                print("   ✅ Kullanıcı 2 silindi")
            }
            
            // İlişkiyi sil
            if let relationshipId = testRelationshipId {
                try? await db.collection("relationships").document(relationshipId).delete()
                print("   ✅ İlişki silindi")
            }
            
            // Davetleri sil
            let invitations = try? await db.collection("invitations")
                .whereField("senderEmail", isEqualTo: testUser1Email)
                .getDocuments()
            
            for doc in invitations?.documents ?? [] {
                try? await doc.reference.delete()
            }
            
            let invitations2 = try? await db.collection("invitations")
                .whereField("receiverEmail", isEqualTo: testUser2Email)
                .getDocuments()
            
            for doc in invitations2?.documents ?? [] {
                try? await doc.reference.delete()
            }
            print("   ✅ Davetler silindi")
            
            // Firebase Auth kullanıcılarını sil
            if let currentUser = Auth.auth().currentUser {
                try? await currentUser.delete()
                print("   ✅ Firebase Auth kullanıcısı silindi")
            }
            
            relationshipService.stopListening()
            
        } catch {
            print("   ⚠️ Temizlik sırasında hata: \(error.localizedDescription)")
        }
    }
}

// MARK: - String Helper
extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
