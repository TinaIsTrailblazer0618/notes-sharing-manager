@isTest
private class SObjectUtils_Test {

    static String objType = 'Opportunity';
    static String rtDevName = ConstantsSelector.RECORD_TYPE_CEB;
    static String orgId = UserInfo.getOrganizationId();

    @isTest static void testMapRecTypeById() {
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = :objType LIMIT 1];
        Map<Id, Schema.RecordTypeInfo> rtMapById = SObjectUtils.mapRecordTypeById(objType);
        Schema.RecordTypeInfo rtById =  rtMapById.get(rt.Id);
        System.assertEquals(rtById.getDeveloperName(), rt.DeveloperName, 'Record type incorrect!');
    }

    @isTest static void testMapRecTypeByDevName() {
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = :objType LIMIT 1];
        Map<String, Schema.RecordTypeInfo> rtMapByDevName = SObjectUtils.mapRecordTypeByDeveloperName(objType);
        Schema.RecordTypeInfo rtByDevName = rtMapByDevName.get(rt.DeveloperName);
        System.assertEquals(rtByDevName.getRecordTypeId(), rt.Id, 'Record type incorrect!');
    }

    @isTest static void testGetRecTypeIdByDevName() {
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType 
                                                        WHERE SObjectType = :objType 
                                                        AND DeveloperName = :rtDevName LIMIT 1];
        String recordTypeId = SObjectUtils.getRecordTypeIdByDeveloperName(objType, rtDevName);
        System.assertEquals(recordTypeId, rt.Id, 'Record type incorrect!');
    }

    @isTest static void testGetSObjectKeyPrefix() {
        String oppPrefix = SObjectUtils.getSObjectKeyPrefix(objType);
        System.assertEquals('006', oppPrefix, 'Opportunity prefix should be 006.');
    }

    @isTest static void testGenerateUniqueUsernames() {
        String userName = SObjectUtils.generateGloballyUniqueUsernames();
        System.assert(userName.contains('@edenred-tw' + orgId + '.org'), 
        'Username should contain ' + '@edenred-tw' + orgId + '.org');
    }

    @isTest static void testGenerateUserEmail() {
        String email = SObjectUtils.generateUserEmail();
        System.assert(email.contains('@edenred-tw' + orgId + '.org'), 
        'Email should contain ' + '@edenred-tw' + orgId + '.org');
    }

}