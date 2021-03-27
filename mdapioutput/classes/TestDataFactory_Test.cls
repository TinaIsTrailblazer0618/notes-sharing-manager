@isTest
private with sharing class TestDataFactory_Test {
    
    static final String PROFILE_NAME = ConstantsSelector.TEST_PROFILE_CEB_LEAD;
    static final String RECORD_TYPE = ConstantsSelector.RECORD_TYPE_CEB;
    static final String GROUP_ID_CIR = ConstantsSelector.GROUP_ID_CIR;
    static final String TEAM_LEAD_ID_CIR = ConstantsSelector.TEAM_LEAD_ID_CIR;
    static final String SALES_VP_ID = ConstantsSelector.SALES_VP;
    static final String NOTE_TITLE = ConstantsSelector.TEST_CONTENT_NOTE_TITLE;
    static final String VERSION_TITLE = ConstantsSelector.TEST_CONTENT_VERSION_TITLE;
    static final String ROLE_NAME = 'BD_Sales';
    static final String LAST_NAME = 'GenericLastName'; 
    static final String STAGE_NAME = 'Qualification';
    
    @TestSetup
    static void dataCreation() {
        Test.startTest();
        TestDataFactory.constructUser(PROFILE_NAME, ROLE_NAME, LAST_NAME);
        TestDataFactory.insertTestDataForOppNotes(3, 1, 5, STAGE_NAME, RECORD_TYPE, true);
        TestDataFactory.insertTestDataForNotes(3, GROUP_ID_CIR, TEAM_LEAD_ID_CIR, true);
        Test.stopTest();
    }

    @isTest static void testInsertTestDataForNotes() {
        Set<Id> cnIds;
        Set<Id> cdIds;
        List<ContentNote> cnLst;
        List<ContentVersion> cvLst;
        List<ContentDocumentLink> cdlLst1;
        Integer cdlLst2;
        Integer cdlLst3;      
        Test.startTest();
        cnLst = [SELECT Id FROM ContentNote
                WHERE Title LIKE :NOTE_TITLE + '%'
                AND OwnerId != :UserInfo.getUserId()];
        cvLst = [SELECT Id, ContentDocumentId FROM ContentVersion
                WHERE Title LIKE :VERSION_TITLE + '%'];
        cnIds = (new Map<Id, SObject>(cnLst)).keySet();
        cdIds = new Set<Id>();
        for (ContentVersion cv : cvLst) {
            cdIds.add(cv.ContentDocumentId);
        }                                                  
        cdlLst1 = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink 
                    WHERE ContentDocumentId IN :cnIds
                    OR ContentDocumentId IN :cdIds];
        cdlLst2 = [SELECT COUNT() FROM ContentDocumentLink 
                    WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                    AND ContentDocument.Title LIKE :VERSION_TITLE + '%'];
        cdlLst3 = [SELECT COUNT() FROM ContentDocumentLink 
                    WHERE LinkedEntityId = :SALES_VP_ID
                    AND ContentDocument.Title LIKE :VERSION_TITLE + '%'];
        Test.stopTest();
        System.debug('cdlLst1: ' + cdlLst1);
        System.assertEquals(6, cnLst.size(), 'Was expecting to find 6 content notes');
        System.assertEquals(3, cvLst.size(), 'Was expecting to find 3 content versions');
        System.assertEquals(29, cdlLst1.size(), 'Was expecting to find 29 content document links');
        System.assertEquals(0, cdlLst2, 'Was expecting to find 0 content document links');
        System.assertEquals(0, cdlLst3, 'Was expecting to find 0 content document links');
        /**
         * Owner + Shared With = 29 cotent document links
         */
        /********************************************************************************
         *                                      Owner       Shared With 
         * constructContentNotesOfGroupMembers  James       Current User, Sales VP
         *                                      Jazmin      Current User, Sales VP, James
         *                                      Annie       Current User, Sales VP, James
         * constructContentNotesOfUser          James       Current User, Sales VP
         *                                      James       Current User, Sales VP
         *                                      James       Current User, Sales VP
         * constructContentVersionsOfUser       Jazmin      Current User, Opp
         *                                      Jazmin      Current User, Opp
         *                                      Jazmin      Current User, Opp
         * ******************************************************************************                                        
         */
    }

    @isTest static void testInsertTestDataForOppNotes() {
        Set<Id> oppIds;
        List<ContentNote> cnLst;
        List<ContentDocumentLink> cdlLst;     
        Test.startTest();
        oppIds = (new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE StageName = 'Qualification'
                                            AND Name LIKE :ConstantsSelector.TEST_OPP_NAME_CEB + '%'])).keySet();
        cnLst = [SELECT Id FROM ContentNote
                WHERE Title LIKE :NOTE_TITLE + '%'
                AND OwnerId = :UserInfo.getUserId()];                                
        cdlLst = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN :oppIds];                            
        Test.stopTest();
        System.assertEquals(6, oppIds.size(), 'Was expecting to find 6 opportunities'); // 1 opp from insertTestDataForNotes + 5 opps from insertTestDataForOppNotes                                                  
        System.assertEquals(3, cnLst.size(), 'Was expecting to find 3 content notes');
        System.assertEquals(18, cdlLst.size(), 'Was expecting to find 18 content document links'); // 3 from insertTestDataForNotes + 15 from insertTestDataForOppNotes
    }

    @isTest static void updateNotes() {
        Map<Id, ContentNote> cnMap;
        List<ContentVersion> cvLst;
        String body;
        List<ContentVersion> cvToUpdate;        
        cnMap = new Map<Id, ContentNote>([SELECT Id FROM ContentNote
                                        WHERE Title LIKE :NOTE_TITLE + '%'
                                        AND OwnerId != :UserInfo.getUserId()]);
        cvLst = [SELECT Id, VersionData FROM ContentVersion
                WHERE ContentDocumentId = :cnMap.keySet()
                AND IsLatest = TRUE];
        body = 'Updated Unit Test Note Body';
        cvToUpdate = new List<ContentVersion>();
        for (ContentVersion cv : cvLst) {
            cv.VersionData = Blob.valueOf(body.escapeHtml4());
            cvToUpdate.add(cv);
        }
        Test.startTest();
        update cvToUpdate;        
        Test.stopTest();
        System.assertEquals(6, cnMap.size(), 'Was expecting to find 6 content notes');  
        System.assertEquals(6, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 6 content document links');                      
    }

    @isTest static void deleteNotes() {
        List<ContentNote> cnLst;
        cnLst = [SELECT Id FROM ContentNote
                WHERE Title LIKE :NOTE_TITLE + '%'
                AND OwnerId != :UserInfo.getUserId()];
        Test.startTest();
        delete cnLst;        
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM ContentNote
                                WHERE Title LIKE :NOTE_TITLE + '%'
                                AND OwnerId != :UserInfo.getUserId()], 
                                'Was expecting to find 0 content notes');  
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 0 content document links');                       
    }

    @isTest static void undeleteNotes() {
        List<ContentNote> cnLst;
        Integer cdl1;
        Integer cdl2;
        Test.startTest();
        cnLst = [SELECT Id FROM ContentNote
                WHERE Title LIKE :NOTE_TITLE + '%'
                AND OwnerId != :UserInfo.getUserId()];
        cdl1 = [SELECT COUNT() FROM ContentDocumentLink 
                WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'];
        cdl2 = [SELECT COUNT() FROM ContentDocumentLink 
                WHERE LinkedEntityId = :SALES_VP_ID
                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'];
        Test.stopTest();
        /** 
         * Verify data insert in @TestSetup
         */
        System.assertEquals(6, cnLst.size(), 'Was expecting to find 6 content notes');  
        System.assertEquals(6, cdl1, 'Was expecting to find 6 content document links');
        System.assertEquals(6, cdl2, 'Was expecting to find 6 content document links');
        /**
         * Verify delete operation
         */                                
        delete cnLst;
        System.assertEquals(0, [SELECT COUNT() FROM ContentNote
                                WHERE Title LIKE :NOTE_TITLE + '%'
                                AND OwnerId != :UserInfo.getUserId()],
                                'Was expecting to find 0 content notes');  
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 0 content document links');
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :SALES_VP_ID
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 0 content document links');                                  
        /**
         * Verify undelete operation
         */        
        undelete cnLst;      
        System.assertEquals(6, [SELECT COUNT() FROM ContentNote
                                WHERE Title LIKE :NOTE_TITLE + '%'
                                AND OwnerId != :UserInfo.getUserId()],
                                'Was expecting to find 6 content notes');  
        System.assertEquals(6, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :TEAM_LEAD_ID_CIR
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 6 content document links');
        System.assertEquals(6, [SELECT COUNT() FROM ContentDocumentLink 
                                WHERE LinkedEntityId = :SALES_VP_ID
                                AND ContentDocument.Title LIKE :NOTE_TITLE + '%'],
                                'Was expecting to find 6 content document links');                                                           
    }

    @isTest static void testConstructUser() {
        List<User> userLst;
        Test.startTest();
        userLst = [SELECT Id FROM User WHERE LastName = :LAST_NAME];                              
        Test.stopTest();
        System.assertEquals(1, userLst.size(), 'Was expecting to find 1 user');
    }

    @isTest static void testConstructPublicGroupWithMembers() {
        List<User> userLst;
        Set<Id> userIds;
        Group g;
        List<GroupMember> members;
        Test.startTest();
        userLst = [SELECT Id FROM User WHERE LastName = :LAST_NAME];                              
        Test.stopTest();
        System.assertEquals(1, userLst.size(), 'Was expecting to find 1 user');
        userIds = new Map<Id, User>(userLst).keySet();
        g = TestDataFactory.constructPublicGroup(true);
        members = TestDataFactory.constructPublicGroupMember(g.Id, userIds, true);
        System.assertEquals(1, members.size(), 'Was expecting to find 1 group member');
    }

}