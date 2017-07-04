public class TriggerCampaignLineItemMarkCatalogAsUsed implements Triggers.Handler
{
	public void handle()
	{
		Set<Id>parentProductCatalogEntryIds = new Set<Id>();
		for(sObject s : trigger.new)
		{
			parentProductCatalogEntryIds.add((ID)s.get('ProductCatalogEntryRef__c'));
		}
		List<ProductCatalogEntry__c>productCatalogEntries = new List<ProductCatalogEntry__c>();
		for(ID productCatalogId : parentProductCatalogEntryIds)
		{
			if (productCatalogId != null)
			{
				productCatalogEntries.add(new ProductCatalogEntry__c(id = productCatalogId, isUsed__c = true));
			}
		}
		if(productCatalogEntries.size()>0)
		{
			update productCatalogEntries;
		}
	}
}