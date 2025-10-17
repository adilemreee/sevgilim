//
//  PartnerInvitationTests.swift
//  sevgilimTests

import XCTest
@testable import sevgilim

final class PartnerInvitationTests: XCTestCase {
    
    func testInvitationInitialization() {
        let invitation = PartnerInvitation(
            id: UUID().uuidString,
            senderUserId: UUID().uuidString,
            senderName: "Sender",
            senderEmail: "sender@test.com",
            receiverEmail: "receiver@test.com",
            relationshipStartDate: Date(),
            status: .pending,
            createdAt: Date()
        )
        
        XCTAssertEqual(invitation.senderName, "Sender")
        XCTAssertEqual(invitation.receiverEmail, "receiver@test.com")
        XCTAssertEqual(invitation.status, .pending)
    }
    
    func testPendingInvitation() {
        let invitation = PartnerInvitation(
            senderUserId: UUID().uuidString,
            senderName: "Sender",
            senderEmail: "sender@test.com",
            receiverEmail: "receiver@test.com",
            relationshipStartDate: Date(),
            status: .pending,
            createdAt: Date()
        )
        
        XCTAssertEqual(invitation.status, .pending)
    }
    
    func testAcceptedInvitation() {
        let invitation = PartnerInvitation(
            senderUserId: UUID().uuidString,
            senderName: "Sender",
            senderEmail: "sender@test.com",
            receiverEmail: "receiver@test.com",
            relationshipStartDate: Date(),
            status: .accepted,
            createdAt: Date()
        )
        
        XCTAssertEqual(invitation.status, .accepted)
    }
}
