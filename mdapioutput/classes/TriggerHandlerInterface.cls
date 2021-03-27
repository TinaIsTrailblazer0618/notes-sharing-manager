/** 
 * @author Tina Chang
 * @date June 29, 2020
 * @name TriggerHandlerInterface
 * @description The interface dictates which methods every trigger handler must implement, 
 *                  even if these methods have no code in them. 
 *                  By implementing the methods in this class, 
 *                  the TriggerDispatcher can be confident that the trigger handler has a method for each of these events.
**/
public interface TriggerHandlerInterface {
    void beforeInsert(List<SObject> newItems);
 
    void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
 
    void beforeDelete(Map<Id, SObject> oldItems);
 
    void afterInsert(Map<Id, SObject> newItems);
 
    void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
 
    void afterDelete(Map<Id, SObject> oldItems);
 
    void afterUndelete(Map<Id, SObject> newItems);
 
    Boolean isDisabled();
}