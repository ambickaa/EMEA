/*
	Assigns hybrid record if exists, if not, creates a new one
	
*/
public with sharing class TriggerStockAssignHybrid implements Triggers.Handler {

public void handle()
	{
		Map<String, Id> PKVsHybrid= new Map<String,Id>();
		List<Stock__c> stockToCheck = new List<Stock__c>();
		List<Stock__c> stockToCheck2 = new List<Stock__c>();		
		Set<String> HybridPks = new Set<String> ();
		Map <String, Hybrid__c> hybridToInsert= new Map<String, Hybrid__c>();
		Set<String> newPkToInsert = new Set<String>();
		
		for (Stock__c stk : (List<Stock__c>)trigger.new)
		{
			if(stk.HybridRef__c==null && stk.HybridName__c!=null && stk.User_RSA__c!=null && stk.ProductCatalogId__c!=null )
      		{
      		
				HybridPks.add(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c);
				stockToCheck.add(stk);		
			}			
		}
				
		for (Hybrid__c hyb : [SELECT ID, PK__c FROM Hybrid__c WHERE PK__c in: HybridPks])
		{
			PKVsHybrid.put(hyb.PK__c,hyb.ID);
		}		
		
		for(Stock__c stk : stockToCheck )  
		{
			if(stk.HybridRef__c==null && stk.HybridName__c!=null && stk.User_RSA__c!=null && stk.ProductCatalogId__c!=null )			
			{
				if(PKVsHybrid.get(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c)!=null)
					stk.HybridRef__c=PKVsHybrid.get(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c);
				else if(!newPkToInsert.contains(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c))
				{  
					Hybrid__c temp = new Hybrid__c(Name=stk.HybridName__c, UserRef__c=stk.User_RSA__c, ProductCatalogRef__c=stk.ProductCatalogId__c);
					hybridToInsert.put(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c,temp);
					stockToCheck2.add(stk);
					newPkToInsert.add(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c);
				}
			}
		}
		
		insert hybridToInsert.values(); 
				
		for(Stock__c stk : stockToCheck2)  
		{
			if(stk.HybridRef__c==null && stk.HybridName__c!=null && stk.User_RSA__c!=null && stk.ProductCatalogId__c!=null )			
			{
				if(hybridToInsert.get(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c).Id!=null)
					stk.HybridRef__c=hybridToInsert.get(stk.HybridName__c+'-'+stk.User_RSA__c+'-'+stk.ProductCatalogId__c).ID;
			}
		}
		 
	}


}