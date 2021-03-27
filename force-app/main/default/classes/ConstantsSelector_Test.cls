@isTest
private class ConstantsSelector_Test {

    @isTest static void assertConstants() {
        System.assertEquals('00G2x000000IwW9EAK', ConstantsSelector.GROUP_ID_CEB, 'Incorrect Id.');
        System.assertEquals('00528000005Geu7AAC', ConstantsSelector.TEAM_LEAD_ID_CEB, 'Incorrect Id.');
        System.assertEquals('00G2x000000Iy4eEAC', ConstantsSelector.GROUP_ID_CIR, 'Incorrect Id.');
        System.assertEquals('0050K00000A72yfQAB', ConstantsSelector.TEAM_LEAD_ID_CIR, 'Incorrect Id.');
        System.assertEquals('00528000002VP7YAAW', ConstantsSelector.SALES_VP, 'Incorrect Id.');
        System.assertEquals('SNOTE', ConstantsSelector.FILE_TYPE_SNOTE, 'Incorrect note type name.');
        System.assertEquals('ClientEmployeeBenefits', ConstantsSelector.RECORD_TYPE_CEB, 'Incorrect record type dev name.');
        System.assertEquals('ClientIncentivesRewards', ConstantsSelector.RECORD_TYPE_CIR, 'Incorrect record type dev name.');
        System.assertEquals(Datetime.now().addDays(-10), ConstantsSelector.NOTE_MODIFIED_START_DATE, 
            'Note modified start date should be 10 days ago.');
        System.assertEquals(Datetime.now(), ConstantsSelector.NOTE_MODIFIED_END_DATE,
            'Note modified end date should be today.');
        System.assertEquals('0122x000000DbcmAAC', ConstantsSelector.RT_ID_OPP_CEB, 'Incorrect Id.');
        System.assertEquals('0122x000000DbcnAAC', ConstantsSelector.RT_ID_OPP_CIR, 'Incorrect Id.');
        System.assertEquals('006', ConstantsSelector.OPPORTUNITY_PREFIX, 'Incorrect prefix.');
        System.assertEquals('TestAcc', ConstantsSelector.TEST_ACC_NAME, 'Incorrect test acc name.');
        System.assertEquals('TestOpp - YearEndBonus', ConstantsSelector.TEST_OPP_NAME_CEB, 'Incorrect test opp name.');
        System.assertEquals('TestContentVersion' + Date.today(), ConstantsSelector.TEST_CONTENT_VERSION_TITLE, 'Incorrect test version name.');
        System.assertEquals('TestContentNote' + Date.today(), ConstantsSelector.TEST_CONTENT_NOTE_TITLE, 'Incorrect test note name.');
        System.assertEquals('Client Sales', ConstantsSelector.TEST_PROFILE_CEB_LEAD, 'Incorrect test username.');
        System.assertEquals('TestGroup4UAT_DoNotDelete', ConstantsSelector.TEST_GROUP_NAME, 'Incorrect group name.');
    }

}