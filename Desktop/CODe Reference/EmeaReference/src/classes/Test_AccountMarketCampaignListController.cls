/*
	@description Test create, edit and delete CampaignLineItem records
*/
@isTest
private class Test_AccountMarketCampaignListController
{
	
	/*
		@description Initialize URL parameters and required records for test.
	*/
	private static void init()
	{
		TestInit.createAccountListController();
		
		TestInit.contacts[0].AccountId = TestInit.accountWrapper.accountRecord.Id;
		update TestInit.contacts[0];
		
		CampaignMember aCampaignM = new CampaignMember(CampaignId = TestInit.accountWrapper.campaignRecord.id, ContactId = TestInit.contacts[0].Id);
		insert aCampaignM;
		
		PageReference aPage = Page.AccountViewDefault;
		aPage.getParameters().put('Id', TestInit.accountWrapper.accountRecord.Id);
		aPage.getParameters().put('division', TestInit.accountWrapper.campaignRecord.DivisionRef__c);
		Test.setCurrentPageReference(aPage);
	}
	
	/*
		@description Test select from database Campaign records
	*/
	private static testMethod void testAccountMarketingCampaignController()
	{
		init();
		
		Test.startTest();
		AccountMarketingCampaignListController aController = new AccountMarketingCampaignListController();
		System.assertEquals(1, aController.getCampaigns().size(), 'Size of list Campaign should be 1.');
		System.assertEquals(TestInit.accountWrapper.campaignRecord.Id, aController.getCampaigns()[0].record.Id, 'Selected Campaign record is incorrect.');
		Test.stopTest();
	}
}