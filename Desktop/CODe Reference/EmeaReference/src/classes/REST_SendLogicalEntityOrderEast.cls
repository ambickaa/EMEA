@RestResource(urlMapping='/sendLogicalEntity/OrderEast/*')
global with sharing class REST_SendLogicalEntityOrderEast{

    private static Map<Integer,Order__c> preliminaryOrderToInsert = new Map<Integer,Order__c>();
    private static Map<Integer,Order__c> finalOrderToInsert = new Map<Integer,Order__c>();
    private static Map<Integer,Order__c> cancelledOrders = new Map<Integer,Order__c>();
    private static Map<Integer,REST_OrderObject> finalOrderObjectToInsert = new Map<Integer,REST_OrderObject>();
    private static List<Order__c> allOrders = new List<Order__c>();
    private static Map<Integer,Map<String,String>> previousOrderValues = new Map<Integer,Map<String,String>>();
    
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
        // Other caching
        TriggerOrderCalculatePrice.cacheCampaignLineItems = true;
       // TriggerOrderCalculatePrice.isOffline=true;
        /* END - Id lists for triggers map caching */
        REST_SendLogicalEntityOrder returned = paramInfo;
        
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems) 
        {
            // INI 16/03/2015
            //system.debug('ana new ' +Util.currentUser.Id );
            //system.debug('javi_01: ' + rclio.campaignLineItem.PoS__c);
            //system.debug('javi_02: ' + rclio.campaignLineItem.DistributorRef__c);
            if(rclio.campaignLineItem.PoS__c == null && rclio.campaignLineItem.DistributorRef__c != null && 'Italy'.equalsIgnoreCase(Util.currentUser.Country))
               rclio.campaignLineItem.PoS__c = rclio.campaignLineItem.DistributorRef__c;
            // FIN 16/03/2015
                        
            rclio.campaignLineItem.OwnerId=Util.currentUser.Id;
        }
        // timestamp check
        Set<ID> campaignLineItemsIDToCheck = new Set<ID>();
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){            
            if(!'Insert'.equalsIgnoreCase(rclio.action)){
                campaignLineItemsIDToCheck.add(rclio.campaignLineItem.ID);
            }
        }
        Set<ID> ordersIDToCheck = new Set<ID>();
        for(REST_OrderObject roo : returned.orders)
            {
            if(!'Insert'.equalsIgnoreCase(roo.action)){
                ordersIDToCheck.add(roo.order.ID);
            }
        }
        Map<ID,CampaignLineItem__c> campaignLineItemsToCheck = new Map<ID,CampaignLineItem__c>([SELECT LastModifiedDate FROM CampaignLineItem__c WHERE ID IN :campaignLineItemsIDToCheck]);
        Map<ID,Order__c> ordersToCheck = new Map<ID,Order__c>([SELECT LastModifiedDate FROM Order__c WHERE ID IN :ordersIDToCheck]);
        
        List<Id> accountCLIsTimestampList = new List<Id>();
        List<Id> accountCLIsDeleteList = new List<Id>();
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
            if(!'Insert'.equalsIgnoreCase(rclio.action)){
                if(campaignLineItemsToCheck.get(rclio.campaignlineItem.id) == null){
                    returned.statusCode = REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED;
                    accountCLIsDeleteList.add(rclio.campaignLineItem.FarmRef__c);
                    rclio.statusCode = returned.statusCode;
                    rclio.statusDescription = returned.statusDescription;
                }else if(rclio.campaignLineItem.LastModifiedDate != campaignLineItemsToCheck.get(rclio.campaignLineItem.id).LastModifiedDate){
                    returned.statusCode = REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH;
                    accountCLIsTimestampList.add(rclio.campaignLineItem.FarmRef__c); 
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
        
         List<Account> accountNameCLIsDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountCLIsDeleteList
                                                        ];
        List<Account> accountNameCLIsTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountCLIsTimestampList
                                                        ];
        String accounCLIsDelete = '';
        String accountCLIsTimestamp = '';
        
        for(account acc : accountNameCLIsDeleteList )
        {
            accounCLIsDelete += acc.Name +'\n';
        }
        for(account acct : accountNameCLIsTimestampList )
        {
            accountCLIsTimestamp += acct.Name +'\n';
        }
        
        if(accountCLIsTimestamp != '')
        {
            returned.statusDescription += 'Fields for the next accounts have been overwritten because of online changes: \n'+accountCLIsTimestamp ;
        }
        if(accounCLIsDelete != '')
        {
            returned.statusDescription += '\n\nFields for the next accounts have been deleted from the online: \n'+accounCLIsDelete ;            
        }  
  /*      if(returned.statusCode == REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH || returned.statusCode == REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED){
            generateBackupDocument(request,paraminfo, false);
            return returned;
        }
   */     
        List<Id> accountOrdersTimestampList = new List<Id>();
        List<Id> accountOrdersDeleteList = new List<Id>();
        for(REST_OrderObject roo : returned.orders){
            if(!'Insert'.equalsIgnoreCase(roo.action)){
                if(ordersToCheck.get(roo.order.id) == null){
                    returned.statusCode = REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED ;
                    accountOrdersDeleteList.add(roo.order.AccountRef_RSA__c);
                    roo.statusCode = returned.statusCode;
                    roo.statusDescription = returned.statusDescription;
                }else if(roo.order.LastModifiedDate != ordersToCheck.get(roo.order.id).LastModifiedDate){
                    returned.statusCode = REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH;
                    accountOrdersTimestampList.add(roo.order.AccountRef_RSA__c);
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
        }
         List<Account> accountNameOrdersDeleteList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountOrdersDeleteList
                                                        ];
        List<Account> accountNameOrdersTimestampList = [SELECT
                                                Name
                                                FROM
                                                Account
                                                WHERE id IN : accountOrdersTimestampList
                                                        ];
        String accounOrdersDelete = '';
        String accountOrdersTimestamp = '';
        
        for(account acc : accountNameOrdersDeleteList)
        {
            accounOrdersDelete += acc.Name +'\n';
        }
        for(account acct : accountNameOrdersTimestampList)
        {
            accountOrdersTimestamp += acct.Name +'\n';
        }
        
        if(accountOrdersTimestamp != '')
        {
            returned.statusDescription += 'Fields for the next accounts have been overwritten because of online changes: \n'+accountOrdersTimestamp ;
        }
        if(accounOrdersDelete != '')
        {
            returned.statusDescription += '\n\nFields for the next accounts have been deleted from the online: \n'+accounOrdersDelete ;            
        }  
        
        if(returned.statusCode == REST_ERROR_CODES.ERROR_TIMESTAMP_MISMATCH || returned.statusCode == REST_ERROR_CODES.ERROR_RECORD_PREVIOUSLY_DELETED){
            generateBackupDocument(request,paraminfo, false);
            return returned;
        }

        // End_Of    timestamp check
      
        for(REST_OrderObject roo : returned.orders){
            if('Insert'.equalsIgnoreCase(roo.action)){
                previousOrderValues.put(Integer.valueOf(roo.order.idDevice__c),new Map<String,String>{'Signed_RSA__c'=>String.valueOf(roo.order.Signed_RSA__c),'Status_RSA__c'=>roo.order.Status_RSA__c});
                roo.order.Status_RSA__c = 'Draft';
                roo.order.Signed_RSA__c = false;
                if(roo.order.recordTypeID == Util.recordType.get('Order__c:PreliminaryOrder')){//roo.preliminaryOrderIdDevice == 0){
                    preliminaryOrderToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo.order);
                }else{
                    finalOrderObjectToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo);
                    finalOrderToInsert.put(Integer.valueOf(roo.order.idDevice__c),roo.order);
                }
            }    
            
            if('Update'.equalsIgnoreCase(roo.action) && roo.order.Status_RSA__c == 'Cancelled'){
                cancelledOrders.put(Integer.valueOf(roo.order.idDevice__c), roo.order);
            }else{
                allOrders.add(roo.order);
            }            
        }
        
        for(REST_CampaignLineItemObject rclio : returned.campaignLineItems){
            if('Insert'.equalsIgnoreCase(rclio.action)){                 
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
                roo.order.Status_RSA__c = previousOrderValues.get(Integer.valueOf(roo.order.idDevice__c)).get('Status_RSA__c');
            }
            // update AllOrders

            punto = 6;

            update allOrders;
            /*OPEN New Development - Preliminary Order Edit. Orders must keep their signature if they are already signed*/
            // Signature insert for orders
            Set<ID> ordersToPdf = new Set<ID>();
            // Get all the signatures
            list<Attachment> currentSignatures = [SELECT ParentId, name from Attachment where name = 'Signature.png'];
            // Only orders' Id with signature are needed
            set<Id>signedOrders = new set<Id>();
            for (Attachment signature :currentSignatures){
                signedOrders.add(signature.ParentId);
            }
            /*CLOSE New Development - Preliminary order Edit. Orders must keep their signature if they are already signed*/
            
            List<Attachment> signaturesToInsert = new List<Attachment>();

            for(REST_OrderObject roo : returned.orders){
                if (roo.order.recordTypeID == Util.recordType.get('Order__c:PreliminaryOrder') &&
                    roo.order.Status_RSA__c == 'Closed' && 
                    roo.order.Signed_RSA__c == true && !signedOrders.contains(roo.order.Id))
                {
                    if (roo.signature != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature.png', body = EncodingUtil.base64Decode(roo.signature)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND, roo.order.id);
                    }
                        
                } else if(roo.order.recordTypeId == Util.recordType.get('Order__c:FinalOrder') && 
                        (
                           roo.order.Status_RSA__c == 'Closed' || 
                           roo.order.Status_RSA__c == 'Waiting for discount approval' || roo.order.Status_RSA__c =='Cancelled'
                        ) && 
                        roo.order.Signed_RSA__c == true && !signedOrders.contains(roo.order.Id)) 
                {
                    if (roo.signature != null)
                        signaturesToInsert.add(new Attachment(parentID = roo.order.id, name='Signature.png', body = EncodingUtil.base64Decode(roo.signature)));
                    else{
                        throw new REST_ERROR_CODES.REST_Exception(REST_ERROR_CODES.ERROR_SIGNATURE_NOT_FOUND,roo.order.id);
                    }
                }
            }

            punto = 7;

            insert signaturesToInsert;
            
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
            
            Map<ID,CampaignLineItem__c> campaignLineItemsToGet = new Map<ID,CampaignLineItem__c>([SELECT LastModifiedDate FROM CampaignLineItem__c WHERE ID IN :campaignLineItemsIDToGet]);
            Map<ID,Order__c> ordersToGet = new Map<ID,Order__c>([SELECT LastModifiedDate FROM Order__c WHERE ID IN :ordersIDToGet]);
            
            
            
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
        }
        catch(DMLException e){
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
            Boolean ValRule = false;
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
            }else if((''+e).contains('voucher line items')){
                returned.statusCode = REST_ERROR_CODES.ERROR_USER_HAS_NO_RIGHTS;
                returned.statusDescription = '' + e;
            }else if((''+e).contains('Not Enough Stock')){
                returned.statusCode = REST_ERROR_CODES.ERROR_NO_STOCK_LEFT;
            }else{
                returned.statusCode = REST_ERROR_CODES.ERROR_UNKNOWN;
                returned.statusDescription = '' + e;
            }

            if ((''+e.getMessage()).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ValRule = true;
            }       
                    
                    
           Account acc;
            Product2 prod;
            
            if(accId!=null && ItemOrderName!=null){
                       acc = [SELECT name FROM Account WHERE id=:accId];
                        errorMsg = e.getDmlMessage(0)+ '\n\n' + 'account: ' + acc.name + '\n' +'order: ' + ItemOrderName + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                    }
            if(accId!=null && ItemProdId!=null){
                if (ValRule){
                    acc = [SELECT name FROM Account WHERE id=:accId];
                    prod = [SELECT name FROM Product2 WHERE id=:ItemProdId];
                    errorMsg = 'Account: ' + acc.name + + '\n'+ 'Product: ' + prod.name + '\n\n' + (e.getMessage()!=null? (e.getMessage() + '\n'):'');
                }else{
                    acc = [SELECT name FROM Account WHERE id=:accId];
                    prod = [SELECT name FROM Product2 WHERE id=:ItemProdId];
                    errorMsg = e.getDmlMessage(0)+ '\n\n' + 'account: ' + acc.name + '\n' +'product: ' + prod.name + '\n\n' +'-Technical error detail-\n'+ System.now() +'\n'+ UserInfo.getUsername() +'\n' +(e.getCause()!=null? (e.getCause() + '\n'):'')  +(e.getMessage()!=null? (e.getMessage() + '\n'):'') +(e.getStackTraceString()!=null? (e.getStackTraceString() + '\n'):'');
                }
            }    
  
            returned.statusDescription =  (returned.statusCode==REST_ERROR_CODES.ERROR_UNKNOWN ? '' : (REST_ERROR_CODES.getErrorDescription(returned.statusCode)))+ returned.statusDescription;
            
            if(itemFailed!=null){
                for(REST_OrderObject roo : returned.orders){
                    if(returned.statusCode == REST_ERROR_CODES.ERROR_NO_STOCK_LEFT){
                        if(ee.contains(roo.order.id)){
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

            if (ValRule){
                returned.statusDescription =errorMsg;
            }
            generateBackupDocument(request,paramInfo,false);
        }catch(Exception e){
            Database.rollback(sp);
            
            returned.statusCode = REST_ERROR_CODES.ERROR_UNKNOWN;
            returned.statusDescription = '' + e;
            returned.statusDescription = REST_ERROR_CODES.getErrorDescription(returned.statusCode) + returned.statusDescription;
            
            generateBackupDocument(request,paramInfo,false);
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
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='exception' && status == false ) || 
            systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c=='all'
        ) {
            String documentName='REST_SendLogicalEntityOrder'+string.valueOf(system.currentTimeMillis())+'_'+Util.currentUser.ID;
            String logFolder=systemSettings__c.getvalues(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER').Value__c;
            
            if (status){
                documentName = documentName+'_OK';
            }
            else{
                documentName = documentName+'_ERR';
            }
            
            documentName=documentName.remove(':').remove(' ').remove('-');
            
            String body = '[REQUEST]\n'+request+'\n[RESPONSE]\n'+System.JSON.serializePretty(response);
            Blob documentBody= Blob.valueOf(body);
            list<Folder> destFolder = [SELECT Id FROM Folder WHERE DeveloperName =:logFolder AND Type = 'Document'];
            if (destFolder.size() == 1) {
                Document doc= new Document(Name = documentName , body=documentBody,developerName=documentName, IsPublic = true, FolderId=destFolder[0].Id, contentType='text/plain',type='json' );
                insert doc;
            }
            else {
                system.debug('SharedDocuments folder not found or returned too many values: ' + destFolder);
            }
        }
        else if (systemSettings__c.getvalues('EAST_REST_SVC_JSON_SAVE').Value__c!='none'){
            system.debug('Warning: Unexpected value in System Setting \'EAST_REST_SVC_JSON_SAVE\'. Expected values are \'None\', \'Exceptioin\' or \'All\'');
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
    
    // Auxiliary Entities
    global class REST_SendLogicalEntityOrder{
        public Integer statusCode;
        public String statusDescription;
        
        public List<REST_OrderObject> orders;
        public List<REST_CampaignLineItemObject> campaignLineItems;
    }

    global class REST_OrderObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        
        public Integer PreliminaryOrderIdDevice;
        
        public Order__c order;
        public String signature;
    }
    
    global class REST_CampaignLineItemObject{
        public String action;
        public Integer statusCode;
        public String statusDescription;
        
        public DateTime LastModifiedDate;
        
        public Integer PreliminaryOrderIdDevice;
        public Integer FinalOrderIdDevice;
        
        public CampaignLineItem__c campaignLineItem;
    }
}