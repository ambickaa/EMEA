public with sharing class TriggerCampaignLineItemUpdateStock implements Triggers.Handler{
    
    private static map<Id, Order__c> allOrdersStaticMap = new map<Id, Order__c>();
    public static boolean fromAdmin = false ;
    
    //Caching operations
    public static void setNewOrders(list<Order__c> newOrders) {
        allOrdersStaticMap.putAll(newOrders);
    }
    public static map<Id, Order__c> getAllOrders(list<Id> ordersList) {
        map<Id, Order__c> result = new map<Id, Order__c>();
        list<Id> finalFilter = new list<Id>();
        for (Id element: ordersList) {
            if (!allOrdersStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, allOrdersStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Order__c> newElements = new list<Order__c>([SELECT id, Status_RSA__c, Signed_RSA__c FROM Order__c WHERE Id in :finalFilter]);
            result.putAll(newElements);
            allOrdersStaticMap.putAll(newElements);
        }
        return result;

    }
    
    public void handle(){
        Set<Id>initialOrdersId = new Set<Id>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
            if (cli.FinalOrderRef_RSA__c != null)
                initialOrdersId.add(cli.FinalOrderRef_RSA__c);
        }
        if (!trigger.isDelete){
            for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
                if (cli.PreliminaryOrderRef_RSA__c != null)
                    initialOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
                if (cli.FinalOrderRef_RSA__c != null)
                    initialOrdersId.add(cli.FinalOrderRef_RSA__c);
            }
        }
        map<Id, Order__c> allOrders = getAllOrders(new list<Id>(initialOrdersId));
        
        Set<Id> globalStocks = new Set<Id>();
        Set<Id> personalStocks = new Set<Id>();
        Set<ID> whStocksID = new Set<ID>();
        
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
 
	 		if (cli.FinalOrderRef_RSA__c != null && allOrders.get(cli.FinalOrderRef_RSA__c).status_RSA__c =='Draft' &&
	                    allOrders.get(cli.FinalOrderRef_RSA__c).Signed_RSA__c && !cli.Consigned__c){
	                if (cli.GlobalStock_RSA__c != null){
	                    globalStocks.add(cli.GlobalStock_RSA__c);
	                }
	                if (cli.PersonalStock_RSA__c != null){
	                    personalStocks.add(cli.PersonalStock_RSA__c);
	                }
	            
	        }else if(cli.FinalOrderRef_RSA__c != null && allOrders.get(cli.FinalOrderRef_RSA__c).status_RSA__c =='Draft' &&
	                    allOrders.get(cli.FinalOrderRef_RSA__c).Signed_RSA__c && cli.Consigned__c)
	        {
	        	if(cli.ConsignedWarehouseRef__c!=null)
	        		whStocksID.add(cli.ConsignedWarehouseRef__c);      	
	        }
        }
        try
        {    	
        		
        		if(globalStocks.size()>0)
        		   TriggerOrderUpdateStocks2.updateStocks(globalStocks, personalStocks);
                if(whStocksID.size()>0)
                   TriggerOrderUpdateStocks2.updateWarehouseStock(whStocksID);	
        }
        catch(Exception e)
	    {
	            		  System.debug('Trigger Exception 1: ' + e); 
			              String sumOfErrors = 'Not Enough Stock for ';
			              ID itemFailed = (''+e).split(';')[0].split('id ')[1];  
			              for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
			              {
		                    if(cli.GlobalStock_RSA__c == itemFailed || cli.PersonalStock_RSA__c == itemFailed || cli.ConsignedWarehouseRef__c == itemFailed)
	                        {
	                            sumOfErrors += cli.ProductName_RSA__c + ';';
								cli.addError(sumOfErrors);  
	                            break;                                                     
	                        }
                  	  	  }
					
        }
    }
    
    
}