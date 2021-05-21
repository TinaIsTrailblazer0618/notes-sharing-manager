@IsTest
private class ContentDocumentLinkHelper_Test {

    static final String ROLE_NAME = 'BD_Sales';
    static final String LAST_NAME_1 = 'GenericLastName_1';
    static final String LAST_NAME_2 = 'GenericLastName_2';
    static final String LAST_NAME_3 = 'GenericLastName_3';
    static List<User> userLst1;
    static List<User> userLst2;
    static List<User> userLst3;
    static Id userId1;
    static Id userId2;
    static Id userId3;
    static User user3;
    static Group testGroup;
    static List<GroupMember> members;
    static List<ContentNote> noteList;
    static Map<Id, ContentNote> noteMap;
    
    @TestSetup
    static void dataCreation() {
        // Create three test users: Manager +1, Manager, and Sales Rep, which is user3.
        // Add user3 to the test public group.
        Test.startTest();
        TestDataFactory.constructUser(ConstantsSelector.TEST_PROFILE_CLIENT_SALES, ROLE_NAME, LAST_NAME_1);
        TestDataFactory.constructUser(ConstantsSelector.TEST_PROFILE_CLIENT_SALES, ROLE_NAME, LAST_NAME_2);
        TestDataFactory.constructUser(ConstantsSelector.TEST_PROFILE_CLIENT_SALES, ROLE_NAME, LAST_NAME_3);
        Test.stopTest();

        userLst1 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_1];
        userLst2 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_2];
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        System.assertEquals(1, userLst1.size(), 'Was expecting to find 1 user');
        System.assertEquals(1, userLst2.size(), 'Was expecting to find 1 user');
        System.assertEquals(1, userLst3.size(), 'Was expecting to find 1 user');

        userId3 = userLst3[0].Id;
        testGroup = TestDataFactory.constructPublicGroup(ConstantsSelector.TEST_GROUP_NAME, true);
        members = TestDataFactory.constructPublicGroupMember(testGroup.Id, new Set<Id> { userId3 }, true);
        System.assertEquals(1, members.size(), 'Was expecting to find 1 group member');
    }
    
    @IsTest static void notesToShareWithManagers() {
        // Setup.
        List<User> admins = [SELECT Id FROM User 
                            WHERE ProfileId = :ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID 
                            AND IsActive = true];
        userLst1 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_1];
        userLst2 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_2];
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        userId1 = userLst1[0].Id;
        userId2 = userLst2[0].Id;
        userId3 = userLst3[0].Id;
        user3 = userLst3[0];

        // Execution.
        System.runAs(admins[0]) {
            Test.startTest();
            user3.ManagerId = userId1;
            user3.Manager_1__c = userId2;
            update user3; 

            System.runAs(user3) {
                noteList = new List<ContentNote>();
                String body = 'Unit Test Note Body';
                noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE,
                                            Content = Blob.valueOf(body.escapeHTML4())));
                insert noteList;
            }
            TestDataFactory.contentDocumentLinkedToCurrentUser(noteList, true);
            Test.stopTest();

            // Check if record(s) have correct sharing now.
            noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                                WHERE OwnerId = :userId3
                                                AND Title = :ConstantsSelector.TEST_CONTENT_NOTE_TITLE]);
            System.assertEquals(1, noteMap.size(), 'Was expecting to find 1 content note');
            System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId1 
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 1 content document link');
            System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId2
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 1 content document link');
        }
    }

    @IsTest static void notesFailToShareWithManagers() {
        // Setup.
        List<User> admins = [SELECT Id FROM User 
                            WHERE ProfileId = :ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID 
                            AND IsActive = true];
        userLst1 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_1];
        userLst2 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_2];
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        userId1 = userLst1[0].Id;
        userId2 = userLst2[0].Id;
        userId3 = userLst3[0].Id;
        user3 = userLst3[0];

        Id groupId = [SELECT Id FROM Group WHERE Name = :ConstantsSelector.TEST_GROUP_NAME LIMIT 1].Id;
        List<GroupMember> removeMembers = [SELECT Id FROM GroupMember WHERE GroupId = :groupId];
        delete removeMembers;

        // Execution.
        System.runAs(admins[0]) {
            Test.startTest();
            user3.ManagerId = userId1;
            user3.Manager_1__c = userId2;
            update user3;

            System.runAs(user3) {
                noteList = new List<ContentNote>();
                String body = 'Unit Test Note Body';
                noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE,
                                            Content = Blob.valueOf(body.escapeHTML4())));
                insert noteList;
            }
            TestDataFactory.contentDocumentLinkedToCurrentUser(noteList, true);
            Test.stopTest();

            // Assert that records NOT shared because user3 was removed from the test public group.
            noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                                WHERE OwnerId = :userId3
                                                AND Title = :ConstantsSelector.TEST_CONTENT_NOTE_TITLE]);
            System.assertEquals(1, noteMap.size(), 'Was expecting to find 1 content note');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId1 
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId2
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
        }
    }


    @IsTest static void salesRepsWithoutManagers() {
        // Setup.
        List<User> admins = [SELECT Id FROM User 
                            WHERE ProfileId = :ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID 
                            AND IsActive = true];
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        userId3 = userLst3[0].Id;
        user3 = userLst3[0];

        // Execution.
        System.runAs(admins[0]) {
            Test.startTest();
            System.runAs(user3) {
                noteList = new List<ContentNote>();
                String body = 'Unit Test Note Body';
                noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE,
                                            Content = Blob.valueOf(body.escapeHTML4())));
                insert noteList;
            }
            TestDataFactory.contentDocumentLinkedToCurrentUser(noteList, true);
            Test.stopTest();

            // Assert that records NOT shared because manager(s) not specified for user3
            noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                                WHERE OwnerId = :userId3
                                                AND Title = :ConstantsSelector.TEST_CONTENT_NOTE_TITLE]);
            System.assertEquals(1, noteMap.size(), 'Was expecting to find 1 content note');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId1 
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId2
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
        }
    }

    @IsTest static void salesRepsWithoutManagerPlus1() {
        // Setup.
        List<User> admins = [SELECT Id FROM User 
                            WHERE ProfileId = :ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID 
                            AND IsActive = true];
        userLst1 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_1];
        userId1 = userLst1[0].Id;
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        userId3 = userLst3[0].Id;
        user3 = userLst3[0];

        // Execution.
        System.runAs(admins[0]) {
            Test.startTest();
            user3.ManagerId = userId1;
            update user3;

            System.runAs(user3) {
                noteList = new List<ContentNote>();
                String body = 'Unit Test Note Body';
                noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE,
                                            Content = Blob.valueOf(body.escapeHTML4())));
                insert noteList;
            }
            TestDataFactory.contentDocumentLinkedToCurrentUser(noteList, true);
            Test.stopTest();

            // Assert that record shared with immediate manager only.
            noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                                WHERE OwnerId = :userId3
                                                AND Title = :ConstantsSelector.TEST_CONTENT_NOTE_TITLE]);
            System.assertEquals(1, noteMap.size(), 'Was expecting to find 1 content note');
            System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId1 
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 1 content document link');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId2
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
        }
    }

    @IsTest static void shouldNotShareTriggerDisabled() {
        TriggerSettings__c settings;
        // Retrieve Custom Settings status, for org defaults.
        settings = TriggerSettings__c.getOrgDefaults();
        System.assert(!settings.ContentDocumentLinkTriggerDisabled__c, 'Trigger is not disabled in Custom Settings');
        // Disable Trigger through Custom Settings.
        settings.ContentDocumentLinkTriggerDisabled__c = true;
        upsert settings;
        System.assert(settings.ContentDocumentLinkTriggerDisabled__c, 'Trigger is disabled in Custom Settings');

        List<User> admins = [SELECT Id FROM User 
                            WHERE ProfileId = :ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID 
                            AND IsActive = true];
        userLst1 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_1];
        userLst2 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_2];
        userLst3 = [SELECT Id FROM User WHERE LastName = :LAST_NAME_3];
        userId1 = userLst1[0].Id;
        userId2 = userLst2[0].Id;
        userId3 = userLst3[0].Id;
        user3 = userLst3[0];

        // Execution.
        System.runAs(admins[0]) {
            Test.startTest();
            user3.ManagerId = userId1;
            user3.Manager_1__c = userId2;
            update user3;

            System.runAs(user3) {
                noteList = new List<ContentNote>();
                String body = 'Unit Test Note Body';
                noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE,
                                            Content = Blob.valueOf(body.escapeHTML4())));
                insert noteList;
            }
            TestDataFactory.contentDocumentLinkedToCurrentUser(noteList, true);
            Test.stopTest();

            // Assert that records NOT shared.
            noteMap = new Map<Id, ContentNote>([SELECT Id, OwnerId FROM ContentNote 
                                                WHERE OwnerId = :userId3
                                                AND Title = :ConstantsSelector.TEST_CONTENT_NOTE_TITLE]);
            System.assertEquals(1, noteMap.size(), 'Was expecting to find 1 content note');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId1 
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink 
                                    WHERE LinkedEntityId = :userId2
                                    AND ContentDocumentId IN :noteMap.keySet()],
                                    'Was expecting to find 0 content document link');
        }                                   
    }
    
}