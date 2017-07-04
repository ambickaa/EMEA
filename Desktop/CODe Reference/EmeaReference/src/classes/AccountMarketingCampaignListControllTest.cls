public with sharing class AccountMarketingCampaignListControllTest
{
    static
    {
        MixedDMLOps.add( Testinit.farmers );
        MixedDMLOps.ins();
        Testinit.getDivision('Corn');
        TestInit.setYear( 1 );
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }

    static testMethod void basicTest()
    {
    	AccountMarketingCampaignListController controller = new AccountMarketingCampaignListController();
        TestAccountListInterface.basicTest( new AccountMarketingCampaignListController() );
        controller.getCampaigns();
    }
}