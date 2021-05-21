// * 1
Map<String, String> recFullNameWithLabelMap = new Map<String, String>();
Map<String, Map<String, Object>> recFullNameWithFieldValueMap = new Map<String, Map<String, Object>>();
Map<String, Object> feildValueMap = new Map<String, Object>();
Map<String, Object> feildValueMap2 = new Map<String, Object>();
Account acct;

feildValueMap.put('Active__c', true);
recFullNameWithLabelMap.put('Notes_Sharing_Group__mdt.TestGroup1', 'TestGroup1');
recFullNameWithFieldValueMap.put('Notes_Sharing_Group__mdt.TestGroup1', feildValueMap);

recFullNameWithLabelMap.put('Notes_Sharing_Group__mdt.TestGroup2', 'TestGroup2');
recFullNameWithFieldValueMap.put('Notes_Sharing_Group__mdt.TestGroup2', feildValueMap);

recFullNameWithLabelMap.put('Notes_Sharing_Group__mdt.TestGroup3', 'TestGroup3');
recFullNameWithFieldValueMap.put('Notes_Sharing_Group__mdt.TestGroup3', feildValueMap);
    
feildValueMap2.put('Entity__c', acct); // It won't update because SObject, here Account, is not one of the supported Apex primitive types. 
                                        // To solve the issue, use String. See exampe * 2.
feildValueMap2.put('Field_API_Name__c', 'StageNameTestAPIName');
recFullNameWithLabelMap.put('Field__mdt.StageNameTest', 'StageNameTestLabel');
recFullNameWithFieldValueMap.put('Field__mdt.StageNameTest', feildValueMap2);

// * 2
Map<String, String> recFullNameWithLabelMap = new Map<String, String>();
Map<String, Map<String, Object>> recFullNameWithFieldValueMap = new Map<String, Map<String, Object>>();
Map<String, Object> feildValueMap = new Map<String, Object>();
feildValueMap.put('Entity__c', 'Account'); // String works. 
feildValueMap.put('Field_API_Name__c', 'StageNameTestAPIName2');
recFullNameWithLabelMap.put('Field__mdt.StageNameTest2', 'StageNameTestLabel2');
recFullNameWithFieldValueMap.put('Field__mdt.StageNameTest2', feildValueMap);

CustomMetadataService cmdService = new CustomMetadataService();
cmdService.createAndUpdateMetadata(recFullNameWithLabelMap, recFullNameWithFieldValueMap);

// * 3
Map<String, String> recFullNameWithLabelMap = new Map<String, String>();
Map<String, Map<String, Object>> recFullNameWithFieldValueMap = new Map<String, Map<String, Object>>();
Map<String, Object> feildValueMap = new Map<String, Object>();
feildValueMap.put('Entity__c', 'Account'); // String works. 
feildValueMap.put('Field_API_Name__c', 'StageNameTestAPIName');
recFullNameWithLabelMap.put('Field__mdt.StageNameTest', 'StageNameTestLabel');
recFullNameWithFieldValueMap.put('Field__mdt.StageNameTest', feildValueMap);

CustomMetadataService cmdService = new CustomMetadataService();
cmdService.createAndUpdateMetadataComponents(recFullNameWithLabelMap, recFullNameWithFieldValueMap); 

// * 4
// sObject types to describe
String[] types = new String[]{'PermissionSet'};
 
// Make the describe call
Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
 
System.debug('Got describe information for ' + results.size() + ' sObjects.');

// For each returned result, get some info
for(Schema.DescribeSobjectResult res : results) {
    System.debug('sObject Label: ' + res.getLabel());
    System.debug('Number of fields: ' + res.fields.getMap().size());
    System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
    System.debug('fields: ' + res.fields.getMap().keySet());
}

String prefix1 = Account.sObjectType.getDescribe().getKeyPrefix();
System.debug('Account prefix: ' + prefix1);

String prefix2 = DeployResult.sObjectType.getDescribe().getKeyPrefix(); // DeployResult is not an sObject
System.debug('DeployRequest prefix: ' + prefix2);

// * 5
String body;
Map<Id, ContentNote> cnMap;
List<ContentVersion> cvLst;
List<ContentVersion> cvToUpdate;
TestDataFactory.constructContentNotesOfUser(1, UserInfo.getUserId(), true);
cnMap = new Map<Id, ContentNote>([SELECT Id FROM ContentNote
                                    AND OwnerId = :UserInfo.getUserId()]);
cvLst = [SELECT Id, VersionData FROM ContentVersion
        WHERE ContentDocumentId = :cnMap.keySet()
        AND IsLatest = TRUE];
body = 'Updated Unit Test Note Body';
cvToUpdate = new List<ContentVersion>();
for (ContentVersion cv : cvLst) {
    cv.VersionData = Blob.valueOf(body.escapeHtml4());
    cvToUpdate.add(cv);
}
update cvToUpdate;

for (ContentVersion cv : cvToUpdate) {
    String checkContenVersion = cv.VersionData.toString();
    System.debug('checkContenVersion: ' + checkContenVersion);
}  

// * 6
System.debug(Account.Industry.getDescribe().getPicklistValues());
System.debug(Account.Industry.getDescribe().getPicklistValues()[0].getLabel());
System.debug(Account.Industry.getDescribe().getPicklistValues()[1].getLabel());
System.debug(Account.Region__c.getDescribe().getPicklistValues()[1].getLabel());