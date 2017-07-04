public without sharing class TriggerOrderUpdateStocks implements Triggers.Handler{
    public static boolean displayIDs = false;
    static boolean passed = false;
    
    private list<Id> filterOrdersToProcess(list<Order__c> newOrdersValues, map<Id, Order__c> oldOrdersValues) {
    	list<Id> result = new list<Id>();
    	
    	for (Order__c element :newOrdersValues) {
            if(element.recordTypeID == Util.recordType.get('Order__c:FinalOrder') && 
            	(
            		(element.signed_RSA__c && !((Order__c)oldOrdersValues.get(element.id)).signed_RSA__c)) ||
            		(element.status_RSA__c == 'Cancelled' && ((Order__c)oldOrdersValues.get(element.id)).status_RSA__c == 'Closed' && element.Signed_RSA__c) 
            	)
            {
                result.add(element.id);
            }
    	}
    	
    	return result;
    }
    
    public void handle(){
        //if(passed)return;
        passed=true;
        Boolean rejectDML = false; String rejectReason = '';
        list<ID> ordersID = filterOrdersToProcess((list<Order__c>)trigger.new, (map<Id, Order__c>)trigger.oldMap);
        /*List<ID> ordersID = new List<ID>();
        for(Order__c o : (List<Order__c>)trigger.new){
            if(o.recordTypeID == Util.recordType.get('Order__c:FinalOrder') && 
            (
            	(o.signed_RSA__c && !((Order__c)trigger.oldMap.get(o.id)).signed_RSA__c)) ||
            	(o.status_RSA__c == 'Cancelled'&&((Order__c)trigger.oldmap.get(o.id)).status_RSA__c == 'Closed' && o.Signed_RSA__c) 
            ){
                ordersID.add(o.id);
            }
        }*/
        List<Order__c> orders = [
            SELECT
                (
                    SELECT
                        GlobalStock_RSA__c,
                        PersonalStock_RSA__c,
                        PersonalStock_RSA__r.User_RSA__c,
                        PoG__c,
                        ProductCatalogEntryRef__c,
                        CatalogType_RSA__c
                    FROM
                        FinalItems__r
                ),
                Type_RSA__c,
                Status_RSA__c
            FROM
                Order__c
            WHERE
                ID IN :ordersID];
                    
        Set<ID> stocksID = new Set<ID>();
        Set<ID> personalStocksID = new Set<ID>();
        for(Order__c o : orders){
            for(CampaignLineItem__c cli : o.FinalItems__r){
                if(cli.GlobalStock_RSA__c == null){
                    rejectDML = True;
                    rejectReason = 'There are Items without Stock Associated' + (displayIDs?'{id='+cli.id + '}':'');
                }else{
                    stocksID.add(cli.GlobalStock_RSA__c);
                    if(cli.CatalogType_RSA__c == 'Regular'){
                        personalStocksID.add(cli.ID);
                    }
                }
            }
        }
        if(!rejectDML){
            List<AggregateResult> aggRes = [
                SELECT
                    SUM(PoG__c) SUM_PoG,
                    ProductCatalogEntryRef__c//,
                    //GlobalStock_RSA__c
                FROM   
                    CampaignLineItem__c
                WHERE
                    GlobalStock_RSA__c in :stocksID AND
                    FinalOrderRef_RSA__r.Signed_RSA__c = True AND
                    FinalOrderRef_RSA__c NOT IN :ordersID
                    // As Cancelled orders return their stock, they mustn't be queried 
                    AND FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled'
                GROUP BY
                    ProductCatalogEntryRef__c];//,
                    //GlobalStock_RSA__c];

            List<AggregateResult> aggResPersonal = [
                SELECT 
                    SUM(PoG__c) SUM_PoG,
                    ProductCatalogEntryRef__c,
                    PersonalStock_RSA__r.User_RSA__c
                FROM
                    CampaignLineItem__c
                WHERE
                    PersonalStock_RSA__c in :personalStocksID AND
                    FinalOrderRef_RSA__r.Signed_RSA__c = True
                    // As Cancelled orders return their stock, they mustn't be queried 
                    AND FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled'
                GROUP BY
                    ProductCatalogEntryRef__c,
                    PersonalStock_RSA__r.User_RSA__c];
            Map<ID,Integer> allocated = new Map<ID,Integer>();
            Map<Set<ID>,Integer> allocatedPersonal = new Map<Set<ID>,Integer>(); // Map<{UserID,ProductCatalogEntryID},Allocated>
            for(AggregateResult ar : aggRes){
                allocated.put(
                    //new Set<ID>{
                        (ID)ar.get('ProductCatalogEntryRef__c'),
                        //(ID)ar.get('GlobalStock_RSA__c'),//},
                    Integer.valueOf(ar.get('SUM_PoG')));
            }
            for(AggregateResult ar : aggResPersonal){
                allocatedPersonal.put(
                    new  Set<ID>{
                        (ID)ar.get('User_RSA__c'),
                        (ID)ar.get('ProductCatalogEntryRef__c')},
                    Integer.valueOf(ar.get('SUM_PoG')));
            }
            Map<ID,Stock__c> stocksToUpdate = new Map<ID,Stock__c>();
            try{
            rejectReason += 'Allocated: ' + allocated;
            
            for(Order__c o : orders){
                for(CampaignLineItem__c cli : o.FinalItems__r){
                    if(o.Type_RSA__c == 'Tax'){
                        if(stocksToUpdate.get(cli.GlobalStock_RSA__c) == null){
                            stocksToUpdate.put(
                                cli.GlobalStock_RSA__c,
                                new Stock__c(
                                    id=cli.GlobalStock_RSA__c,
                                    TaxQuantity_RSA__c = (allocated.get(cli.ProductCatalogEntryRef__c)==null?0:allocated.get(cli.ProductCatalogEntryRef__c))));
                            rejectReason += '<br/>StocksToUpdate: ' + stocksToUpdate;
                            rejectReason += '<br/>CampaignLineItem: ' + cli + '<br/>';
                            if (o.Status_RSA__c != 'Cancelled'){
                            	stocksToUpdate.get(cli.GlobalStock_RSA__c).TaxQuantity_RSA__c += cli.PoG__c;
                            }
                        }
                    }else if(o.Type_RSA__c == 'Regular'){
                        if(stocksToUpdate.get(cli.GlobalStock_RSA__c) == null){
                            stocksToUpdate.put(
                                cli.GlobalStock_RSA__c,
                                new Stock__c(
                                    id=cli.GlobalStock_RSA__c,
                                    Quantity_RSA__c = (allocated.get(cli.ProductCatalogEntryRef__c)==null?0:allocated.get(cli.ProductCatalogEntryRef__c))));
                        }
                        if (o.Status_RSA__c != 'Cancelled'){
                        	stocksToUpdate.get(cli.GlobalStock_RSA__c).Quantity_RSA__c += cli.PoG__c;
                        }
                        
                        if(cli.PersonalStock_RSA__c != null){
                            if(stocksToUpdate.get(cli.PersonalStock_RSA__c) == null){
                                stocksToUpdate.put(
                                    cli.PersonalStock_RSA__c,
                                    new Stock__c(
                                        id=cli.PersonalStock_RSA__c,
                                        Quantity_RSA__c = (allocatedPersonal.get(new Set<ID>{cli.PersonalStock_RSA__r.User_RSA__c,cli.ProductCatalogEntryRef__c})==null?0:allocatedPersonal.get(new Set<ID>{cli.PersonalStock_RSA__r.User_RSA__c,cli.ProductCatalogEntryRef__c}))));
                            }
                            if (o.Status_RSA__c != 'Cancelled'){
                            	stocksToUpdate.get(cli.PersonalStock_RSA__c).Quantity_RSA__c += cli.PoG__c;
                            }
                        }
                    }
                }
            }
            //((String)null).length();
            }catch(Exception e){
            /*if(rejectDML){*/
                for(Order__c o : (List<Order__c>) trigger.new){
                    o.addError('Debug\nReason:<br/>' + rejectReason + '<br/>' + stocksToUpdate + 'e:' + e);
                }
            }
            try{
                update stocksToUpdate.values();
            }catch(Exception e){
                System.debug('TriggerOrderUpdateStocks Exception: ' + e);
                String sumOfErrors = 'Not Enough Stock for id ';
                ID itemFailed = (''+e).split(';')[0].split('id ')[1];

                for(Order__c o : orders){
                    for(CampaignLineItem__c cli : o.FinalItems__r){
                        if(cli.GlobalStock_RSA__c == itemFailed || cli.PersonalStock_RSA__c == itemFailed){
                            sumOfErrors += o.ID + ';';
                        }
                    }
                }
                for(Order__c o : (List<Order__c>) trigger.new){
                    if(sumOfErrors.contains(o.id)){
                        o.addError(sumOfErrors);
                        break;
                    }
                }
                System.debug(sumOfErrors);
                /*for(Order__c o : (List<Order__c>) trigger.new){
                    o.addError('Not Enough Stock ( ' + e + ' )');
                }*/
            }
        }
        if(rejectDML){
            for(Order__c o : (List<Order__c>) trigger.new){
                o.addError('Stocks missing\nReason:' + rejectReason );
            }
        }
    }
    public static testMethod void testHandle(){
        try{
            new TriggerOrderUpdateStocks().handle();
        }catch(Exception e){}
    }
}