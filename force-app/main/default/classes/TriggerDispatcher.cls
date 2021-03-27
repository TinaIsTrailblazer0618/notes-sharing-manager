/** 
 * @author Tina Chang
 * @builtDate June 29, 2020
 * @name TriggerDispatcher
 * @description The dispatcher is responsible for making sure all of the applicable methods on trigger handler are called, depending on the current trigger context. 
 *                  It also contains a check to make sure that the trigger has not been disabled. 
 *                  If the trigger has been disabled, then the trigger events will not be fired (See lines 16/17).
**/
public class TriggerDispatcher {
    /*
        Call this method from the trigger, passing in an instance of a trigger handler which implements TriggerHandlerInterface.
        This method will fire the appropriate methods on the handler depending on the trigger context.
    */
    public static void run(TriggerHandlerInterface handler) {
        // Check to see if the trigger has been disabled. If it has, return
        if (handler.isDisabled()) {
            return;
        }
             
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            }
            /*
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.oldMap);
            }
            */
            when AFTER_INSERT {
                handler.afterInsert(Trigger.newMap);
            }
            when AFTER_UPDATE {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
            /*
            when AFTER_DELETE {
                handler.afterDelete(Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.newMap);
            }
            */
        }
    }
}