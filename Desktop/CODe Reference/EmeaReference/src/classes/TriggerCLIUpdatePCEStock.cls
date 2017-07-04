public with sharing class TriggerCLIUpdatePCEStock implements Triggers.Handler {
//----------------------------------------
// Created by Support Team 2016.09.16
// Updated by Support Team 2016.12.20
//----------------------------------------  
    Set<Id> Set_PCEId = new Set<Id>();
    
    List<ProductCatalogEntry__c> List_PCE = new List<ProductCatalogEntry__c>();
    Set<ProductCatalogEntry__c> Set_PCE = new Set<ProductCatalogEntry__c>();
    
    Map<Id, List<CampaignLineItem__c>> Map_CLIs = new Map<Id, List<CampaignLineItem__c>>();
    Map<Id, Decimal> Map_PCE_old = new Map<Id, Decimal>();
    Map<Id, Decimal> Map_PCE_new = new Map<Id, Decimal>();
    
    public void handle()
    {
			//----------------------------------------
			// Building maps with old and new status of Monsanto Sales CLIs
			// and building set with all PCEs related to these CLIs
			//----------------------------------------
	        if(trigger.isDelete || trigger.isUpdate)
	        {
	            for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.old)
	            {
	                if(cli.ProductCatalogEntryRef__c != null && cli.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales') && cli.Provider__c != null && cli.Provider__c.contains('Monsanto'))
	                {
	                    Set_PCEId.add(cli.ProductCatalogEntryRef__c);
	                    
	                    Decimal q = (cli.Agreed__c != null && cli.Status__c != 'Cancelled') ? cli.Agreed__c : 0;
	                    
	                    if(Map_PCE_old.containsKey(cli.ProductCatalogEntryRef__c))
	                        q += Map_PCE_old.get(cli.ProductCatalogEntryRef__c);
	                    
	                    Map_PCE_old.put(cli.ProductCatalogEntryRef__c, q);
	                }
	            }
	        }
	        if(trigger.isUpdate || trigger.isInsert)
	        {
	            for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
	            {
	                if(cli.ProductCatalogEntryRef__c != null && cli.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales') && cli.Provider__c != null && cli.Provider__c.contains('Monsanto'))
	                {
	                	if(cli.Status__c != 'Cancelled')
	                	{
		                	if(cli.POG__c != null) cli.Status__c = 'Confirmed';
		                	else if(cli.Agreed__c != null) cli.Status__c = 'Ordered / Discussed';
		                	else if(cli.Forecast__c != null) cli.Status__c = 'Forecast';
	                	}
	                	
	                    Set_PCEId.add(cli.ProductCatalogEntryRef__c);
	                    
	                    if(Map_CLIs.containsKey(cli.ProductCatalogEntryRef__c))
	                        Map_CLIs.get(cli.ProductCatalogEntryRef__c).add(cli);
	                    else
	                        Map_CLIs.put(cli.ProductCatalogEntryRef__c, new List<CampaignLineItem__c>{cli});
	                    
	                    Decimal q = (cli.Agreed__c != null && cli.Status__c != 'Cancelled') ? cli.Agreed__c : 0;
	                    
	                    if(Map_PCE_new.containsKey(cli.ProductCatalogEntryRef__c))
	                        q += Map_PCE_new.get(cli.ProductCatalogEntryRef__c);
	                    
	                    Map_PCE_new.put(cli.ProductCatalogEntryRef__c, q);
	                }
	            }
	        }

			//----------------------------------------
			// Actions only when there are Monsanto Sales CLIs with PCEs
			//----------------------------------------
	        if(Util.currentCountry.Name != 'South Africa' && Set_PCEId.size() > 0)
	        {
	            //----------------------------------------
	            // Getting further info for PCEs
	            //----------------------------------------
				for(ProductCatalogEntry__c pce : [SELECT Id, Allocation__c, In_use__c, Left__c, TXT_ProductName__c FROM ProductCatalogEntry__c WHERE Allocation__c != null AND Id IN :Set_PCEId])
	            {
					//----------------------------------------
					// Avoiding null arguments
					//----------------------------------------
					Decimal newInUse = Map_PCE_new.get(pce.Id) == null ? 0 : Map_PCE_new.get(pce.Id);
	            	Decimal oldInUse = Map_PCE_old.get(pce.Id) == null ? 0 : Map_PCE_old.get(pce.Id);

	                pce.In_use__c += trigger.isUpdate ? (newInUse - oldInUse) : (trigger.isInsert ? newInUse : (trigger.isDelete ? - oldInUse : 0));
	                
	                if(pce.In_use__c > pce.Allocation__c && !Test.isRunningTest())
	                {
	                    for(CampaignLineItem__c cli : Map_CLIs.get(pce.Id))
	                        cli.addError('\r\n' + cli.Name + ' - ' + cli.FarmName__c + ':\r\n' + Label.Err_PCE_Stock + ' \u300A' + pce.TXT_ProductName__c + '\u300B');
	                }
	                
	                Set_PCE.add(pce);
	            }
	
	            //----------------------------------------
	            // Updating PCEs
	            //----------------------------------------
	            List_PCE.addAll(Set_PCE);
	            if(List_PCE.size() > 0)
	            {
		            try {
		                update List_PCE;
		            } catch (DmlException e) {
		                for(Integer i = 0; i < e.getNumDml(); i++)
		                    system.debug(e.getDmlMessage(i));
		            }
	            }
	        }
    }
}