/** 
 * @author Tina Chang
 * @date July 8, 2020
 * @name ContentNoteSharingSettings
 * @description After data insertion of new ContentNote, perform check on the new ContentNote records.
 *  If a ContentDocumentLink record already exists relating this ContentNoteId to this LinkedEntityId, don't insert.
 *  If not, insert a new ContentDocumentLink to associate ContentDocumentId(ContentNoteId) with LinkedEntityId in the database asynchronously.
**/
public inherited sharing class ContentNoteSharingSettings implements Queueable {

    public class NotesSharingException extends Exception {}

    Map<Id, Id> mapNoteUserIds; // ContentDocumentId, OwnerId;
    Set<Id> noteIds;
    Map<Id, Set<Id>> notesToShareWithMgrs;
    List<ContentDocumentLink> cdlsToInsert = 
        new List<ContentDocumentLink>();

    public ContentNoteSharingSettings(Map<Id, Id> mapNoteUserIdsToShare) {
        this.mapNoteUserIds = mapNoteUserIdsToShare;
        this.noteIds = mapNoteUserIds.keySet();
    }

    public void execute(QueueableContext context) {
        //
        // The whole execute method encompasses 
        // the business logic that determines whether to share ContentNote with other users.
        //
        if (!mapNoteUserIds.isEmpty()) {
            Map<Id, Set<Id>> mapUserMgrIds = searchUserManagers(mapNoteUserIds.values()); // mapUserMgrIds = userId, mgrIds
            if (mapUserMgrIds != null && !mapUserMgrIds.isEmpty()) {
                checkLinkedEntityIdAlreadyExists(noteIds, mapUserMgrIds);
            }
        }

        if (!notesToShareWithMgrs.isEmpty()) {
            insertContentDocumentLink(notesToShareWithMgrs);
        }

        if (!cdlsToInsert.isEmpty()) {
            try {
                insert cdlsToInsert;
                System.debug('cdlsToInsert: ' + cdlsToInsert);
            } catch (Exception e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
        }  
    }

    /**
     * @name searchUserManagers
     * @description Private helper Method
     */
    Map<Id, Set<Id>> searchUserManagers(List<Id> userIds) {
        Map<Id, Set<Id>> mapUserMgrIds = new Map<Id, Set<Id>>();
        for (User u : [SELECT Id,
                       		Email,
                            ManagerId, 
                            Manager_1__c
                        FROM User
                        WHERE Id IN :userIds]) {
            // All note sharing participating members must have a value specified in the Manager field for the auto-sharing to happen.
            if (u.ManagerId != null) {
                if (u.Manager_1__c == null) {
                    mapUserMgrIds.put(u.Id, new Set<Id> { u.ManagerId });
                } else {
                    mapUserMgrIds.put(u.Id, new Set<Id> { u.ManagerId, u.Manager_1__c });
                }
            } else {
                mapUserMgrIds.put(u.Id, null);
            }
        } 
        return mapUserMgrIds;
    }

    /**
     * @name checkLinkedEntityIdAlreadyExists
     * @description Private helper Method
     */
    void checkLinkedEntityIdAlreadyExists(Set<Id> noteIds, Map<Id, Set<Id>> mapUserMgrIds) {
        // Check to see if linkedEntityId already exists for the note.
        notesToShareWithMgrs = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapDocToEntities = queryAllRelatedLinks(noteIds);
        for (Id noteId : noteIds) {
            System.debug('noteId is ' + noteId);
            Set<Id> linkedEntityIds = mapDocToEntities.get(noteId);
            System.debug('linkedEntityIds are ' + linkedEntityIds); 
            Id ownerId = mapNoteUserIds.get(noteId);
            Set<Id> mgrIds = mapUserMgrIds.get(ownerId);
            if (mgrIds != null) {
                for (Id mgrId : mgrIds) {       
                    if (linkedEntityIds != null && !linkedEntityIds.contains(mgrId)) {
                        // If managers of group members haven't already been granted access to note records, 
                        // populate notesToShareWithMgrs map
                        if (notesToShareWithMgrs.containsKey(noteId)) {
                            Set<Id> addMgrIds = notesToShareWithMgrs.get(noteId);
                            addMgrIds.add(mgrId);
                            notesToShareWithMgrs.put(noteId, addMgrIds);
                        } else {
                            notesToShareWithMgrs.put(noteId, new Set<Id> { mgrId });
                        }                   
                    } // If managers of group members have already been granted access to note records, do nothing          
                }
        	}		
        }
        System.debug('notesToShareWithMgrs: ' + notesToShareWithMgrs);     
    }

    /**
     * @name queryAllRelatedLinks
     * @description Helper Method
     */
    public Map<Id, Set<Id>> queryAllRelatedLinks(Set<Id> noteIds) {
        // Query for all LinkedEntityIds that are associated with the notes
        // and put them in a ContentDocumentId to LinkedEntityIds map 
        Map<Id, Set<Id>> mapDocToEntities = new Map<Id, Set<Id>>();
        for (ContentDocumentLink cdl : [SELECT Id, 
                                                ContentDocumentId, 
                                                LinkedEntityId 
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId 
                                        IN :noteIds]) {
            if (mapDocToEntities.containsKey(cdl.ContentDocumentId)) {
                Set<Id> linkedEntityIdSet = mapDocToEntities.get(cdl.ContentDocumentId);
                linkedEntityIdSet.add(cdl.LinkedEntityId);
                mapDocToEntities.put(cdl.ContentDocumentId, linkedEntityIdSet);
            } else {
                mapDocToEntities.put(cdl.ContentDocumentId, new Set<Id> { cdl.LinkedEntityId });
            }
        }
        return mapDocToEntities;                
    }

    /**
     * @name insertContentDocumentLink
     * @description Private helper Method
     */
    void insertContentDocumentLink(Map<Id, Set<Id>> notesToShareWithMgrs) {
        System.debug('# of ContentDocumentLink to create: ' + notesToShareWithMgrs.values());         
        for (Id noteId : notesToShareWithMgrs.keySet()) {
            for (Id mgrId : notesToShareWithMgrs.get(noteId)) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = noteId;
                cdl.LinkedEntityId = mgrId; // User Id where user wants to share the note.
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                cdlsToInsert.add(cdl);
            } 
        }
    }
    
}