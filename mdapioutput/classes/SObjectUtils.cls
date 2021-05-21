/**
 * @author Tina Chang
 * @date July 15, 2020
 * @name SObjectUtils
 * @description A utility class to help when dealing with SObjects.
 */
public with sharing class SObjectUtils {

    public static List<Schema.PicklistEntry> getPicklistValues(String typeName, String fieldName) {        
        Schema.DescribeSObjectResult result = getDescribeSObjectResult(typeName);
        Map<String, Schema.SObjectField> fields = result.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();   
        return pickListValues;
    }

    public static Map<Id, Schema.RecordTypeInfo> mapRecordTypeById(String typeName) {
        Schema.DescribeSObjectResult result = getDescribeSObjectResult(typeName);
        Map<Id, Schema.RecordTypeInfo> rtMapById = result.getRecordTypeInfosById();
        return rtMapById;
    }

    public static Map<String, Schema.RecordTypeInfo> mapRecordTypeByDeveloperName(String typeName) {
        Schema.DescribeSObjectResult result = getDescribeSObjectResult(typeName);
        Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName = result.getRecordTypeInfosByDeveloperName();
        return rtMapByDeveloperName;
    }

    public static String getRecordTypeIdByDeveloperName(String typeName, 
                                                        String recordTypeDeveloperName) {
        Schema.DescribeSObjectResult result = getDescribeSObjectResult(typeName);
        Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName = result.getRecordTypeInfosByDeveloperName();
        String recordTypeId = rtMapByDeveloperName.get(recordTypeDeveloperName).getRecordTypeId();
        return recordTypeId;     
    }

    public static String getSObjectKeyPrefix(String typeName){
        Schema.DescribeSObjectResult result = getDescribeSObjectResult(typeName);
        return (result.getKeyPrefix());
    }

    public static String generateGloballyUniqueUsernames() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String userName = uniqueName + '@edenred-tw' + orgId + '.org';
        return userName;        
    }

    public static String generateUserEmail() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String email = uniqueName + '@edenred-tw' + orgId + '.org';
        return email;        
    }

    /**
     * @name getDescribeSObjectResult
     * @description Helper Method
    **/    
    public static Schema.DescribeSObjectResult getDescribeSObjectResult(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult result = targetType.getDescribe();
        return result;
    }

}