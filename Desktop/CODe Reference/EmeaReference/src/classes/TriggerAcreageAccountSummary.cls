public with sharing class TriggerAcreageAccountSummary implements Triggers.Handler
{
	public void handle()
	{
		Set<Id> anAccounts = new Set<Id>();
		
		//Collect all the related accounts.
		for (sObject anAcreageObj: Trigger.isDelete? Trigger.old: Trigger.new)
		{
			Acreage__c anAcreage = (Acreage__c) anAcreageObj;
			if (anAcreage.AcrFarmRef__c != null)
			{
				anAccounts.add(anAcreage.AcrFarmRef__c);
			}
			if (Trigger.isUpdate)
			{
				Acreage__c anOldAcreage = (Acreage__c) Trigger.oldMap.get(anAcreage.Id);
				if (anOldAcreage.AcrFarmRef__c != null)
				{
					anAccounts.add(anOldAcreage.AcrFarmRef__c);
				}
			}
		}
		//Update account summary fields.
		AccountTriggerHelper.updateSummaryAcreages(anAccounts);
	}
}