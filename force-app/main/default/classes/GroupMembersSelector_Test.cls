@IsTest
private class GroupMembersSelector_Test {

    static final String PROFILE_NAME = ConstantsSelector.TEST_PROFILE_CLIENT_SALES;
    static final String ROLE_NAME = 'BD_Sales';
    static final String LAST_NAME = 'GenericLastName'; 

    @TestSetup
    static void makeData() {
        Test.startTest();
        TestDataFactory.constructUser(PROFILE_NAME, ROLE_NAME, LAST_NAME); // It's a future method
        Test.stopTest();

        User u = [SELECT Id FROM User WHERE LastName = :LAST_NAME LIMIT 1];
        Group testGroup = TestDataFactory.constructPublicGroup(ConstantsSelector.TEST_GROUP_NAME, true);
        List<GroupMember> testMembers = TestDataFactory.constructPublicGroupMember(testGroup.Id, new Set<Id> { u.Id }, true);
    }

    @IsTest static void testSelectByGroupId() {   
        Group g = [SELECT Id FROM Group WHERE Name = :ConstantsSelector.TEST_GROUP_NAME];
        // Sanity check asserting that there is a group before executing the tested method.
        System.assert(g != null, 'You need a group to continue.');
        Test.startTest();
        List<Id> memberIds = new GroupMembersSelector().selectByGroupId(new Set<Id> { g.Id });
        Test.stopTest();
        System.assertEquals(1, memberIds.size(), 'Expected one member record to have returned');
    }
    
}