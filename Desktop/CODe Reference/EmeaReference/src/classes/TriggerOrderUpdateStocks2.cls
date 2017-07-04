public without sharing class TriggerOrderUpdateStocks2 implements Triggers.Handler
{
    public static boolean displayIDs = false ;
    public static boolean fromAdmin = false ;
  
    private List<ID> filterOrdersToProcess(List<Order__c> newOrdersValues, Map<ID,Order__c> oldOrderValues)
    {
        List<ID> returned = new List<ID>();
        for(Order__c o : newOrdersValues)//Get the FINAL orders firmed that are not Cancelled or in Draft
        {
            if( o.recordTypeID == Util.recordType.get('Order__c:FinalOrder') && 
                (o.signed_RSA__c || oldOrderValues.get(o.id).signed_RSA__c) &&
                (o.status_RSA__c != 'Cancelled' || oldOrderValues.get(o.id).status_RSA__c != 'Cancelled' || o.status_RSA__c != 'Draft' || oldOrderValues.get(o.id).status_RSA__c != 'Draft')
            ){
                returned.add(o.id);
            }
        }
        return returned;
    }
    public void handle() 
    {
        Boolean rejectDML = false; String rejectReason = '';
        // This list will contain all order IDs that have to be taken into account (either new or old ones)
        List<ID> ordersID = filterOrdersToProcess((List<Order__c>)trigger.new, (Map<ID,Order__c>)trigger.oldMap);
        List<Order__c> orders = [
            SELECT
              PreliminaryOrderRef_RSA__r.Name,
              Owner.Name,
              Consigned__c,
                (   
                    SELECT
                        GlobalStock_RSA__r.Allocation_RSA__c,
                        GlobalStock_RSA__r.Quantity_RSA__c,
                        GlobalStock_RSA__r.StockLeft_RSA__c,
                        GlobalStock_RSA__c,
                        PersonalStock_RSA__c,
                        PoG__c,
                        CatalogType_RSA__c,
                        ProductName_RSA__c,
                        Consigned__c,
                        ConsignedWarehouseRef__c,
                        ProductCatalogEntryRef__r.Name,
                        ProductRef__r.Name                        
                    FROM
                        FinalItems__r
                )
            FROM
                Order__c
            WHERE
                ID IN :ordersID               
                ];
                
        Set<ID> globalStocksID = new Set<ID>();
        Set<ID> personalStocksID = new Set<ID>();
        Set<ID> whStocksID = new Set<ID>();
        
        for(Order__c o : orders){
          if(!o.Consigned__c)
          {    
            for(CampaignLineItem__c cli : o.FinalItems__r){
                  if(cli.GlobalStock_RSA__c == null){
                      rejectDML = True;
                      rejectReason = 'There are Items without Stock Associated' + (displayIDs?'{id='+cli.id + '}':'');
                  }else{
                      globalStocksID.add(cli.GlobalStock_RSA__c);
                      if((cli.CatalogType_RSA__c == 'Feb Receipt' ||cli.CatalogType_RSA__c == 'Regular') && cli.PersonalStock_RSA__c != null){
                          personalStocksID.add(cli.PersonalStock_RSA__c);
                      }
                  }
              }
          }else
          {
            for(CampaignLineItem__c cli : o.FinalItems__r){
                  if(cli.ConsignedWarehouseRef__c == null){
                      rejectDML = True;
                      rejectReason = 'There are Items without Stock Associated' + (displayIDs?'{id='+cli.id + '}':'');
                  }else{
                    whStocksID.add(cli.ConsignedWarehouseRef__c);
                  }
              }  
          }
        }
        if(!rejectDML)
        {
            try
            {
                if(globalStocksID.size()>0)
                  updateStocks(globalStocksID,personalStocksID);
                if(whStocksID.size()>0)
                  updateWarehouseStock(whStocksID);
                
            }catch(Exception e){
                System.debug('TriggerOrderUpdateStocks Exception: ' + e);
                String sumOfErrors = 'Not Enough Stock for id ';
                ID itemFailed = (''+e).split(';')[0].split('id ')[1];
                        
                for(Order__c o : orders){
                    for(CampaignLineItem__c cli : o.FinalItems__r){
                        if(cli.GlobalStock_RSA__c == itemFailed || cli.PersonalStock_RSA__c == itemFailed || cli.ConsignedWarehouseRef__c == itemFailed){
                            sumOfErrors += o.ID + ';';
                        }
                    }
                }
                
                if(!fromAdmin)            
                  for(Order__c o : (List<Order__c>) trigger.new){
                      if(sumOfErrors.contains(o.id)){
  
                          o.addError(sumOfErrors);
                          break;
                      }
                  }
            }
        } 
        if(rejectDML){
            for(Order__c o : (List<Order__c>) trigger.new){
                o.addError('Stocks missing\nReason:' + rejectReason );
            }
        }
    }
    public static void updateStocks(Set<ID> paramGlobalStockIDs, Set<ID> paramPersonalStockIDs)
    {
      
      Country__c con = [SELECT ID FROM Country__c WHERE Name='South Africa' FOR UPDATE];
      Set<ID> stocksEmpty = new Set<Id>();
      
      if(paramGlobalStockIDs.size()>0)
        stocksEmpty.addAll(paramGlobalStockIDs);
      
        List<AggregateResult> aggRes = [
            SELECT
                SUM(PoG__c) SUM_PoG,
                GlobalStock_RSA__c,
                PersonalStock_RSA__c,
                CatalogType_RSA__c               
            FROM
                CampaignLineItem__c
            WHERE
                (
                    GlobalStock_RSA__c in :paramGlobalStockIDs 
                )AND
                FinalOrderRef_RSA__r.Signed_RSA__c = True AND
                FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled'
                AND FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'
                AND Consigned__c!=true
            GROUP BY
                GlobalStock_RSA__c,
                PersonalStock_RSA__c,
                CatalogType_RSA__c
            ];
            
        Map<ID,Stock__c> stocksToUpdate = new map<ID,Stock__c>();
        //If no rows are returned, quantity should be 0
        if (aggRes.size() == 0){
          for (Id i:paramGlobalStockIDs){
            stocksToUpdate = addStock(
              stocksToUpdate,
              i,
              0,
              false //irrelevant. Quantity is 0 for Tax and Regular
            );
          }
          /*for (Id i:paramPersonalStockIDs){
            stocksToUpdate = addStock(
              stocksToUpdate,
              i,
              0,
              true //irrelevant. Quantity is 0 for Tax and Regular
            );
          }*/         
        }
        
        
        for(AggregateResult ar : aggRes)
        {          
            // If the GlobalStock is Set
            if(ar.get('GlobalStock_RSA__c') != null)
            {
                stocksToUpdate = addStock(
                    stocksToUpdate, 
                    (ID)ar.get('GlobalStock_RSA__c'), 
                    Integer.valueOf(ar.get('SUM_PoG')),
                    ((String)ar.get('CatalogType_RSA__c')).equalsIgnoreCase('Regular') || ((String)ar.get('CatalogType_RSA__c')).equalsIgnoreCase('Feb Receipt') 
                );
                 stocksEmpty.remove((ID)ar.get('GlobalStock_RSA__c'));
            }
            // If the PersonalStock is Set
            /*if(ar.get('PersonalStock_RSA__c') != null)
            {
                stocksToUpdate = addStock(
                    stocksToUpdate,
                    (ID)ar.get('PersonalStock_RSA__c'),
                    Integer.valueOf(ar.get('SUM_PoG')),
                    ((String)ar.get('CatalogType_RSA__c')).equalsIgnoreCase('Regular') || ((String)ar.get('CatalogType_RSA__c')).equalsIgnoreCase('Feb Receipt')
                );
            }*/
        }  
        
        if(stocksEmpty.size()>0)
        {
          for (Id i:stocksEmpty){
            stocksToUpdate = addStock(
              stocksToUpdate,
              i,
              0,
              false //irrelevant. Quantity is 0 for Tax and Regular
            );
          }
        }
          
        update stocksToUpdate.values();
    }
    private static Map<ID,Stock__c> addStock(Map<ID,Stock__c> paramStocks, ID paramStockID, Integer paramQuantity, Boolean paramIsRegular)
    {
        if(paramStocks.get(paramStockID) == null)
        {
            paramStocks.put(paramStockID, new Stock__c(ID = paramStockID, Quantity_RSA__c = 0, TaxQuantity_RSA__c = 0));
        }
        Stock__c temp = paramStocks.get(paramStockID);
        if(paramIsRegular)
        {
            if (paramQuantity != null)
              temp.Quantity_RSA__c += paramQuantity;
        }
        else
        {
          if (paramQuantity != null)
              temp.TaxQuantity_RSA__c += paramQuantity;
        }
        paramStocks.put(paramStockID, temp);
        return paramStocks;
    }
    
    
    public static void updateWarehouseStock(Set<ID> paramWHStockIDs)
    {
      Set<ID> stocksEmpty = new Set<Id>();
      
      if(paramWHStockIDs.size()>0)
        stocksEmpty.addAll(paramWHStockIDs);
            
      List<AggregateResult> aggRes = [
            SELECT
                SUM(PoG__c) SUM_PoG,
                ConsignedWarehouseRef__c
            FROM
                CampaignLineItem__c
            WHERE
                ConsignedWarehouseRef__c in :paramWHStockIDs 
                AND FinalOrderRef_RSA__r.Signed_RSA__c = True 
                AND FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled'
                AND FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'
                AND Consigned__c=true
                AND CatalogType_RSA__c='Regular'
            GROUP BY
                ConsignedWarehouseRef__c               
            ];
                
    Map<ID,ConsignmentWarehouse__c> stocksToUpdate = new map<ID,ConsignmentWarehouse__c>();
        
        if (aggRes.size() == 0){
          for (Id i:paramWHStockIDs){
            stocksToUpdate = addWHStock(
              stocksToUpdate,
              i,
              0
            );
          }
        }              
        
        for(AggregateResult ar : aggRes)
        {
            if(ar.get('ConsignedWarehouseRef__c') != null)
            {
                stocksToUpdate = addWHStock(
                    stocksToUpdate, 
                    (ID)ar.get('ConsignedWarehouseRef__c'), 
                    Integer.valueOf(ar.get('SUM_PoG'))
                );
               stocksEmpty.remove((ID)ar.get('ConsignedWarehouseRef__c'));
                
            }
        }
        
        
        if(stocksEmpty.size()>0)
        {
          for (Id i:stocksEmpty){
            stocksToUpdate = addWHStock(
              stocksToUpdate,
              i,
              0
            );
          }
        }
        
        
      update stocksToUpdate.values();      
    }    
    
    private static Map<ID,ConsignmentWarehouse__c> addWHStock(Map<ID,ConsignmentWarehouse__c> paramStocks, ID paramStockID, Integer paramQuantity)
    {
        if(paramStocks.get(paramStockID) == null)
        {
            paramStocks.put(paramStockID, new ConsignmentWarehouse__c(ID = paramStockID, Consumed__c = 0));
        }
        ConsignmentWarehouse__c temp = paramStocks.get(paramStockID);
        if (paramQuantity != null)
              temp.Consumed__c += paramQuantity;
        paramStocks.put(paramStockID, temp);
        
        return paramStocks;
    }
}