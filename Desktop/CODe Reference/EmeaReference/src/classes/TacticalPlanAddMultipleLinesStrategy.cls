public class TacticalPlanAddMultipleLinesStrategy implements AccountaddMultipleLinesStrategy
{
	private List<CampaignLineItem>temporaryCampaignLineItems {get; set;}
	
	
	
	
	
	public TacticalPlanAddMultipleLinesStrategy()
	{
		temporaryCampaignLineItems = new List<CampaignLineItem>();
		
		for(ProductCatalogEntry__c pce : [SELECT ID, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c = :Util.currentCampaign.SalesPCMRef__c])
		{
			temporaryCampaignLineItems.add(new CampaignLineItem(new CampaignLineItem__c(CampaignRef__c = Util.currentCampaign.id, FarmRef__c = Util.currentAccount.id, ProductRef__c = pce.ProductRef__c, Type__c = 'Charged', DistributorRef__c = Util.currentAccount.PrimaryDistributor__c, PoS__c = Util.currentAccount.PrimaryPoS__c)));
			temporaryCampaignLineItems.add(new CampaignLineItem(new CampaignLineItem__c(CampaignRef__c = Util.currentCampaign.id, FarmRef__c = Util.currentAccount.id, ProductRef__c = pce.ProductRef__c, Type__c = 'Free of charge', DistributorRef__c = Util.currentAccount.PrimaryDistributor__c, PoS__c = Util.currentAccount.PrimaryPoS__c)));
		}
	}
	
	
	
	public List<CampaignLineItem> getTemporaryCampaignLineItems()
	{
		return temporaryCampaignLineItems;
	}
	
	
	
	public PageReference save()
	{
		List<CampaignLineItem__c>cliForDB = new List<CampaignLineItem__c>();
		for(CampaignLineItem c : temporaryCampaignLineItems)
		{
			if(c.record.Agreed__c <> null || c.record.Forecast__c <> null || c.record.PoG__c <> null)
			{
				cliForDB.add(c.record);
			}
		}
		
		if(cliForDB.size()>0)
		{
			insert cliForDB;
		}
		return URLx.setURL('/'+Util.currentAccount.id);
	}
}