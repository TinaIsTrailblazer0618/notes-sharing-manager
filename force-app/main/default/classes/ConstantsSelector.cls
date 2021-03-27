/**
 * @author Tina Chang
 * @name ConstantsSelector
 * @builtDate 8th July, 2020
 * @description Keeps and maintains all constants
**/
public with sharing class ConstantsSelector {

    public static final Id GROUP_ID_CEB = System.Label.Client_Employee_Benefits_Team_Members;
    public static final Id TEAM_LEAD_ID_CEB = System.Label.Client_Employee_Benefits_Team_Lead;
    public static final Id GROUP_ID_CIR = System.Label.Client_Incentives_Rewards_Team_Members;
    public static final Id TEAM_LEAD_ID_CIR = System.Label.Client_Incentives_Rewards_Team_Lead;
    public static final Id SALES_VP = System.Label.Sales_VP;
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
    public static final String TEST_PROFILE_CEB_LEAD = System.Label.Profile_CEB_Team_Lead;
    public static final String TEST_GROUP_NAME = System.Label.Group_Name_for_Apex_Test_Class;
    
}