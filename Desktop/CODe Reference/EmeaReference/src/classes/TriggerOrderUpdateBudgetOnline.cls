public with sharing class TriggerOrderUpdateBudgetOnline implements Triggers.Handler{
	
	public static Boolean fromREST=false;	
	
	public void handle()
	{		
		if(!fromREST)
		{		
			List<ID> Owners = new List<ID>();
			List<ID> OrderIds = new List<ID>();	
			List<Id> ProductIds = new List<ID>();	
					
					
	        if(trigger.isUpdate)
	        {
	        	
	        	for(Order__c ord : (List<Order__C>)trigger.new)
				{
					Owners.add(ord.OwnerId);
					OrderIds.add(ord.id);
				}
				
				for(CampaignLineItem__c cli : [ SELECT ProductRef__c FROM CampaignLineItem__c WHERE (PreliminaryOrderRef_RSA__c in: orderIds OR FinalOrderRef_RSA__c in: orderIds)])
				{
					ProductIds.add(cli.ProductRef__c);
				}
				
		       	try
	           	{	
	           		if(ProductIds.size()>0)           		          		
                		UtilREST.BudgetUpdater(ProductIds,Owners);              	               	
	            }catch(Exception e)
	            {
				}
			}
			else if(trigger.isDelete)
			{
	        	for(Order__c ord : (List<Order__C>)trigger.old)
				{
					Owners.add(ord.OwnerId);
					OrderIds.add(ord.id);					
				}
				
				for(CampaignLineItem__c cli : [ SELECT ProductRef__c FROM CampaignLineItem__c WHERE (PreliminaryOrderRef_RSA__c in: orderIds OR FinalOrderRef_RSA__c in: orderIds)])
				{
					ProductIds.add(cli.ProductRef__c);
				}				
				
		       	try
	           	{
                	if(ProductIds.size()>0)
                		UtilREST.BudgetUpdater(ProductIds,Owners);              	               	
	            }catch(Exception e)
	            {
				}
			}
		}
	}
}