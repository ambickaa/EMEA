@isTest
private class TriggerOpportunityLinkToCampaignTest
{

    static testMethod void basicTest()
    {
        MixedDMLOps.ins( TestInit.farmers );
        Opportunity o = new Opportunity( AccountId = TestInit.farmers.get( 0 ).id, stageName = 'Open', CloseDate= Date.today(), name = 'ABC' );
        try
        {
            insert o;
        }
        catch(Exception e) {}
        try
        {
            upsert o;
        }
        catch(Exception e) {}

    }
}