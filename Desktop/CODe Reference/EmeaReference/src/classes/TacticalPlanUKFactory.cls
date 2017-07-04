public with sharing class TacticalPlanUKFactory extends TacticalPlanCountryFactory implements AccountListObjectFactory
{
	
	public AccountListObjectWrapper createAnEmptyRecord(String accountId)
	{
		
		CampaignLineItem cli = new CampaignLineItem();
    	cli.nextPeriodeElement = cli.deepClone();
    	if(Util.currentCampaign <> null)
    	{
    		cli.nextPeriodeElement.record.CampaignRef__c = Util.currentCampaign.id;
    	}
        return cli;
	}
	
	public List<AccountListObjectWrapper>createObjectWrapperForAccountId(String AccountId)
	{
		sortCampaignLineItemsAndCreateMapsFromIt();
		List<CampaignLineItem>result = new List<CampaignLineItem>();
		
		result.addAll(combine(prevCCampaignLineItems, nextCCampaignLineItems).values());
		result.addAll(combine(prevFOCCampaignLineItems, nextFOCCampaignLineItems).values());
		return result;
	}
	
	
	private Map<String, CampaignLineItem>combine(map<String, CampaignLineItem> prevCampaign, map<String, CampaignLineItem> nextCampaign)
	{
		Map<String, CampaignLineItem>result = new Map<String, CampaignLineItem>();
		for(String key : prevCampaign.keySet())
		{
			result.put(key, prevCampaign.get(key));
			if(nextCampaign.containsKey(key))
			{
				result.get(key).nextPeriodeElement = nextCampaign.get(key);
				nextCampaign.remove(key);
			}
			else
			{
				result.get(key).nextPeriodeElement = result.get(key).deepClone();
				if(nextCampaign.size()== 0)
				{
					result.get(key).nextPeriodeElement.record.Forecast__c = result.get(key).record.ForeCastPlusOne__c;
					result.get(key).nextPeriodeElement.record.ForeCastPlusOne__c = null;
					result.get(key).nextPeriodeElement.record.ForeCastLow__c = null;
				}
			}
		}
	
		for(String key : nextCampaign.keySet())
		{
			result.put(key, nextCampaign.get(key).deepClone());
			result.get(key).nextPeriodeElement = nextCampaign.get(key);
		}
		return result;
	}
	
}