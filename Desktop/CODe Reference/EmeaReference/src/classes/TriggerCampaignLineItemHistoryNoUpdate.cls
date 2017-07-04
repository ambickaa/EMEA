public class TriggerCampaignLineItemHistoryNoUpdate implements Triggers.Handler
{
	public void handle()
	{
	//trigger beforeUpdate 
		
		CampaignLineItemHistory__c oldCampaignLineItemHistory;
		
		for (CampaignLineItemHistory__c aCampaignLineItemHistory : (List<CampaignLineItemHistory__c>)Trigger.new)
		{
			if (Trigger.isUpdate)
			{				
				oldCampaignLineItemHistory=(CampaignLineItemHistory__c)Trigger.oldMap.get(aCampaignLineItemHistory.id);
				
				if( oldCampaignLineItemHistory.AgreedCopy__c!=null || oldCampaignLineItemHistory.PreliminaryOrderRef_RSACopy__c!=null)
				{
					aCampaignLineItemHistory.AgreedCopy__c=oldCampaignLineItemHistory.AgreedCopy__c;
					aCampaignLineItemHistory.PreliminaryOrderRef_RSACopy__c=oldCampaignLineItemHistory.PreliminaryOrderRef_RSACopy__c;
				}
			
			} 
		}		
	}

}