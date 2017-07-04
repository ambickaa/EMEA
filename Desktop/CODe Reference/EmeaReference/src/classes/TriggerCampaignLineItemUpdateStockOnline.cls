public with sharing class TriggerCampaignLineItemUpdateStockOnline implements Triggers.Handler {

	public static Boolean fromREST=false;
	List<ID> ordersToUpdate = new List<ID>();
	
	public List<Order__c> getOrders(List<ID> orderIds)
	{
		List<Order__c> Orders= new List<Order__c>();
		Orders=[ SELECT ID FROM Order__c WHERE id in: orderIds];
		return Orders;		
	}
	
	public void handle()
	{		
		if(!fromREST)
		{			
			 if(trigger.isInsert)
	        {
	        	for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
	        	{
	        		ordersToUpdate.add(cli.FinalOrderRef_RSA__c);
	        	}
	        	try
           		{
               		 update(getOrders(ordersToUpdate));               	
            	}catch(Exception e)
            	{
            		   System.debug('Trigger Exception: ' + e);
		               String sumOfErrors = 'Not Enough Stock for ';
		               ID itemFailed = (''+e).split(';')[0].split('id ')[1];  
		               for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
	                        if(cli.FinalOrderRef_RSA__c == itemFailed)
	                        {
	                            sumOfErrors += cli.ProductName_RSA__c + ';';
	                            cli.addError(sumOfErrors);  
	                            break;                                                     
	                        }
                  	  }
				}
	        }
	        else if(trigger.isUpdate)
	        {
			        for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
			        {
			        	ordersToUpdate.add(cli.FinalOrderRef_RSA__c);
			        }
		        	try
	           		{
	               		 update(getOrders(ordersToUpdate));               	
	            	}catch(Exception e)
	            	{
	            		  System.debug('Trigger Exception: ' + e);
			              String sumOfErrors = 'Not Enough Stock for ';
			              ID itemFailed = (''+e).split(';')[0].split('id ')[1];  
			              for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
			              {
		                    if(cli.FinalOrderRef_RSA__c == itemFailed)
	                        {
	                            sumOfErrors += cli.ProductName_RSA__c + ';';
	                            cli.addError(sumOfErrors);  
	                            break;                                                     
	                        }
                  	  	  }
					}
			}
			else if(trigger.isDelete)
			{
					set<Id> stocksToUpdateGlobal = new set<Id>();
					set<Id> stocksToupdatePersonal = new set<Id>();
															
			        for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.old)
			        {
			        	ordersToUpdate.add(cli.FinalOrderRef_RSA__c);
			        	if(cli.FinalOrderRef_RSA__c!=null)
			        	{
			        		stocksToUpdateGlobal.add(cli.GlobalStock_RSA__c);
			        		stocksToupdatePersonal.add(cli.PersonalStock_RSA__c);			        		
			        	}			        	
			        }
		        	try
	           		{
	               		 update(getOrders(ordersToUpdate));  
			        	 TriggerOrderUpdateStocks2.updateStocks(stocksToUpdateGlobal,stocksToupdatePersonal);        			               		              	
	            	}catch(Exception e)
	            	{
	            		  /*System.debug('Trigger Exception: ' + e);
	            		  String sumOfErrors='';
	            		  if((''+e).contains('Cancelled orders cannot be edited'))
			              	 sumOfErrors = 'Cancelled orders cannot be edited id ';
			              ID itemFailed = (''+e).split(';')[0].split('id ')[1];  
			              for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old)
			              {
		                    if(cli.FinalOrderRef_RSA__c == itemFailed)
	                        {
	                            sumOfErrors += cli.ProductName_RSA__c + ';';
	                            cli.addError(sumOfErrors);  
	                            break;                                                     
	                        }
                  	  	  }*/
					}
			}
		}
	}
}