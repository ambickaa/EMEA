public class TriggerCampaignLineItemCheckChanges implements Triggers.Handler
{
    private String MSG_ATTEMPT_TO_CHANGE_A_FROZEN_FIELD = 'Attempt to change a Frozen field';
    public static Boolean fromRest = false;  
        
    private static map<Id, Order__c> allOrdersStaticMap = new map<Id, Order__c>();
    private static map<Id, CampaignLineItem__c> MapCLIs = new map<Id, CampaignLineItem__c>();
    private static map<Id, Id> MapCLIsWithVLI = new map<Id, Id>();
    private static map<Id, ProductCatalogEntry__c> MapPCEsWithVLI = new map<Id, ProductCatalogEntry__c>();
    
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
            list<Order__c> newElements = new list<Order__c>([SELECT id, Status_RSA__c, PdfSent_RSA__c FROM Order__c WHERE Id in :finalFilter]);
            result.putAll(newElements);
            allOrdersStaticMap.putAll(newElements);
        }
        return result;

    }
    
    public void handle()
    { 
      // Data: 01/07/2014 Add SystemSetting. This admin functionality allow change the AP without the frozen validation.
          String Ignore = 'false';
          SystemSettings__c settings = SystemSettings__c.getValues('IgnoreTriggers_Order');
          if(settings <> null) Ignore = settings.Value__c;
   
      if(Ignore=='false' || (Ignore=='true' && !UserInfo.getUserId().contains('005D0000002FcQu'))){
        
        /*BEG- Query all involved orders in a single query*/
        Set<Id>initialOrdersId = new Set<Id>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
            if (cli.PreliminaryOrderRef_RSA__c != null)
                initialOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
            if (cli.FinalOrderRef_RSA__c != null)
                initialOrdersId.add(cli.FinalOrderRef_RSA__c);
            
            MapCLIs.put(cli.Id,cli);
        }
        if (!trigger.isDelete){
            for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
                if (cli.PreliminaryOrderRef_RSA__c != null)
                    initialOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
                if (cli.FinalOrderRef_RSA__c != null)
                    initialOrdersId.add(cli.FinalOrderRef_RSA__c);
            }
        }
        
        for(VoucherLineItem__c vli : [SELECT Id, CampaignLineItemRef__c, CampaignLineItemRef__r.ProductCatalogEntryRef__c FROM VoucherLineItem__c WHERE CampaignLineItemRef__c IN :MapCLIs.keyset()]) {
        	MapCLIsWithVLI.put(vli.CampaignLineItemRef__c,vli.CampaignLineItemRef__r.ProductCatalogEntryRef__c);
        }
        for(ProductCatalogEntry__c pce : [SELECT Id, In_use__c FROM ProductCatalogEntry__c WHERE Id IN :MapCLIsWithVLI.values()]) {
        	MapPCEsWithVLI.put(pce.Id,pce);
        }
        
        /*map<Id,Order__c> allOrders = new map<Id,Order__c>([SELECT id, Status_RSA__c,PdfSent_RSA__c FROM Order__c WHERE Id in :initialOrdersId]);*/
        map<Id, Order__c> allOrders = getAllOrders(new list<Id>(initialOrdersId));
      
        
        /*END- Query all involved orders in a single query*/
        
        
        Set<Id>preliminaryOrdersId = new Set<Id>();
        if(trigger.isDelete){
        	for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old) {
        	  system.debug('***services/soap?' + String.valueOf(URL.getCurrentRequestUrl()).toLowerCase());
        	  if(!String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/apexrest') && MapCLIsWithVLI.containsKey(cli.Id)) {
        		cli.addError('You cannot delete a Campaign Line Item related to a Voucher Line Item');
        	  } else if (String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/apexrest') && MapCLIsWithVLI.containsKey(cli.Id)) {
        	  	//MapPCEsWithVLI.get(cli.ProductCatalogEntryRef__c).In_use__c -= cli.Agreed__c;
        	  }
        	}
        	update MapPCEsWithVLI.values();
            Set<ID> ordersID = new Set<ID>();
            for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
                if(cli.PreliminaryOrderRef_RSA__c != null){
                    ordersID.add(cli.PreliminaryOrderRef_RSA__c);
                    preliminaryOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
                }
                if(cli.FinalOrderRef_RSA__c != null){
                    ordersID.add(cli.FinalOrderRef_RSA__c);
                }
            }
            Map<ID,Order__c> orders = new Map<ID,Order__c>();
            for (Id i:OrdersID){
                if (allOrders.get(i) != null)
                    orders.put(i,allOrders.get(i));
            }
            
            for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
                /*now all campaign line items can be deleted, even if they belong to a Non-Draft Preliminary Order*/
                
                /*if(cli.PreliminaryOrderRef_RSA__c != null && orders.get(cli.PreliminaryOrderRef_RSA__c).Status_RSA__c != 'Draft'){
                    cli.addError('You cannot delete a Campaign Line Item that belongs to a non-Draft Order');
                }*/
                if(cli.FinalOrderRef_RSA__c != null && string.valueof(cli.FinalOrderRef_RSA__c).equals('') && (orders.get(cli.FinalorderRef_RSA__c).Status_RSA__c != 'Draft' /*|| orders.get(cli.FinalorderRef_RSA__c).Status_RSA__c != 'Cancelled')*/)){
                    cli.addError('You cannot delete a Campaign Line Item that belongs to a non-Draft Order');
                }
            }
        }else if(trigger.isUpdate){
            Set<ID> farmIds = new Set<ID>();
            for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.old){
                farmIds.add(cli.FarmRef__c);
            }
            TriggerCampaignLineItemHelper.add(farmIds);
            
            Set<ID> ordersID = new Set<ID>();
            List<CampaignLineItem__c> oldMapCLI= (List<CampaignLineItem__c>)trigger.old;
            List<CampaignLineItem__c> newMapCLI= (List<CampaignLineItem__c>)trigger.new;
            List<ID> cliWithoutOrd = new List<ID> ();
            
            for(CampaignLineItem__c cli : newMapCLI)
            {
                if(cli.PreliminaryOrderRef_RSA__c==null)
                    cliWithoutOrd.add(cli.id);
            }
            for(CampaignLineItem__c cli : oldMapCLI)
            {
                if(cli.PreliminaryOrderRef_RSA__c!=null)
                {
                    for(ID cliId :cliWithoutOrd)
                    {
                        if (cliId== cli.ID)
                        {
                            preliminaryOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
                        }
                    }
                }
            }           

            for(CampaignLineItem__c cli : oldMapCLI){
                if(cli.PreliminaryOrderRef_RSA__c != null){
                    ordersID.add(cli.PreliminaryOrderRef_RSA__c);
                }
                if(cli.FinalOrderRef_RSA__c != null){
                    ordersID.add(cli.FinalOrderRef_RSA__c);
                }
            }

            for(CampaignLineItem__c cli : newMapCLI){
                if(cli.PreliminaryOrderRef_RSA__c != null){
                    ordersID.add(cli.PreliminaryOrderRef_RSA__c);
                }
                if(cli.FinalOrderRef_RSA__c != null){
                    ordersID.add(cli.FinalOrderRef_RSA__c);
                }
            }    
            Map<ID,Order__c> orders = new Map<ID,Order__c>();
            for (Id i:OrdersID){
                if (allOrders.get(i)!= null)
                    orders.put(i,allOrders.get(i));
            }

            for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){    
                if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c)){
                    if(cli.campaignRef__c != ((CampaignLineItem__c)trigger.oldMap.get(cli.ID)).campaignRef__c ||
                       cli.CatalogType_RSA__c != ((CampaignLineItem__c)trigger.oldMap.get(cli.ID)).CatalogType_RSA__c ||
                       cli.FarmRef__c != ((CampaignLineItem__c)trigger.oldMap.get(cli.ID)).FarmRef__c ||
                       cli.Type__c != ((CampaignLineItem__c)trigger.oldMap.get(cli.ID)).Type__c)
                    {
                       cli.addError(MSG_ATTEMPT_TO_CHANGE_A_FROZEN_FIELD );
                    }else{
                        /*Now Campaign Line Items can be modified for preliminary orders*/
                        if(cli.PreliminaryOrderRef_RSA__c != null && orders.get(cli.PreliminaryOrderRef_RSA__c).Status_RSA__c != 'Draft'){
                            if(hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'Agreed__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'ProductCatalogEntryRef__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'ProductRef__c')||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'PreliminaryOrderRef_RSA__c'))
                            {
                                preliminaryOrdersId.add(cli.PreliminaryOrderRef_RSA__c);
                            }
                        }
                        if(cli.FinalOrderRef_RSA__c != null && orders.get(cli.FinalOrderRef_RSA__c).Status_RSA__c != 'Draft')
                        {
                            if(hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'Ultrashort_Irrigation_RSA__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'PlantingDensity__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'PoS__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'DistributorRef__c') ||
                               hasChanged(trigger.oldMap.get(cli.id),trigger.newMap.get(cli.id),'FinalOrderRef_RSA__c'))
                            {
                               cli.addError(MSG_ATTEMPT_TO_CHANGE_A_FROZEN_FIELD );
                            }
                        }
                       if((((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c != null && orders.get(((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c ).Status_RSA__c != 'Cancelled')&& 
                        (
                            /*(cli.PreliminaryOrderRef_RSA__c != null && orders.get(cli.PreliminaryOrderRef_RSA__c).Status_RSA__c != 'Draft' && ((CampaignLineItem__c)trigger.oldMap.get(cli.id)).PreliminaryOrderRef_RSA__c != cli.PreliminaryOrderRef_RSA__c) || 
                           (((CampaignLineItem__c)trigger.oldMap.get(cli.id)).PreliminaryOrderRef_RSA__c != null && orders.get(((CampaignLineItem__c)trigger.oldMap.get(cli.id)).PreliminaryOrderRef_RSA__c).Status_RSA__c != 'Draft' && ((CampaignLineItem__c)trigger.oldMap.get(cli.id)).PreliminaryOrderRef_RSA__c != cli.PreliminaryOrderRef_RSA__c) ||*/
                           (cli.FinalOrderRef_RSA__c != null && orders.get(cli.FinalOrderRef_RSA__c).Status_RSA__c != 'Draft' && ((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c != cli.FinalOrderRef_RSA__c ) || 
                            (((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c != null && orders.get(((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c ).Status_RSA__c != 'Draft' && ((CampaignLineItem__c)trigger.oldMap.get(cli.id)).FinalOrderRef_RSA__c != cli.FinalOrderRef_RSA__c ))
                           )
                      {
                           cli.addError(MSG_ATTEMPT_TO_CHANGE_A_FROZEN_FIELD );
                        }
                    }
                }   
            }
        }
        /*Preliminary Orders with modified campaign line items need their pdf generated again*/
        list<Order__c>ordersToUpdate = new list<Order__c>();
        for (Id i:preliminaryOrdersId){
            if (allOrders.get(i)!= null)
                ordersToUpdate.add(allOrders.get(i));
        }
        
        /* BEG - Don?t reesend pdf from online */
        if(fromRest)
        {
          for (Order__c o: ordersToUpdate){
              o.PdfSent_RSA__c = False;
          }
        }
        /* END */
        update ordersToUpdate;
     }
    }
    private Boolean hasChanged(sObject paramA, sObject paramB, String paramField){
        return (paramA.get(paramField) != paramB.get(paramField));
    }
}