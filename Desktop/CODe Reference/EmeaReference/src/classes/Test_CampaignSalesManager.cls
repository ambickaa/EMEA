@isTest
private class Test_CampaignSalesManager
{
	private static final String USER_ID = '005D0000002EIDn';
	private static final String CAMPAIGN_SALES_RM_TEMPLEATE_ID = '00XM0000000HyKL';
	private static final String CAMPAIGN_SALES_SR_TEMPLEATE_ID = '00XM0000000HyKV';
	
	private static testMethod void testCampaignSalesManager() 
	{
		CampaignSalesManager manager;
		Campaign campaign;
		
		// select User record for testing
		User testUser = [SELECT ID, Country FROM User WHERE ID = :USER_ID];
		
		Test.startTest();
		// insert custom setting with existing template ID
		SystemSettings__c notificationSalesPmTemplateId = new SystemSettings__c(
			Name = CampaignSalesManager.CAMPAIGN_SALES_RM_TEMPLEATE,
			Value__c = CAMPAIGN_SALES_RM_TEMPLEATE_ID);
		insert notificationSalesPmTemplateId;
		
		// insert custom setting with existing template ID
		SystemSettings__c notificationSalesSmTemplateId = new SystemSettings__c(
			Name = CampaignSalesManager.CAMPAIGN_SALES_SR_TEMPLEATE,
			Value__c = CAMPAIGN_SALES_SR_TEMPLEATE_ID);
		insert notificationSalesSmTemplateId;
		
		Country__c aCountry = new Country__c(Name = testUser.Country);
		aCountry.OwnerId = testUser.Id;
		insert aCountry;
		System.debug('*** New Country: ' + aCountry);
		
		System.runAs(testUser)
		{
			// create and insert Campaign
			campaign = (Campaign) SmartFactory.createSObject('Campaign');
			campaign.TotalCampaignBudget__c = 15000;
			campaign.Name = 'Test Campaign';
			campaign.CountryRef__c = aCountry.Id;
			insert campaign;
			// System.assert(false, campaign);
			manager = new CampaignSalesManager(campaign.Id);
			
			manager.loadFullCampaignsList();
			
			List<Campaign> createdChildrenCampaigns = manager.childrenCampaigns;
			
			
			
			// add budget for each child Campaign
			Decimal totalChildrenBudget = 0;
			for (Campaign createdCampaign : createdChildrenCampaigns)
			{
				createdCampaign.TotalCampaignBudget__c = 
						campaign.TotalCampaignBudget__c / createdChildrenCampaigns.size();
				totalChildrenBudget += createdCampaign.TotalCampaignBudget__c;
				
			}
			if (campaign.TotalCampaignBudget__c != totalChildrenBudget)
			{
				createdChildrenCampaigns.get(createdChildrenCampaigns.size() - 1).TotalCampaignBudget__c += 
						(campaign.TotalCampaignBudget__c - totalChildrenBudget);
			}
			
			try
			{
				// save children campaigns
				manager.saveChildrenCampaign();
			} catch(Exception e)
			{
				System.assert(false, 'In current Campaign TotalCampaignBudget__c field should be equals ' + 
						' to the sum of TotalCampaignBudget__c field of children Campaign.');
			} 
			try
			{
				manager.notifyUsers();
			}catch (Exception e){}
		}
		
		// check that changes were successfully saved
		//System.assertEquals(true, manager.getIsAllocatedAndSaved());
		
		// change budget for parent campaign
		campaign.TotalAllocatedBudget__c = 22000;
		update campaign;
		
		manager.loadFullCampaignsList();
		
		Boolean isCatch;
		try
		{
			
			// save changes
			manager.saveChildrenCampaign();
		} catch (Exception e)
		{
			isCatch = true;
			// check that changes wasn't saved
			Decimal aTotalSum = 0;
			for (Campaign aCamp: manager.childrenCampaigns)
			{
				aTotalSum += aCamp.TotalCampaignBudget__c;
			}
			System.assertEquals(System.Label.ErrorCampaignSalesUnderlimit + 
					'(' + manager.getCurrentCampaign().TotalCampaignBudget__c +  '/' + aTotalSum + ')', 
					e.getMessage());
		}
		
		System.assert(true, isCatch);
		Test.stopTest();
	}
}