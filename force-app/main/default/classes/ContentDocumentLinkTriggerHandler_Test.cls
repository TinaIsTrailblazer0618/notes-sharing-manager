@isTest
private class ContentDocumentLinkTriggerHandler_Test {

    static final Id GROUP_ID_CEB = ConstantsSelector.GROUP_ID_CEB;
    static final List<Id> MEMBER_IDS = new GroupMembersSelector().selectByGroupId(new Set<Id> { GROUP_ID_CEB });

    @isTest static void callTriggerContexts() {
        List<ContentDocumentLink> triggerLst;
        Map<Id, ContentDocumentLink> triggerMap;
        ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
        TriggerSettings__c cs = TriggerSettings__c.getOrgDefaults();
        System.assert(!cs.ContentDocumentLinkTriggerDisabled__c, 'Custom Settings ContentDocumentLinkTrigger is not disabled.');
        System.assert(!handler.isDisabled(), 'ContentDocumentLinkTrigger is not disabled in handler.');
        triggerLst = [SELECT Id, ContentDocumentId FROM ContentDocumentLink
                        WHERE ContentDocument.Title LIKE :ConstantsSelector.TEST_CONTENT_NOTE_TITLE + '%'
                        AND LinkedEntityId IN :MEMBER_IDS];
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