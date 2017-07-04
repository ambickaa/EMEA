@isTest( SeeAllData=true )
private class TriggerCampaignUpdateAmountTest
{

    static testMethod void basicTest()
    {
        update [SELECT ID FROM Campaign LIMIT 1];
    }
}