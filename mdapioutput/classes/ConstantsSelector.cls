/**
 * @author Tina Chang
 * @name ConstantsSelector
 * @builtDate 8th July, 2020
 * @description Keeps and maintains all constants
**/
public with sharing class ConstantsSelector {

    public static final String FILE_TYPE_SNOTE = 'SNOTE';
    public static final String RECORD_TYPE_CEB = System.Label.Record_Type_Client_Employee_Benefits;
    public static final String RECORD_TYPE_CIR = System.Label.Record_Type_Client_Incentives_Rewards;
    public static final Id RT_ID_OPP_CEB = SObjectUtils.getRecordTypeIdByDeveloperName('Opportunity', RECORD_TYPE_CEB);
    public static final Id RT_ID_OPP_CIR = SObjectUtils.getRecordTypeIdByDeveloperName('Opportunity', RECORD_TYPE_CIR);
    public static final String OPPORTUNITY_PREFIX = SObjectUtils.getSObjectKeyPrefix('Opportunity');
    public static final Datetime NOTE_MODIFIED_START_DATE = Datetime.now().addDays(-10);
    public static final Datetime NOTE_MODIFIED_END_DATE = Datetime.now();
    public static final String TEST_ACC_NAME = 'TestAcc';
    public static final String TEST_OPP_NAME_CEB = 'TestOpp - YearEndBonus';
    public static final String TEST_CONTENT_VERSION_TITLE = 'TestContentVersion' + Date.today();
    public static final String TEST_CONTENT_NOTE_TITLE = 'TestContentNote' + Date.today();
    public static final String TEST_PROFILE_CLIENT_SALES = System.Label.Profile_Client_Sales;
    public static final String TEST_GROUP_NAME = System.Label.Group_Name_for_Apex_Test_Class;
    public static final Id SYSTEM_ADMIN_PROFILE_ID = 
        [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    
}