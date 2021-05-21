/**
 * @author Tina Chang
 * @name TestDataFactory
 * @builtDate 8th July, 2020
 * @description Contains methods to construct and/or validate commonly used records
**/
@IsTest
public class TestDataFactory {

    /**
     * @name constructContentVersionsOfGroupMembers
     * @description Constructs a list of ContentVersion records for unit tests
     * @params Integer cnt, Id groupId, Boolean doInsert
    **/
    public static List<ContentVersion> constructContentVersionsOfGroupMembers(Integer cnt, Id groupId, Boolean doInsert) {
        // This method returns a list, of size cnt, of uniquely named ContentVersion records
        //  with all the required fields populated
        //  and ContentVersion owner set to specified user - here is team member
        List<Id> memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { groupId });
        List<ContentVersion> versionList = new List<ContentVersion>();
        Id userId = memberIds[0];
        List<Opportunity> opps = constructOpportunities(1, 1, 'Qualification', ConstantsSelector.RECORD_TYPE_CEB, true);
        for (Integer i = 0; i < cnt; i++) {
            versionList.add(new ContentVersion(OwnerId = userId,
                                                FirstPublishLocationId = opps[0].Id,
                                                Title = ConstantsSelector.TEST_CONTENT_VERSION_TITLE + i,
                                                VersionData = EncodingUtil.base64Decode('Unit Test File Body'),
                                                PathOnClient = 'Test'));                                    
        }
        if (doInsert) {
            insert versionList;
        }               
        return versionList;
    }

    /**
     * @name constructContentNotesOfGroupMembers
     * @description Constructs a list of ContentNote records for unit tests
     * @params Integer cnt, Id groupId, Boolean doInsert
    **/
    public static List<ContentNote> constructContentNotesOfGroupMembers(Integer cnt, Id groupId, Boolean doInsert) {
        // This method returns a list, of size cnt, of uniquely named ContentNote records
        //  with all the required fields populated
        //  and note owner set to specified users - here is group members
        //  and iterating through the member values throughout the list
        List<Id> memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { groupId });
        List<ContentNote> noteList = new List<ContentNote>();
        String body = 'Unit Test Note Body';
        for (Integer i = 0; i < cnt; i++) {
            noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE + i,
                                        OwnerId = memberIds[math.mod(i, memberIds.size())],
                                        Content = Blob.valueOf(body.escapeHtml4())));                             
        }
        if (doInsert) {
            insert noteList;
        }        
        return noteList;
    }

    /**
     * @name constructContentNotesOfUser
     * @description Constructs a list of ContentNote records for unit tests
     * @params Integer cnt, Id userId, Boolean doInsert
    **/
    public static List<ContentNote> constructContentNotesOfUser(Integer cnt, Id userId, Boolean doInsert) {
        // This method returns a list, of size cnt, of uniquely named ContentNote records
        //  with all the required fields populated
        //  and note owner set to specified user - here is team lead
        List<ContentNote> noteList = new List<ContentNote>();
        String body = 'Unit Test Note Body';
        for (Integer i = 0; i < cnt; i++) {
            noteList.add(new ContentNote(Title = ConstantsSelector.TEST_CONTENT_NOTE_TITLE + i,
                                        OwnerId = userId,
                                        Content = Blob.valueOf(body.escapeHTML4())));                               
        }
        if (doInsert) {
            insert noteList;
            System.debug('***TestDataFactory*** noteList size: ' + noteList.size());
        }       
        return noteList;
    }

    /**
     * @name contentDocumentLinkedToCurrentUser
     * @description Constructs a list of ContentDocumentLink records for unit tests
     * @params List<SObject> contentDoclst, Boolean doInsert
    **/
    public static List<ContentDocumentLink> contentDocumentLinkedToCurrentUser(List<SObject> contentDoclst, 
                                                                                Boolean doInsert) {
        // This method returns a corresponding list of ContentDocumentLink records
        //  related to the provided SObjects
        //  with all the required fields populated
        //  and ShareType = V
        //  and LinkedEntityId set to the current user
        //  therefore the test note records are directly shared with the current user that runs this unit test
        //  and can appear/return in SOQL for the current user to verify the assertion in test classes

        // Validate input
        System.assert(contentDoclst != null, 'Expected to receive at least one ContentDocument');
        System.assert(contentDoclst.size() > 0, 'Expected to receive at least one ContentDocument');

        Schema.SObjectType token = contentDoclst[0].Id.getSObjectType();
        String objName = token.getDescribe().getName();
        Set<Id> objIds = (new Map<Id, SObject>(contentDoclst)).keySet();
        List<Id> objIdLst = new List<Id>(objIds);
        // If it's content version, get content document Id 
        if (objName == 'ContentVersion') {
            objIdLst = new List<Id>();
            for (ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :objIds]) {
                objIdLst.add(cv.ContentDocumentId);        
            }            
        }
        // Create ContentDocumentLinks
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for (Integer i = 0; i < objIdLst.size(); i++) {
            cdlList.add(new ContentDocumentLink(ContentDocumentId = objIdLst[i],
                                                LinkedEntityId = UserInfo.getUserId(),
                                                ShareType = 'V',
                                                Visibility = 'AllUsers'));
        }
        if (doInsert) {
            insert cdlList;
        }         
        return cdlList;
    }

    /**
     * @name contentDocumentLinkedToSObject
     * @description Constructs a list of ContentDocumentLink records 
     *  and relates to provided Opportunities and ContentNotes for unit tests
     * @params List<SObject> linkedEntityLst, List<SObject> contentDoclst, Boolean doInsert
    **/    
    public static List<ContentDocumentLink> contentDocumentLinkedToSObject(List<SObject> linkedEntityLst, 
                                                                            List<SObject> contentDoclst, 
                                                                            Boolean doInsert) {
        // Validate input
        System.assert(linkedEntityLst != null, 'Expected to receive at least one linkedEntity');
        System.assert(linkedEntityLst.size() > 0, 'Expected to receive at least one linkedEntity');
        System.assert(contentDoclst != null, 'Expected to receive at least one ContentDocument');
        System.assert(contentDoclst.size() > 0, 'Expected to receive at least one ContentDocument');
                                                                       
        Set<Id> linkedEntityIds = (new Map<Id, SObject>(linkedEntityLst)).keySet();
        Set<Id> contentDocIds = (new Map<Id, SObject>(contentDoclst)).keySet();
        List<Id> leIdLst = new List<Id>(linkedEntityIds);
        List<Id> cdIdLst = new List<Id>(contentDocIds);                                                                                             
        // For every link entity created, there is at lease one content document related to it
        List<ContentDocumentLink> cdlLst = new List<ContentDocumentLink>();
        for (Integer i = 0; i < leIdLst.size(); i++) {
            for (Integer j = 0; j < cdIdLst.size(); j++) {
                cdlLst.add(new ContentDocumentLink(ContentDocumentId = cdIdLst[j],
                                                    LinkedEntityId = leIdLst[i],
                                                    ShareType = 'V',
                                                    Visibility = 'AllUsers'));
            }
        }
        if (doInsert) {
            insert cdlLst;
        }
        return cdlLst;
    }

    /**
     * @name constructAccounts
     * @description Inserts Accounts with specified name
     * @params Integer cnt, String accName, Boolean doInsert
    **/
    public static List<Account> constructAccounts(Integer cnt, String accName, Boolean doInsert) {
        List<Account> accLst = new List<Account>();
        for (Integer i = 0; i < cnt; i++) {
            Account acc = new Account();
            acc.Name = accName + i;
            acc.Account_Name_English__c = accName + i;
            acc.Industry = SObjectUtils.getPicklistValues('Account', 'Industry')[0].getValue();
            acc.Region__c = SObjectUtils.getPicklistValues('Account', 'Region__c')[0].getValue();
            acc.NumberOfEmployees = 500;
            acc.Account_Classification__c = 
                SObjectUtils.getPicklistValues('Account', 'Account_Classification__c')[0].getValue();
            accLst.add(acc);            
        }
        if (doInsert) {
            insert accLst;
        }
        return accLst;
    }

    /**
     * @name constructOpportunities
     * @description Inserts Opportunities with specified stage and record type
     * @params Integer numAcc, Integer numOpp, String stageName, String recordType, Boolean doInsert
    **/
    public static List<Opportunity> constructOpportunities(Integer numAcc,
                                                            Integer numOpp,
                                                            String stageName, 
                                                            String recordType, 
                                                            Boolean doInsert) {
        List<Opportunity> oppLst = new List<Opportunity>();
        List<Account> accLst = constructAccounts(numAcc, ConstantsSelector.TEST_ACC_NAME, true);
        for (Integer i = 0; i < accLst.size(); i++) {
            Account acc = accLst[i];            
            for (Integer j = 0; j < numOpp; j++) {
                Opportunity opp = new Opportunity();
                opp.Name = ConstantsSelector.TEST_OPP_NAME_CEB + j + String.valueOf(i);
                opp.StageName = stageName;
                opp.CloseDate = Date.today().addMonths(6);
                opp.AccountId = acc.Id;
                opp.RecordTypeId = SObjectUtils.getRecordTypeIdByDeveloperName('Opportunity', recordType);
                oppLst.add(opp);
            }
        }
        if (doInsert) {
            insert oppLst;
        }
        return oppLst;
    }

    /**
     * @name constructUser
     * @description Inserts User with specified profile and role
     * @params String profileName, String roleName, String lastName
    **/
    @future
    public static void constructUser(String profileName, String roleName, String lastName) {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :roleName].Id,
            FirstName = 'TestUser',
            LastName = lastName,
            Email = SObjectUtils.generateUserEmail(),
            Username = SObjectUtils.generateGloballyUniqueUsernames(),
            CompanyName = 'Edenred Taiwan',
            Title = 'Sales Manager',
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
    }
    
    /**
     * @name constructPublicGroup
     * @description Inserts standard public group
     * @params Boolean doInsert
    **/
    public static Group constructPublicGroup(String groupName, Boolean doInsert) {
        Group testGroup = new Group(
            Name = groupName,
            Type = 'Regular'
        );
        if (doInsert) {
            insert testGroup;
        }
        return testGroup;
    }

    /**
     * @name constructPublicGroupMember
     * @description Inserts member(s) of a public group
     * @params Id groupId, Set<Id> userIds, Boolean doInsert
    **/
    public static List<GroupMember> constructPublicGroupMember(Id groupId, Set<Id> userIds, Boolean doInsert) {
        // Validate input
        System.assert(userIds != null, 'Expected to receive at least one user Id');
        System.assert(userIds.size() > 0, 'Expected to receive at least one user Id');
        
        List<GroupMember> members = new List<GroupMember>();
        for (Id userId : userIds) {
            GroupMember testMember = new GroupMember(
                GroupId = groupId,
                UserOrGroupId = userId
            );
            members.add(testMember);
        }
        if (doInsert) {
            insert members;
        }
        return members;  
    }

    /**
     * @name insertTestDataForOppNotes
     * @description Inserts Opportunities, ContentNotes, ContentDocumentLinks
     * @params Integer numNote, Integer numAcc, Integer numOpp, String stageName, String recordType, Boolean doInsert
    **/
    public static void insertTestDataForOppNotes(Integer numNote,
                                                Integer numAcc,
                                                Integer numOpp,
                                                String stageName, 
                                                String recordType, 
                                                Boolean doInsert) {
        // Constructs a list of ContentNote records 
        //  and relates to provided Opportunities for use as test data
        List<ContentNote> notes = constructContentNotesOfUser(numNote, UserInfo.getUserId(), doInsert);

        List<Opportunity> opps = constructOpportunities(numAcc, numOpp, stageName, recordType, doInsert);

        contentDocumentLinkedToSObject(opps, notes, doInsert);
    }

}