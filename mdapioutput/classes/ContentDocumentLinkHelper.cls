public without sharing class ContentDocumentLinkHelper {
    /**
     * @name shouldShareWithOthers
     * @date March, 2021
     * @description Helper method to decide whether to share the note with other users.
     *  Depending on the note owner,
     *  if the note owner is one of the group members defined in the Notes Sharing Group custom metadata type,
     *  the note owner will share his/her notes with immediate manager (and manager + 1 if exists).
     */
    public static void shouldShareWithOthers(List<ContentDocumentLink> cdls) {
        Set<Id> docIds = new Set<Id>();
        Map<Id, Id> mapDocToOwner = new Map<Id, Id>();
        Map<Id, String> mapDocToFileType = new Map<Id, String>();
        List<String> groupDevNames = new List<String>();
        Set<Id> groupIds = new Set<Id>();
        List<Id> memberIds;
        Map<Id, Id> mapNoteUserIdsToShare = new Map<Id, Id>(); // Map<ContentDocumentId, OwnerId>;

        for (ContentDocumentLink cdl : cdls) {
            docIds.add(cdl.ContentDocumentId);
        }

        for (ContentDocument doc : [SELECT Id, 
                                            OwnerId, 
                                            FileType 
                                    FROM ContentDocument 
                                    WHERE Id = :docIds]) {
            mapDocToOwner.put(doc.Id, doc.OwnerId);
            mapDocToFileType.put(doc.Id, doc.FileType);
        }

        // Users in groups defined in this Notes Sharing Group mdt will share their notes with their immediate manager & manager + 1.
        // Step 1: Query for Notes Sharing Group mdt
        List<Notes_Sharing_Group__mdt> notesSharingGroups = [SELECT DeveloperName, 
                                                                    Active__c 
                                                            FROM Notes_Sharing_Group__mdt
                                                            WITH SECURITY_ENFORCED];    
        for (Notes_Sharing_Group__mdt notesSharingGroup : notesSharingGroups) {
            if (notesSharingGroup.Active__c) {
                groupDevNames.add(notesSharingGroup.DeveloperName);
            }
        }
        
        // Step 2: Get the Ids of the note sharing participating groups
        for (Group gr : [SELECT Id 
                        FROM Group 
                        WHERE DeveloperName 
                        IN :groupDevNames]) {
            groupIds.add(gr.Id);
        }

        // Step 3: Get the Ids of the note sharing participating members
        memberIds = new GroupMembersSelector().selectByGroupId(groupIds);

        // Step 4: Determine if the note needs to be shared with the note owner's managers
        for (ContentDocumentLink cdl : cdls) {
            Id ownerId = mapDocToOwner.get(cdl.ContentDocumentId);
            String fileType = mapDocToFileType.get(cdl.ContentDocumentId);
            System.debug('ownerId is ' + ownerId);
            System.debug('fileType is ' + fileType);
            if (fileType == ConstantsSelector.FILE_TYPE_SNOTE) {
                if (memberIds != null &&
                    ownerId != null &&
                    memberIds.contains(ownerId)) {
                    mapNoteUserIdsToShare.put(cdl.ContentDocumentId, ownerId);
                }
            }
            System.debug('mapNoteUserIdsToShare: ' + mapNoteUserIdsToShare);
        }

        if (!mapNoteUserIdsToShare.isEmpty()) {
            // Step 5: Instantiate a new instance of the ContentNoteSharingSettings Queueable class
            ContentNoteSharingSettings noteSharing = new ContentNoteSharingSettings(mapNoteUserIdsToShare);

            // Step 6: Enqueue the job for processing
            Id jobId = System.enqueueJob(noteSharing);
        }             
    }

}