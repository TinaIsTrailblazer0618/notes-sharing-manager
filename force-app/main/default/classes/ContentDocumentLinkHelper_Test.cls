@isTest
private class ContentDocumentLinkHelper_Test {

    static final Id GROUP_ID_CEB = ConstantsSelector.GROUP_ID_CEB;
    static final Id GROUP_ID_CIR = ConstantsSelector.GROUP_ID_CIR;
    static final Id LEADER_CEB = ConstantsSelector.TEAM_LEAD_ID_CEB;
    static final Id LEADER_CIR = ConstantsSelector.TEAM_LEAD_ID_CIR;
    static final Id LEADER_SALES_VP = ConstantsSelector.SALES_VP;
    static final String PROFILE_CEB_LEAD = ConstantsSelector.TEST_PROFILE_CEB_LEAD;
    static final String NOTE_TITLE = ConstantsSelector.TEST_CONTENT_NOTE_TITLE;
    static final String PROFILE_NAME = ConstantsSelector.TEST_PROFILE_CEB_LEAD;
    static final String ROLE_NAME = 'BD_Sales';
    static final String LAST_NAME = 'GenericLastName';

    static List<Id> memberIds;
    static List<ContentNote> cnLst;
    static Map<Id, ContentNote> noteMap;
    
    @TestSetup static void dataCreation() {
        // Create a test user "without Manager info" and add to a note sharing participating group
        List<User> userLst;
        Set<Id> userIds;
        Group g;
        List<GroupMember> members;
        Test.startTest();
        TestDataFactory.constructUser(PROFILE_NAME, ROLE_NAME, LAST_NAME);                     
        Test.stopTest();
        userLst = [SELECT Id FROM User WHERE LastName = :LAST_NAME];
        System.assertEquals(1, userLst.size(), 'Was expecting to find 1 user');
        userIds = new Map<Id, User>(userLst).keySet();
        g = TestDataFactory.constructPublicGroup(true);
        members = TestDataFactory.constructPublicGroupMember(g.Id, userIds, true);
        System.assertEquals(1, members.size(), 'Was expecting to find 1 group member');
    }
    
    @isTest static void shouldShare_insertNotesWithOwnerOfTeamMembers_CEB() {
        // Get the Ids of the members
        memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { GROUP_ID_CEB });
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        cnLst = TestDataFactory.constructContentNotesOfGroupMembers(20, GROUP_ID_CEB, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        // Validate the job ran. Check if record have correct sharing now
        noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                            WHERE OwnerId IN :memberIds
                                            AND Title LIKE :NOTE_TITLE + '%']);
        System.assertEquals(20, noteMap.size(), 'Was expecting to find 20 content notes');
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_CEB
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 20 content document links');
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_SALES_VP
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 20 content document links');                                     
    }

    @isTest static void shouldShare_insertNotesWithOwnerOfTeamMembers_CIR() {
        // Get the Ids of the members
        memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { GROUP_ID_CIR });
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        cnLst = TestDataFactory.constructContentNotesOfGroupMembers(20, GROUP_ID_CIR, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        // Validate the job ran. Check if record have correct sharing now
        noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                            WHERE OwnerId IN :memberIds
                                            AND Title LIKE :NOTE_TITLE + '%']);
        System.assertEquals(20, noteMap.size(), 'Was expecting to find 20 content notes');
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_CIR
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 20 content document links');
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_SALES_VP
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 20 content document links');                                       
    }    

    @isTest static void shouldShare_insertNotesWithOwnerOfTeamLead_CEB() {
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        cnLst = TestDataFactory.constructContentNotesOfUser(20, LEADER_CEB, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        // Validate the job ran. Check if the ContentNoteSharingSettings class validated linkedEntityId already exists for the note
        // If validation failed, the following error could occur:
        // "System.DmlException: Insert failed. First exception on row 0; first error: INSUFFICIENT_ACCESS_OR_READONLY, Invalid sharing type I: [ShareType]"
        // If assertion passed, the validation was handled properly
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_CEB
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 20 content document links');         
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_SALES_VP
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 20 content document links');                      
    }    

    @isTest static void shouldShare_insertNotesWithOwnerOfTeamLead_CIR() {
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        cnLst = TestDataFactory.constructContentNotesOfUser(20, LEADER_CIR, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        // Validate the job ran. Check if the ContentNoteSharingSettings class validated linkedEntityId already exists for the note
        // If validation failed, the following error could occur:
        // "System.DmlException: Insert failed. First exception on row 0; first error: INSUFFICIENT_ACCESS_OR_READONLY, Invalid sharing type I: [ShareType]"
        // If assertion passed, the validation was handled properly
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_CIR
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 20 content document links');            
        System.assertEquals(20, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_SALES_VP
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 20 content document links');                      
    }  

    @isTest static void shouldNotShareTriggerDisabled() {
        TriggerSettings__c settings;
        // Get the Ids of the members
        memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { GROUP_ID_CEB });
        // Retrieve Custom Settings status, for org defaults
        settings = TriggerSettings__c.getOrgDefaults();
        System.assert(!settings.ContentDocumentLinkTriggerDisabled__c, 'Trigger is not disabled in Custom Settings');
        // Disable Trigger through Custom Settings
        settings.ContentDocumentLinkTriggerDisabled__c = true;
        upsert settings;
        System.assert(settings.ContentDocumentLinkTriggerDisabled__c, 'Trigger is disabled in Custom Settings');      
        // startTest/stopTest block to force async processes to run
        Test.startTest();        
        cnLst = TestDataFactory.constructContentNotesOfGroupMembers(20, GROUP_ID_CEB, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        // Validate the job ran. Assert that records not owned by team lead or sales vp are NOT directly shared with them
        noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                            WHERE OwnerId IN :memberIds
                                            AND Title LIKE :NOTE_TITLE + '%']);
        System.assertEquals(20, noteMap.size(), 'Was expecting to find 20 content notes');
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_CEB
                                AND ContentDocument.OwnerId != :LEADER_CEB
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 0 content document links');
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :LEADER_SALES_VP
                                AND ContentDocument.OwnerId != :LEADER_SALES_VP
                                AND ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 0 content document links');                                        
    }

    @isTest static void shouldNotShareWithoutManagerInfo() {		
        // Any user in the note sharing participating group should have a value in the "Manager" field on their user records.
        // Note @testSetup dataCreation() method
        // ==> this method creates a test user "without Manager info" and add to a note sharing participating group.
        // ==> lastly, have test user create a note and verify auto-sharing did not happen and not cause errors.
        User u = [SELECT Id FROM User WHERE LastName = :LAST_NAME LIMIT 1];
        Test.startTest();
        cnLst = TestDataFactory.constructContentNotesOfUser(1, u.Id, true);
        TestDataFactory.contentDocumentLinkedToCurrentUser(cnLst, true);
        Test.stopTest();
        noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                            WHERE OwnerId = :u.Id
                                            AND Title LIKE :NOTE_TITLE + '%']);
		// Validate two content document links were created for this note without errors
		// Expect to find 2 content doc links: 
        // one linked to note owner and the other one linked to the current context user (whoever runs this test class)       
        System.assertEquals(2, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE ContentDocumentId IN :noteMap.keySet()],
                                'Was expecting to find 2 content document links');         
    }

}