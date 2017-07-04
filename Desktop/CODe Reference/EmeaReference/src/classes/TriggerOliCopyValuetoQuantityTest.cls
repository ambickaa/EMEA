@isTest( SeeAllData=true )
private class TriggerOliCopyValuetoQuantityTest
{

    static testMethod void basicTest()
    {
        update [SELECT ID FROM OpportunityLineItem LIMIT 1];
    }
}