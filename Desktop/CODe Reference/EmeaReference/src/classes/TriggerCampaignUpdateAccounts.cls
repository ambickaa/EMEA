public class TriggerCampaignUpdateAccounts implements Triggers.Handler
{
	public void handle()
	{
		Set<Id> aCampIds = new Set<Id>();
		for (sObject aCampaign: Trigger.new)
		{
			Campaign aNewCamp = (Campaign) aCampaign;
			Campaign anOldCamp = (Campaign) Trigger.oldMap.get(aNewCamp.Id);
			if (aNewCamp.StatusCode__c != anOldCamp.StatusCode__c)
			{
				aCampIds.add(aCampaign.Id);
			}
		}
		if (aCampIds.size() < 1)
		{
			return;
		}
		new AccountTriggerHelper.AccountBatchManager().updateFarmsByCampaigns(aCampIds);
	}
}