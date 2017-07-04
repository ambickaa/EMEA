public with sharing class TriggerCountryHandler implements Triggers.Handler
{
	public void handle()
	{
		List<Country__c> aCountryList = new List<Country__c>();
		
		for (Id anId : Trigger.newMap.keySet())
		{
			aCountryList.add(new Country__c(Id = anId));
		}
		update aCountryList;
	}
}