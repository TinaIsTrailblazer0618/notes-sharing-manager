public without sharing class ContentDocumentLinkHelper {
    /**
     * @name checkIfNotesShouldShareWithManagers
     * @date May, 2021
     * @description Helper method to decide whether to share the note with other users.
     *  Depending on the note owner,
     *  if the note owner is one of the group members defined in the Notes Sharing Group 
     *  custom metadata type, the note owner will share his/her notes 
     *  with immediate manager (and manager + 1 if exists).
     *  
     *  Process Steps:
     *  1. An admin user would create public groups for different teams/departments. 
     *  2. To extend a public group to a notes sharing participating group as an add-on, 
     *  an admin user would create Notes Sharing Group mdt records 
     *  with the same name of the public group.
     *  These metadata group records are considered 'notes sharing participating groups'.
     *  In other words, we use Notes Sharing Group mdt to manage (create, activate, deactivate) 
     *  notes sharing for public groups.
     *  3. Members in public groups from step 1 that match Notes Sharing Group mdt records 
     *  from step 2 will share their notes with their immediate manager & manager + 1.
     */
    public void checkIfNotesShouldShareWithManagers(List<ContentDocumentLink> cdls) {
        Set<Id> docIds = new Set<Id>();
        Map<Id, Id> mapDocToOwner = new Map<Id, Id>();
        Map<Id, String> mapDocToFileType = new Map<Id, String>();
        List<String> groupDevNames = new List<String>();
        Set<Id> memberIds;
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

        // Step 1: Query for active Notes Sharing Group mdt records
        List<Notes_Sharing_Group__mdt> notesSharingGroups = [SELECT DeveloperName, 
                                                                    Active__c 
                                                            FROM Notes_Sharing_Group__mdt
                                                            WITH SECURITY_ENFORCED];    
        for (Notes_Sharing_Group__mdt notesSharingGroup : notesSharingGroups) {
            if (notesSharingGroup.Active__c) {
                groupDevNames.add(notesSharingGroup.DeveloperName);
            }
        }

        // Steps 2 & 3: See method
        if (!Test.isRunningTest()) {
            memberIds = findMatchingPublicGroupsAndMembers(groupDevNames);
        } else {
            memberIds = findMatchingPublicGroupsAndMembers(
                new List<String> { ConstantsSelector.TEST_GROUP_NAME }
            );
        }

        // Step 4: Determine if the note needs to be shared with the note owner's managers
        for (ContentDocumentLink cdl : cdls) {
            Id ownerId = mapDocToOwner.get(cdl.ContentDocumentId);
            String fileType = mapDocToFileType.get(cdl.ContentDocumentId);
            if (fileType == ConstantsSelector.FILE_TYPE_SNOTE &&
                memberIds != null &&
                ownerId != null &&
                memberIds.contains(ownerId)) {
                mapNoteUserIdsToShare.put(cdl.ContentDocumentId, ownerId);
            }
        }

        if (!mapNoteUserIdsToShare.isEmpty()) {
            // Step 5: Instantiate a new instance of the ContentNoteSharingSettings Queueable class
            ContentNoteSharingSettings noteSharing = new ContentNoteSharingSettings(mapNoteUserIdsToShare);

            // Step 6: Enqueue the job for processing
            Id jobId = System.enqueueJob(noteSharing);
        }             
    }

    private Set<Id> findMatchingPublicGroupsAndMembers(List<String> metadataRecDevNames) {
        Set<Id> groupIds = new Set<Id>();
        Set<Id> memberIds;
        // Step 2: Get the Ids of the note sharing participating groups
        for (Group gr : [SELECT Id 
                        FROM Group 
                        WHERE DeveloperName 
                        IN :metadataRecDevNames]) {
            groupIds.add(gr.Id);
        }

        // Step 3: Get the Ids of the note sharing participating members
        List<Id> memberIdList = new GroupMembersSelector().selectByGroupId(groupIds);
        memberIds = new Set<Id>(memberIdList);
        return memberIds;
    }

}