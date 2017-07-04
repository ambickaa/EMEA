/**
* Perform summary field actions for account and campaign
*/
public class TriggerCampaignLineItemSummaryFields implements Triggers.Handler
{
    public static Boolean fromBatch =false;
    
    public void handle()
    {
        if(!fromBatch)
        {
			Set<Id> anAccounts = new Set<Id>();
			Set<Id> aCampaigns = new Set<Id>();
			
			//Collect all the related account and Campaigns.
			for (sObject aCLIObj : Trigger.isDelete ? Trigger.old : Trigger.new)
			{
				CampaignLineItem__c aCLI = (CampaignLineItem__c)aCLIObj;
				if (aCLI.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales'))
				{
					if (aCLI.FarmRef__c != null)
					{
						if(aCLI.country__c!='South Africa')
							anAccounts.add(aCLI.FarmRef__c);
					}
					if (aCLI.CampaignRef__c != null)
					{
						aCampaigns.add(aCLI.CampaignRef__c);
					}
					if (Trigger.isUpdate)
					{
						CampaignLineItem__c anOldCLI = (CampaignLineItem__c) Trigger.oldMap.get(aCLI.Id);
						if (anOldCLI.FarmRef__c != null)
						{
							if(anOldCLI.country__c!='South Africa')
								anAccounts.add(anOldCLI.FarmRef__c);
						}
						if (anOldCLI.CampaignRef__c != null)
						{
							aCampaigns.add(anOldCLI.CampaignRef__c);
						}
					}
				}
			}
			//Update account summary fields. // Remove for RSA
			
			AccountTriggerHelper.updateSummaryCampaignLineItem(anAccounts);
			
			//Update Campaign summary fields.
			CampaignTriggerHelper.updateCLIFields(aCampaigns);
		}
	   }
}