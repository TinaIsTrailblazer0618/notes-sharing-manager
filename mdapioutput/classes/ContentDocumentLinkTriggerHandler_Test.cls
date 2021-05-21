@IsTest
private class ContentDocumentLinkTriggerHandler_Test {
    static final String ROLE_NAME = 'BD_Sales';
    static final String LAST_NAME = 'GenericLastName';

    @TestSetup
    static void dataCreation() {
        List<User> userLst;

        Test.startTest();
        TestDataFactory.constructUser(ConstantsSelector.TEST_PROFILE_CLIENT_SALES, ROLE_NAME, LAST_NAME);
        Test.stopTest();

        userLst = [SELECT Id FROM User WHERE LastName = :LAST_NAME];
        System.assertEquals(1, userLst.size(), 'Was expecting to find 1 user');
    }

    @IsTest static void callTriggerContexts() {
        List<ContentDocumentLink> triggerLst;
        Map<Id, ContentDocumentLink> triggerMap;
        ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
        TriggerSettings__c cs = TriggerSettings__c.getOrgDefaults();
        System.assert(!cs.ContentDocumentLinkTriggerDisabled__c, 'Custom Settings ContentDocumentLinkTrigger is not disabled.');
        System.assert(!handler.isDisabled(), 'ContentDocumentLinkTrigger is not disabled in handler.');

        Id userId = [SELECT Id FROM User WHERE LastName = :LAST_NAME][0].Id;
        triggerLst = [SELECT Id, ContentDocumentId FROM ContentDocumentLink
                        WHERE ContentDocument.Title LIKE :ConstantsSelector.TEST_CONTENT_NOTE_TITLE + '%'
                        AND LinkedEntityId = :userId];
        triggerMap = new Map<Id, ContentDocumentLink>(triggerLst);
        handler.beforeInsert(triggerLst);
        handler.beforeUpdate(triggerMap, triggerMap);
        handler.beforeDelete(triggerMap);
        handler.afterInsert(triggerMap);
        handler.afterUpdate(triggerMap, triggerMap);
        handler.afterDelete(triggerMap);
        handler.afterUndelete(triggerMap);
    }

}