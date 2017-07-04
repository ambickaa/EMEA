public with sharing class TriggerCampaignLineItemAgreedCopy implements Triggers.Handler{
    

    public TriggerCampaignLineItemAgreedCopy ()
    {
    	
    }
     
    public void handle()
    { 
        if(trigger.isInsert)
        {
        	for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)Trigger.new)
        	{
        		if(cli.PreliminaryOrderRef_RSA__c!=null)
        		{
        			cli.AgreedCopy__c=cli.Agreed__c;
        		}
        	}
         
        }
        else if(trigger.isUpdate)      
        {

        	for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)Trigger.new)
        	{
        		if(cli.PreliminaryOrderRef_RSA__c!=null && cli.AgreedCopy__c==null)
        		{
        			cli.AgreedCopy__c=cli.Agreed__c;
        		}
        		
        	}
        }
	}
}