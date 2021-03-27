/** 
 * @author Tina Chang
 * @date July 13, 2020
 * @name GroupMembersSelector
 * @description Encapsulates logic responsible for querying information from GroupMember
 *  and avoids using the with sharing or without sharing keywords on Selector Apex classes 
 *  to ensure that the calling context inherits this context
**/
public with sharing class GroupMembersSelector {
    /**
     * @name selectByGroupId
     * @description Group member selector
     */    
    public List<Id> selectByGroupId(Set<Id> groupIds) {
        List<Id> memberIds = new List<Id>();
        // Get the Ids of the members
        for (GroupMember member : [SELECT UserOrGroupId 
                                    FROM GroupMember 
                                    WHERE GroupId IN :groupIds]) {
            memberIds.add(member.UserOrGroupId);
        }
        System.debug('memberIds: ' + memberIds);
        return memberIds;
    }
}