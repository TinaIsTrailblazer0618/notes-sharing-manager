/** 
 * @author Tina Chang
 * @builtDate June 27, 2020
 * @name ContentDocumentLinkTriggerHandler
 * @description Custom trigger handler setup to handle all triggers received on ContentDocumentLink object
**/
public class ContentDocumentLinkTriggerHandler implements TriggerHandlerInterface {
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean triggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom settings or by running code
    */
    public Boolean isDisabled() { 
        TriggerSettings__c settings = TriggerSettings__c.getOrgDefaults();
        Boolean triggerDisabledBySettings = settings.ContentDocumentLinkTriggerDisabled__c;
        if (triggerDisabledBySettings) {
            return true;
        } else {
            return ContentDocumentLinkTriggerHandler.triggerDisabled;
        }
    }
 
    public void beforeInsert(List<SObject> newItems) {
    }
 
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void beforeDelete(Map<Id, SObject> oldItems) {
    }
 
    public void afterInsert(Map<Id, SObject> newItems) {
        ContentDocumentLinkHelper.shouldShareWithOthers(newItems.values());
    }
 
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void afterDelete(Map<Id, SObject> oldItems) {
    }
 
    public void afterUndelete(Map<Id, SObject> newItems) {
    }
}