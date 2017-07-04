/*
	
*/
@isTest
private class TriggerCampaignLineItemSummaryFieldsTest
{
	private static Campaign aCampaign;
	private static Account anAccount;
	
	static
	{
		aCampaign = new Campaign();
		insert aCampaign;
		anAccount = TestInit.createNewFarmer();
		insert anAccount;
	}
	
	private static testMethod void test()
	{
		Test.startTest();
		Map<String, Object> aCampaignItemFieldMap = new Map<String, Object>
		{
			'FarmRef__c' => anAccount.Id, 'CampaignRef__c' => aCampaign.Id
		};
		CampaignLineItem__c aCampaignLineItem = 
				(CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCampaignItemFieldMap);
		insert aCampaignLineItem;
		Test.stopTest();
	}
}