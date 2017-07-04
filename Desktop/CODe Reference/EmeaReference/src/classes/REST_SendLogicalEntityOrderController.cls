@RestResource(urlMapping='/sendLogicalEntity/Order_5/*')
global with sharing class REST_SendLogicalEntityOrderController{

    private static Map<Integer,Order__c> preliminaryOrderToInsert = new Map<Integer,Order__c>();
    private static Map<Integer,Order__c> finalOrderToInsert = new Map<Integer,Order__c>();
    private static Map<Integer,Order__c> finalOrderToInsertWithoutVolDisc = new Map<Integer,Order__c>();
	private static Map<Integer,Order__c> finalOrderToInsertWithVolDisc = new Map<Integer,Order__c>();
    private static Map<Integer,Order__c> cancelledOrders = new Map<Integer,Order__c>();
    private static Map<Integer,REST_OrderObject> finalOrderObjectToInsert = new Map<Integer,REST_OrderObject>();
    private static List<Order__c> allOrders = new List<Order__c>();
    private static Map<Integer,Map<String,String>> previousOrderValues = new Map<Integer,Map<String,String>>();
    
    private static Set<Id> orderToUpdateIds = new Set<Id>();
    
    private static Order__c auxOrder=new Order__c();
    private static Set<Integer> OrdersIDChecked  = new Set<Integer>();
    
    private static List<CampaignLineItem__c> campaignLineItemsToInsert = new List<CampaignLineItem__c>();
    private static List<CampaignLineItem__c> campaignLineItemsToUpdate = new List<CampaignLineItem__c>();
    private static List<CampaignLineItem__c> campaignLineItemsToDelete = new List<CampaignLineItem__c>();
    @HttpPost
    global static REST_SendLogicalEntityOrder sendOrders(REST_SendLogicalEntityOrder paramInfo)
    {
        String request = System.JSON.serializePretty(paramInfo);
        TriggerOrderUpdateStocks.displayIDs = true;
        TriggerOrderCloneFields.fromREST = true;
        TriggerCampaignLineItemUpdateStockOnline.fromRest =true; 
        TriggerOrderUpdateBudgetOnline.fromRest = true;     
        TriggerCampaignLineItemCheckChanges.fromRest = true;
               
        /* BEGIN - Id lists for triggers map caching */
        list<Id> productCatalogEntryRefList = new list<Id>();
        list<Id> campaignLineItemsList = new list<Id>();
        list<Id> campaignsList = new list<Id>();
        list<Id> ownersList = new list<Id> {Util.currentUser.Id};
        list<Id> involvedOrdersList = new list<Id>();
        //Trigger Orders
        list<Id> finalOrders = new list<Id>();
        list<Id> discountIds= new list<Id>();
        list<Id> accountsIds= new list<Id>();
        List<Id> AccountsIdList = new List<Id>();
        // Other caching
        TriggerOrderCalculatePrice.cacheCampaignLineItems = true;
        TriggerOrderCalculatePrice.isOffline=true;
        
        /* END - Id lists for triggers map caching */
        REST_SendLogicalEntityOrder returned = paramInfo;
        
        // timestamp check
        Set<ID> campaignLineItemsIDToCheck = new Set<ID>();
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
            if(!'Insert'.equalsIgnoreCase(rclio.action)){
                campaignLineItemsIDToCheck.add(rclio.campaignLineItem.ID);
            }
        }
        Set<ID> ordersIDToCheck = new Set<ID>();
        for(REST_OrderObject roo : returned.orders){
            if(!'Insert'.equalsIgnoreCase(roo.action)){
                ordersIDToCheck.add(roo.order.ID);
            }
        }
        Map<ID,CampaignLineItem__c> campaignLineItemsToCheck = new Map<ID,CampaignLineItem__c>([SELECT LastModifiedDate FROM CampaignLineItem__c WHERE ID IN :campaignLineItemsIDToCheck]);
        Map<ID,Order__c> ordersToCheck = new Map<ID,Order__c>([SELECT LastModifiedDate FROM Order__c WHERE ID IN :ordersIDToCheck]);
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
            if(!'Insert'.equalsIgnoreCase(rclio.action)){
                if(campaignLineItemsToCheck.get(rclio.campaignlineItem.id) == null){
                    returned.statusCode = REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED;
                    returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode);
                    rclio.statusCode = returned.statusCode;
                    rclio.statusDescription = returned.statusDescription;
                }else if(rclio.campaignLineItem.LastModifiedDate != campaignLineItemsToCheck.get(rclio.campaignLineItem.id).LastModifiedDate){
                    returned.statusCode = REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH;
                    returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode);
                    rclio.statusCode = returned.statusCode;
                    rclio.statusDescription = returned.statusDescription;
                }
            }
            /* BEGIN - Prepare caching lists for triggers static maps */
            if(rclio.campaignLineItem!=null  ){
                
             if (rclio.campaignLineItem.ProductCatalogEntryRef__c != null && !string.valueof(rclio.campaignLineItem.ProductCatalogEntryRef__c).equals('') /*&&rclio.campaignLineItem.ProductCatalogEntryRef__c != ''*/)
                 productCatalogEntryRefList.add(rclio.campaignLineItem.ProductCatalogEntryRef__c);
             if (rclio.campaignLineItem.CampaignRef__c != null && !string.valueof(rclio.campaignLineItem.CampaignRef__c).equals('')/*&& rclio.campaignLineItem.CampaignRef__c !=''*/)
                campaignsList.add(rclio.campaignLineItem.CampaignRef__c);
             if (rclio.campaignLineItem.PreliminaryOrderRef_RSA__c != null && !string.valueof(rclio.campaignLineItem.PreliminaryOrderRef_RSA__c).equals('') /*&& rclio.campaignLineItem.PreliminaryOrderRef_RSA__c != ''*/)
                involvedOrdersList.add(rclio.campaignLineItem.PreliminaryOrderRef_RSA__c);
             if (rclio.campaignLineItem.FinalOrderRef_RSA__c != null && !string.valueof(rclio.campaignLineItem.FinalOrderRef_RSA__c).equals('')/*&& rclio.campaignLineItem.FinalOrderRef_RSA__c != ''*/)
                involvedOrdersList.add(rclio.campaignLineItem.FinalOrderRef_RSA__c);
             if (rclio.campaignLineItem.Id != null && !string.valueof(rclio.campaignLineItem.Id).equals('')/* && rclio.campaignLineItem.Id !=''*/)
                campaignLineItemsList.add(rclio.campaignLineItem.Id);
            }
            /*END - Prepare caching lists for triggers static maps */
        }
        for(REST_OrderObject roo : returned.orders){
            if(!'Insert'.equalsIgnoreCase(roo.action)){
                if(ordersToCheck.get(roo.order.id) == null){
                    returned.statusCode = REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED ;
                    returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode);
                    roo.statusCode = returned.statusCode;
                    roo.statusDescription = returned.statusDescription;
                }else if(roo.order.LastModifiedDate != ordersToCheck.get(roo.order.id).LastModifiedDate){
                    returned.statusCode = REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH;
                    returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode);
                    roo.statusCode = returned.statusCode;
                    roo.statusDescription = returned.statusDescription;
                }
            }
            /* BEGIN - Prepare caching lists for triggers static maps */
            if (roo.order.recordTypeID == Util.recordType.get('Order__c:FinalOrder')){
               finalOrders.add(roo.order.Id);
            }
            if(roo.order.shouldCopy_RSA__c && roo.order.Status_RSA__c == 'Draft'){
                if (roo.order.AccountRef_RSA__c != null && !string.valueof(roo.order.AccountRef_RSA__c).equals(''))
                    accountsIds.add(roo.order.AccountRef_RSA__c);
                if (roo.order.EarlyPayment_RSA__c != null && !string.valueof(roo.order.EarlyPayment_RSA__c).equals(''))
                    discountIds.add(roo.order.EarlyPayment_RSA__c);
                if (roo.order.EarlyDelivery_RSA__c != null && !string.valueof(roo.order.EarlyDelivery_RSA__c).equals(''))
                    discountIds.add(roo.order.EarlyDelivery_RSA__c);
            }
             /* END - Prepare caching lists for triggers static maps */
             if(roo.order.AccountRef_RSA__c != null && !String.ValueOf(roo.order.AccountRef_RSA__c).equals(''))
             	AccountsIdList.add(roo.order.AccountRef_RSA__c);
        }
        if(returned.statusCode == REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH || returned.statusCode == REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED){
            generateBackupDocument(request,paraminfo, false);
            return returned;
        }

        // End_Of    timestamp check
        
        Map<ID,Account> AccountsToCheck = new Map<ID,Account>([SELECT SAP_Number_RSA__c FROM Account WHERE ID IN :AccountsIdList]);        
        for(REST_OrderObject roo : returned.orders){
            if('Insert'.equalsIgnoreCase(roo.action)){
                previousOrderValues.put(Integer.valueOf(roo.order.idDevice__c),new Map<String,String>{'Signed_RSA__c'=>String.valueOf(roo.order.Signed_RSA__c),'Status_RSA__c'=>roo.order.Status_RSA__c});
                roo.order.Status_RSA__c = 'Draft';
                roo.order.Signed_RSA__c = false;
                if(roo.order.AccountRef_RSA__c != null && AccountsToCheck.get(roo.order.AccountRef_RSA__c) != null)
                	roo.order.SAP_Number_Copy_RSA__c = AccountsToCheck.get(roo.order.AccountRef_RSA__c).SAP_Number_RSA__c;
                if(roo.order.recordTypeID == Util.recordType.get('Order__c:PreliminaryOrder')){//roo.preliminaryOrderIdDevice == 0){
                    preliminaryOrderToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo.order);
                }else{
                    finalOrderObjectToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo);
                    finalOrderToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo.order);
                }
            }
            
            
            if('Update'.equalsIgnoreCase(roo.action) && (roo.order.Status_RSA__c == 'Cancelled')){
                cancelledOrders.put(Integer.valueOf(roo.order.idDevice__c), roo.order);
                orderToUpdateIds.add(roo.order.Id);
            }else{
                allOrders.add(roo.order);
                orderToUpdateIds.add(roo.order.Id);                
            }            
        }
        
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
            if('Insert'.equalsIgnoreCase(rclio.action)){
            	if(rclio.campaignLineItem.CreatedDate == null && rclio.campaignLineItem.LastModifiedDate != null)
            		rclio.campaignLineItem.CreatedDate = rclio.campaignLineItem.LastModifiedDate;
                campaignLineItemsToInsert.add(rclio.campaignLineItem);
            }else if ('Update'.equalsIgnoreCase(rclio.action)){
                campaignLineItemsToUpdate.add(rclio.campaignLineItem);
            }else if ('Delete'.equalsIgnoreCase(rclio.action)){
                campaignLineItemsToDelete.add(rclio.campaignLineItem);
            }
        }
        returned.statusCode = 100;
        returned.statusDescription = 'Processed';
        Savepoint sp = Database.setSavepoint();
               //punto indicates the last DML operation that was completed correctly
       Integer punto = 0;
    
        try{
              /* BEGIN - force cache for all Order trigger-related maps */
              TriggerOrderCalculatePrice.getCliByFinalOrder(finalOrders);
              TriggerOrderCloneFields.getDiscounts(discountIds);
              TriggerOrderCloneFields.getAccounts(accountsIds);
              /* END - force cache for all Order trigger-related maps */
              
            // Insert new preliminary Orders

            if (preliminaryOrderToInsert.size()>0){

              punto = 0;

                insert preliminaryOrderToInsert.values();
                /* BEGIN - Caching of new orders is enforced */
                TriggerCampaignLineItemCheckChanges.setNewOrders(preliminaryOrderToInsert.values());
                TriggerOrderPreventNameUpdate.setNewOrders(preliminaryOrderToInsert.values());
                /* END - Caching of new orders is enforced */
            }
             
            for(Order__c o : preliminaryOrderToInsert.values()){
                o.Signed_RSA__c = boolean.valueOf(previousOrderValues.get(Integer.valueOf(o.idDevice__c)).get('Signed_RSA__c'));
                o.Status_RSA__c = previousOrderValues.get(Integer.valueOf(o.idDevice__c)).get('Status_RSA__c');
            }
            // Update LookupFields for FinalOrders and make them unsigned
            for(REST_OrderObject roo : finalOrderObjectToInsert.values()){
                if(roo.PreliminaryOrderIdDevice != 0 && preliminaryOrderToInsert.get(roo.PreliminaryOrderIdDevice) != null && roo.order.PreliminaryOrderRef_RSA__c == null){
                    roo.order.PreliminaryOrderRef_RSA__c = preliminaryOrderToInsert.get(roo.PreliminaryOrderIdDevice).ID;
                }
                //previousOrderValues.put(Integer.valueOf(roo.order.idDevice__c),new Map<String,String>{'Signed_RSA__c'=>String.valueOf(roo.order.Signed_RSA__c),'Status_RSA__c'=>roo.order.Status_RSA__c});
            }
            

            for(REST_CampaignLineItemObject rclio : returned.campaignLineItems)
            {
            
                if(rclio.FinalOrderIdDevice!=null && rclio.FinalOrderIdDevice!=0)
                {
                    if(finalOrderToInsert.keyset().contains(rclio.FinalOrderIdDevice) && !OrdersIDChecked.contains(rclio.FinalOrderIdDevice))
                    {
                        auxOrder=finalOrderToInsert.get(Integer.valueOf(rclio.FinalOrderIdDevice));
                        auxOrder.isIrrigated_RSA__c=false;                     
                        if(rclio.CampaignLineItem.Ultrashort_Irrigation_RSA__c==true)
                            auxOrder.isIrrigated_RSA__c=true;
                        else
                            auxOrder.isIrrigated_RSA__c=false;
                        OrdersIDChecked.add(Integer.valueOf(rclio.FinalOrderIdDevice));
                        finalOrderToInsert.put(Integer.valueOf(rclio.FinalOrderIdDevice),auxOrder); 
                    }      
                }
             }

            // Insert new final Orders
           if (finalOrderToInsert.size()>0) {

			punto = 1;

                insert finalOrderToInsert.values();
                /* BEGIN - Caching of new orders is enforced */
                TriggerCampaignLineItemCheckChanges.setNewOrders(finalOrderToInsert.values());
                //TriggerOrderPreventNameUpdate.setNewOrders(finalOrderToInsert.values());
                /* END - Caching of new orders is enforced */
            }
            
            for(Order__c o: finalOrderToInsert.values()){
              finalOrders.add(o.Id);
            }
            TriggerOrderPreventNameUpdate.getFinalOrders(finalOrders);
            if (cancelledOrders.size()>0)

			punto = 2;

              update cancelledOrders.values();
                              		             
            // CampaignLineItem Logic
            /* BEGIN - force cache for all CLI trigger-related maps */
            TriggerCampaignLineItemAddProductLineI.getACampaign(campaignsList);
            TriggerCampaignLineItemMatchProdAndCatal.getCampaigns(campaignsList);
            TriggerCampaignLineItemFillStockLookups.getCampaigns(campaignsList);
            TriggerCampaignLineItemFillStockLookups.getUsers(ownersList);
            TriggerCampaignLineItemDeleteEmptyOrder.getOrders(involvedOrdersList);
            TriggerCampaignLineItemCheckChanges.getAllOrders(involvedOrdersList);
            TriggerCampaignLineItemCloneFields.getCampaignLineItems(campaignLineItemsList);
            //TriggerCampaignLineItemCloneFields.getProductCatalogEntries(productCatalogEntryRefList);*/
            /* END - force cache for all CLI trigger-related maps */
            
            for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
                if('Insert'.equalsIgnoreCase(rclio.action) || 'Update'.equalsIgnoreCase(rclio.action)) {
                    if(rclio.PreliminaryOrderIdDevice != 0 && rclio.campaignLineItem.PreliminaryOrderRef_RSA__c == null){
                        rclio.campaignLineItem.PreliminaryOrderRef_RSA__c = preliminaryOrderToInsert.get(rclio.PreliminaryOrderIdDevice).id;
                    }
                    if(rclio.FinalOrderIdDevice != 0 && rclio.campaignLineItem.FinalOrderRef_RSA__c == null){
                        rclio.campaignLineItem.FinalOrderRef_RSA__c = finalOrderToInsert.get(rclio.FinalOrderIdDevice).id;
                    }
                }
            }

			punto = 3;

            insert campaignLineItemsToInsert;
            /* BEGIN - caching of new Campaign Line Items is enforced */
            TriggerCampaignLineItemCloneFields.setNewCampaignLineItems(campaignLineItemsToInsert);
            TriggerOrderCalculatePrice.setNewCampaignLineItems(campaignLineItemsToInsert);
            /* END - caching of new Campaign Line Items is enforced */
             			            
			punto = 4;

            update campaignLineItemsToUpdate;
			                      		            
			punto = 5;

            delete campaignLineItemsToDelete;
            
            // End of CampaignLineItem Logic
            // Recover original Values for Signed_RSA__c and Status_RSA__c for final orders
            for(REST_OrderObject roo : finalOrderObjectToInsert.values()){
                roo.order.Signed_RSA__c = boolean.valueOf(previousOrderValues.get(Integer.valueOf(roo.order.idDevice__c)).get('Signed_RSA__c'));
                
                if(roo.order.VolumeDiscount_RSA__c != 0){
                  roo.order.Status_RSA__c = 'Waiting for discount approval';  
                }
                
                else{
                  roo.order.Status_RSA__c = previousOrderValues.get(Integer.valueOf(roo.order.idDevice__c)).get('Status_RSA__c');
                }
               
            }
            // update AllOrders

			punto = 6;

            update allOrders;                        
            
            /*OPEN New Development - Preliminary Order Edit. Orders must keep their signature if they are already signed*/
            // Signature insert for orders
            Set<ID> ordersToPdf = new Set<ID>();
            // Get all the signatures
            list<Attachment> currentSignatures = [SELECT ParentId, name, Body from Attachment where name = 'Signature.png' AND ParentId in: orderToUpdateIds];
            // Only orders' Id with signature are needed
            set<Id>signedOrders = new set<Id>();
            Map<Id,Id> orderVsAttach = new Map<Id,Id>();
            
            for (Attachment signature :currentSignatures){
                signedOrders.add(signature.ParentId);
                orderVsAttach.put(Signature.ParentId, Signature.Id);
            }
            /*CLOSE New Development - Preliminary order Edit. Orders must keep their signature if they are already signed*/
            
            List<Attachment> signaturesToInsert = new List<Attachment>();
            List<Attachment> signaturesToUpdate = new List<Attachment>();

            for(REST_OrderObject roo : returned.orders){
                if (roo.order.recordTypeID == Util.recordType.get('Order__c:PreliminaryOrder') && 
                    roo.order.Status_RSA__c == 'Closed' && 
                    roo.order.Signed_RSA__c == true 
                    )
                {
                    if (roo.signature != null && !signedOrders.contains(roo.order.Id))
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature.png', body = EncodingUtil.base64Decode(roo.signature)));
                    else if(roo.signature != null &&  signedOrders.contains(roo.order.Id))
                    {
                        signaturesToUpdate.add(new Attachment(Id=orderVsAttach.get(roo.order.Id),parentID = roo.order.id, name='Signature.png', body = EncodingUtil.base64Decode(roo.signature)));                      
                    }else if(roo.signature ==null && signedOrders.contains(roo.order.Id) ) 
                    {
                        
                    }                 
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND, roo.order.id);
                    }
                        
                }else if(roo.order.recordTypeId == Util.recordType.get('Order__c:FinalOrder') && 
                        (
                           roo.order.Status_RSA__c == 'Closed' || 
                           roo.order.Status_RSA__c == 'Waiting for discount approval'
                        ) && 
                        roo.order.Signed_RSA__c == true && !signedOrders.contains(roo.order.Id)) 
                {
                    if (roo.signature != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature.png', body = EncodingUtil.base64Decode(roo.signature)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND,roo.order.id);
                    }
                    if (roo.signature_tech != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature_tech.png', body = EncodingUtil.base64Decode(roo.signature_tech)));
                     if (roo.signature_storage != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature_storage.png', body = EncodingUtil.base64Decode(roo.signature_storage)));
                    if (roo.signature_terms != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature_terms.png', body = EncodingUtil.base64Decode(roo.signature_terms)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND,roo.order.id);
                    }
                    if (roo.signature_privacy != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature_privacy.png', body = EncodingUtil.base64Decode(roo.signature_privacy)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND,roo.order.id);
                    }
    
                }
            }

			punto = 7;

            insert signaturesToInsert;

			punto = 8;

            update signaturesToUpdate;
            
            //delete signaturesToInsert;
             
            // recover new LastModifiedDate
            Set<ID> campaignLineItemsIDToGet = new Set<ID>();
            for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
                if(!'Delete'.equalsIgnoreCase(rclio.action)){
                    campaignLineItemsIDToGet.add(rclio.campaignLineItem.ID);
                }
            }
            Set<ID> ordersIDToGet = new Set<ID>();
            for(REST_OrderObject roo : returned.orders){
                if(!'Delete'.equalsIgnoreCase(roo.action)){
                    ordersIDToGet.add(roo.order.ID);
                }
            }
            
            Map<ID,CampaignLineItem__c> campaignLineItemsToGet = new Map<ID,CampaignLineItem__c>([SELECT LastModifiedDate, ProductRef__c,FinalOrderRef_RSA__r.Type_RSA__c, FinalOrderRef_RSA__r.Status_RSA__c,GlobalStock_RSA__r.HybridRef__r.Name, GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c,  GlobalStock_RSA__r.HybridRef__r.StockLeft__c, ProductRef__r.Name, Pog__c  FROM CampaignLineItem__c WHERE ID IN :campaignLineItemsIDToGet]);
            Map<ID,Order__c> ordersToGet = new Map<ID,Order__c>([SELECT LastModifiedDate, Name FROM Order__c WHERE ID IN :ordersIDToGet]);
            
            
            List<CampaignLineItem__c> cliBelowThreshold = new List<CampaignLineItem__c>(); 
            List<CampaignLineItem__c> cliBelowThresholdTax = new List<CampaignLineItem__c>(); 

            List<ID> productsForBudget = new List<ID>();
                      
            Integer threshold =Integer.valueof(SystemSettings__c.getValues('RSA_STOCK_THRESHOLD').Value__c);
            Integer thresholdTax =Integer.valueof(SystemSettings__c.getValues('RSA_STOCK_THRESHOLD_TAX').Value__c);
            
            
            for(Id iter: campaignLineItemsToGet.keyset())
            {
                
                productsForBudget.add(campaignLineItemsToGet.get(iter).ProductRef__c);  
                if(campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Status_RSA__c=='Closed' && campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Type_RSA__c!='Tax' && campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Type_RSA__c!='General' && campaignLineItemsToGet.get(iter).GlobalStock_RSA__r.HybridRef__r.StockLeft__c<=threshold)
                {
                        cliBelowThreshold.add(campaignLineItemsToGet.get(iter));
                }
                if(campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Status_RSA__c=='Closed' && (campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Type_RSA__c=='Tax' || campaignLineItemsToGet.get(iter).FinalOrderRef_RSA__r.Type_RSA__c=='General') && campaignLineItemsToGet.get(iter).GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c<=thresholdTax)
                {
                        cliBelowThresholdTax.add(campaignLineItemsToGet.get(iter));
                }       
            }
                         
            if(cliBelowThreshold.size()>0)
                UtilREST.sendStockMail(new Order__c(),cliBelowThreshold,true,true,null);
            if(cliBelowThresholdTax.size()>0)
                UtilREST.sendStockMail(new Order__c(),cliBelowThresholdTax,false,true,null);  
      
            //Set all the error codes to 100 and fill LastModifiedDate if possible
            for(REST_OrderObject roo : returned.orders){
                roo.statusCode = returned.statusCode;
                roo.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(roo.action)){
                    roo.LastModifiedDate = ordersToGet.get(roo.order.id).LastModifiedDate;
                }
            }
            for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
                rclio.statusCode = returned.statusCode;
                rclio.statusDescription = returned.statusDescription;
                if(!'Delete'.equalsIgnoreCase(rclio.action)){
                    rclio.LastModifiedDate = campaignLineItemsToGet.get(rclio.campaignLineItem.id).LastModifiedDate;
                }
            }
 
            generateBackupDocument(request,paramInfo,true);
            try{
                UtilREST.BudgetUpdater(productsForBudget,new List<ID>{Util.currentUser.ID});
            }catch(Exception e){
            }
          
        }catch (REST_ERROR_CODES.REST_Exception e){
            Database.rollback(sp);
            returned.statusCode=e.getErrorCode();
            returned.statusDescription =e.getMessage();
            ID itemFailed;
            if((e.getMessage()).contains(';')&&((e.getMessage()).split(';')[0].contains('id ')))
                    itemFailed = (e.getMessage()).split(';')[0].split('id ')[1];
            if(itemFailed!=null && e.getErrorCode() == REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND){
                for(REST_OrderObject roo : returned.orders){
                    if(roo.order.id == itemFailed){
                        roo.statusCode = returned.statusCode;
                        roo.statusDescription = returned.statusDescription;
                    }
                }
            }
                generateBackupDocument(request,paramInfo,false);
        }catch(DMLException e){
            String errorMsg ='';
            String accId;
            String ItemOrderName;
            String ItemProdId;
            
            for(Integer i = 0; i<e.getNumDMl(); i++){
                errorMsg += e.getDmlMessage(i);
                if(e.getDmlFields(i)!=null &&  e.getDmlFields(i).size()>0)
                    errorMsg += ' : ' + e.getDmlFields(i)[0].getDescribe().getLabel() + ' ';
                if(punto == 0 && preliminaryOrderToInsert.values()[e.getDmlIndex(i)]!= null && preliminaryOrderToInsert.values()[e.getDmlIndex(i)].Name != null && preliminaryOrderToInsert.values()[e.getDmlIndex(i)].AccountRef_RSA__c != null)
                {
                  accId = preliminaryOrderToInsert.values()[e.getDmlIndex(i)].AccountRef_RSA__c ;
                  ItemOrderName = preliminaryOrderToInsert.values()[e.getDmlIndex(i)].Name;
                }
                if(punto == 1 && finalOrderToInsert.values()[e.getDmlIndex(i)]!= null && finalOrderToInsert.values()[e.getDmlIndex(i)].Name != null && finalOrderToInsert.values()[e.getDmlIndex(i)].AccountRef_RSA__c != null)
                {
                  accId = finalOrderToInsert.values()[e.getDmlIndex(i)].AccountRef_RSA__c ;
                  ItemOrderName = finalOrderToInsert.values()[e.getDmlIndex(i)].Name;
                }
                if(punto == 2 && cancelledOrders.values()[e.getDmlIndex(i)]!= null && cancelledOrders.values()[e.getDmlIndex(i)].Name != null && cancelledOrders.values()[e.getDmlIndex(i)].AccountRef_RSA__c != null)
                {
                  accId = cancelledOrders.values()[e.getDmlIndex(i)].AccountRef_RSA__c ;
                  ItemOrderName = cancelledOrders.values()[e.getDmlIndex(i)].Name;
                }
                if(punto == 3 && campaignLineItemsToInsert[e.getDmlIndex(i)]!= null && campaignLineItemsToInsert[e.getDmlIndex(i)].FarmRef__c != null && campaignLineItemsToInsert[e.getDmlIndex(i)].ProductRef__c != null)
                {
                  
                  accId = campaignLineItemsToInsert[e.getDmlIndex(i)].FarmRef__c ;
                  ItemProdId = campaignLineItemsToInsert[e.getDmlIndex(i)].ProductRef__c;
                }
                if(punto == 4 && campaignLineItemsToUpdate[e.getDmlIndex(i)]!= null && campaignLineItemsToUpdate[e.getDmlIndex(i)].FarmRef__c != null && campaignLineItemsToUpdate[e.getDmlIndex(i)].ProductRef__c != null)
                {
                  accId = campaignLineItemsToUpdate[e.getDmlIndex(i)].FarmRef__c ;
                  ItemProdId = campaignLineItemsToUpdate[e.getDmlIndex(i)].ProductRef__c;
                }
                if(punto == 5 && campaignLineItemsToDelete[e.getDmlIndex(i)]!= null && campaignLineItemsToDelete[e.getDmlIndex(i)].FarmRef__c != null && campaignLineItemsToDelete[e.getDmlIndex(i)].ProductRef__c != null)
                {
                  accId = campaignLineItemsToDelete[e.getDmlIndex(i)].FarmRef__c ;
                  ItemProdId = campaignLineItemsToDelete[e.getDmlIndex(i)].ProductRef__c;
                }
                if(punto == 6 && allOrders[e.getDmlIndex(i)]!= null && allOrders[e.getDmlIndex(i)].Name != null && allOrders[e.getDmlIndex(i)].AccountRef_RSA__c != null)
                {
                  accId = allOrders[e.getDmlIndex(i)].AccountRef_RSA__c ;
                  ItemOrderName = allOrders[e.getDmlIndex(i)].Name;
                }
            } 


            
            Database.rollback(sp);
            ID itemFailed;
            String ee ='' + e;
            if((''+e).contains(';'))
                if((''+e).split(';')[0].contains('id '))
                    itemFailed = (''+e).split(';')[0].split('id ')[1];
            
             returned.statusDescription = '';
            if((''+e).contains('Attempt to change a Frozen field')){
                returned.statusCode = REST_ERROR_CODES.ERROR_ATTEMPT_TO_CHANGE_FROZEN_FIELDS;
            }else if((''+e).contains('A reason must be entered when a discretionary discount is applied')){
                returned.statusCode = REST_ERROR_CODES.ERROR_REASON_NEEDED_FOR_DISCRETIONARY_DISCOUNT;
            }else if((''+e).contains('There are Items without Stock Associated')){
                returned.statusCode = REST_ERROR_CODES.ERROR_NO_STOCK_ASSOCIATED;
                if((''+e).contains('id='))
                    if((''+e).split('id=')[1].contains('}'))
                        itemFailed = (''+e).split('id=')[1].split('}')[0];
            }else if((''+e).contains('Not Enough Stock')){
                returned.statusCode = REST_ERROR_CODES.ERROR_NO_STOCK_LEFT;
            }else{
                returned.statusCode = REST_ERROR_CODES.ERROR_UNKNOWN;
                returned.statusDescription = '' + e;
            }
            
            Account acc;
            Product2 prod;
            
            if(accId!=null && accId!='' &&ItemOrderName!=null){
            
                       acc = [SELECT name FROM Account WHERE id=:accId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' + acc.name + '\n' +'order: ' + ItemOrderName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
            if(accId!=null && ItemProdId!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                       prod = [SELECT name FROM Product2 WHERE id=:ItemProdId];
                        errorMsg = e.getDmlMessage(0)+'\n\n' + 'account: ' +acc.name + '\n' +'product: ' + prod.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
            
            
            if(returned.statusCode == REST_ERROR_CODES.ERROR_UNKNOWN)
            {
                returned.statusDescription = errorMsg;
            }
            
            returned.statusDescription =  (returned.statusCode==REST_ERROR_CODES.ERROR_UNKNOWN ? '' : (REST_ERROR_CODES.getErrorDescription(returned.statusCode)))+ returned.statusDescription;
                      
            REST_OrderObject orderFailed = new REST_OrderObject();
            List<CampaignLineItem__c>  clisFailed = new List<CampaignLineItem__c> ();
             
             
            if(itemFailed!=null){
                for(REST_OrderObject roo : returned.orders){
                    if(returned.statusCode == REST_ERROR_CODES.ERROR_NO_STOCK_LEFT){
                        if(ee.contains(roo.order.id)){
                          orderFailed=roo;
                            roo.statusCode = returned.statusCode;
                            roo.statusDescription = returned.statusDescription;
                        }else{
                            roo.statusCode = REST_ERROR_CODES.ERROR_NOT_PROCESSED;
                            roo.statusDescription = REST_ERROR_CODES.getErrorDescription(roo.statusCode);
                        }
                    }else{
                        if(roo.order.id == itemFailed){
                            roo.statusCode = returned.statusCode;
                            roo.statusDescription = returned.statusDescription;
                        }else{
                            roo.statusCode = REST_ERROR_CODES.ERROR_NOT_PROCESSED;
                            roo.statusDescription = REST_ERROR_CODES.getErrorDescription(roo.statusCode);
                        }
                    }
                }
                for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
                    if(rclio.campaignLineItem.id == itemFailed){
                        rclio.statusCode = returned.statusCode;
                        rclio.statusDescription = errorMsg;
                    }else{
                        rclio.statusCode = REST_ERROR_CODES.ERROR_NOT_PROCESSED;
                        rclio.statusDescription = REST_ERROR_CODES.getErrorDescription(rclio.statusCode);
                    }
                }
                                                  

                
            }
          if(returned.statusCode==REST_ERROR_CODES.ERROR_NO_STOCK_LEFT || returned.statusCode==REST_ERROR_CODES.ERROR_NO_STOCK_ASSOCIATED)
            returned = UtilREST.stockErrorMessages(returned);   
            generateBackupDocument(request,returned,false);
        }catch(Exception e){
            Database.rollback(sp);          
            returned.statusCode = REST_ERROR_CODES.ERROR_UNKNOWN;
            returned.statusDescription = '' + e;
            returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode) + returned.statusDescription;          
        }

        return returned; 
    }
    
    
    /**Generate Backup Document according to the system settings logging value
    *
    * @param status: false when an error happens. True if everything is ok
    * 
    *
    * None: No documents are generated.
    * Exception: Documents are generated only when an exception is thrown
    * All: A document is generated always.
    * 
    */
    private static void generateBackupDocument(String request, REST_SendLogicalEntityOrder response, boolean status){
        if((
            systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityOrder'+string.valueOf(system.now())+'_'+Util.currentUser.ID;
            
            if (status){
                documentName = documentName+'_OK';
            }
            else{
                documentName = documentName+'_ERR';
            }
            
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'SharedDocuments' AND Type = 'Document'];
            if (destFolder.size() == 1) {
                Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                insert doc;
            }
            else {
                system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
            }
        }
        else if (systemSettings__c.getvalues('RSA_REST_SVC_JSON_SAVE').Value__c!='none'){
            system.debug('Warning: Unexpected value in System Setting \'RSA_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
        }
    }
    
    
    // Example Structure
    @HttpGet
    global static REST_SendLogicalEntityOrder sendOrders()
    {
        REST_SendLogicalEntityOrder returned = new REST_SendLogicalEntityOrder();
        
        returned.orders = new List<REST_OrderObject>();
        REST_OrderObject ooToInsert = new REST_OrderObject();
        ooToInsert.action = 'Insert';
        ooToInsert.preliminaryOrderIdDevice = 6;
        ooToInsert.order = [SELECT Name, PreliminaryOrderRef_RSA__c, Status_RSA__c, Signed_RSA__c from Order__c LIMIT 1];
        ooToInsert.signature = 'BASE64 SIGNATURE';
        returned.orders.add(ooToInsert);
        
        returned.campaignLineItems = new List<REST_CampaignLineItemObject>();
        REST_CampaignLineItemObject clio = new REST_CampaignLineItemObject();
        clio.action = 'Insert';
        clio.PreliminaryOrderIdDevice = 7;
        clio.FinalOrderIdDevice = 8;
        clio.campaignLineItem = [SELECT Name, PoG__c, ProductRef__c from CampaignLineItem__c LIMIT 1];
        returned.campaignLineItems.add(clio);
        

        return returned;
    }
}