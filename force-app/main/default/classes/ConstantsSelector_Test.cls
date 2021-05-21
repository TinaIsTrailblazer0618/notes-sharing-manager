@IsTest
private class ConstantsSelector_Test {

    @IsTest static void assertConstants() {
        System.assertEquals('SNOTE', ConstantsSelector.FILE_TYPE_SNOTE, 'Incorrect note type name.');
        System.assertEquals('ClientEmployeeBenefits', ConstantsSelector.RECORD_TYPE_CEB, 'Incorrect record type dev name.');
        System.assertEquals('ClientIncentivesRewards', ConstantsSelector.RECORD_TYPE_CIR, 'Incorrect record type dev name.');
        System.assertEquals(Datetime.now().addDays(-10).date(), ConstantsSelector.NOTE_MODIFIED_START_DATE.date(), 
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
        System.assertEquals('Client Sales', ConstantsSelector.TEST_PROFILE_CLIENT_SALES, 'Incorrect test profile.');
        System.assertEquals('TestGroup_DoNotDelete', ConstantsSelector.TEST_GROUP_NAME, 'Incorrect group name.');
        System.assertEquals([SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, 
            ConstantsSelector.SYSTEM_ADMIN_PROFILE_ID, 'Incorrect Id.');
    }

}