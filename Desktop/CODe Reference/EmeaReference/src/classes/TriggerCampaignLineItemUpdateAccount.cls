public class TriggerCampaignLineItemUpdateAccount implements Triggers.Handler
{
	public static Boolean fromBatch =false;  
	
	public void handle()
	{
		if(!fromBatch)
		{
			Set<Id> anAccoutnIdSet = new Set<Id>();
			Set<Id>ordersIdSet = new Set<Id>();
			list<Order__c>ordersList = new list<Order__c>();
			List<CampaignLineItem__c> aCLIList = Trigger.isInsert 
					? (List<CampaignLineItem__c>)Trigger.new 
					: (List<CampaignLineItem__c>)Trigger.old;
			for (CampaignLineItem__c aCLI : aCLIList)
			{
					//Fix TEST
					if(aCLI.country__c!='South Africa' && aCLI.FarmRef__c != NULL) //As per CR-00000645, added aCLI.FarmRef__c != NULL in the condition to avoid System.QueryException: Non-selective query against large object type (more than 200000 rows).
						anAccoutnIdSet.add(aCLI.FarmRef__c);
					if (aCLI.PreliminaryOrderRef_RSA__c != null){
						ordersIdSet.add(aCLI.PreliminaryOrderRef_RSA__c);
					}
			}
			for (Id i:ordersIdSet){
				//ordersList.add(new Order__c(id=i, PdfSent_RSA__c = false)); Not makes sense
				ordersList.add(new Order__c(id=i));
			}
			
			if(anAccoutnIdSet.size()>0)
				new AccountTriggerHelper.AccountBatchManager().updateFarmsByCampaignLineItem(anAccoutnIdSet);
			update ordersList;
		}
		
	}
}