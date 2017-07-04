public with sharing class OrderDetailExtensions   {

    public String orders { get; set; }

    public Order__c OrderRecord  { get; set; }
    public ID OrderId  {get; set;}
    public List<CampaignLineItem> OrderProducts {get; set;}
    public PageReference returned;
    public Boolean isFinal {get;set;}
    public Boolean isConsigned {get;set;}
    public Boolean editMode {get;set;}
    public Boolean showEditDelete {get;set;}
    public Boolean showSwitcher {get;set;}
    public Boolean reloadPage {get;set;}
    public Map<Id, String> prodNames = new map <Id,String>();
    // Map for summarized quantities for table footer in Visualforce Component OrderProducts
    public Map<String, Decimal> Map_Summarized_Order_Fields {get; set;}
    
    public OrderDetailExtensions() {
    
        init();
    }
    
    public void init()
    {
        editMode=false;
        showEditDelete=true;
        OrderID = (ID) Util.urlParameters.get('id');
        OrderProducts = new List<CampaignLineItem>();
        isFinal=false;
        isConsigned=false; 
        showSwitcher=false;
        
        returned= new PageReference('/apex/OrderDetail?id=' +OrderId );
      
        OrderRecord=[ SELECT ID, CreatedDate, Name, AccountRef_RSA__c,Type_RSA__c, OwnerId, Status_RSA__c, PreliminaryOrderRef_RSA__c,
                     RecordType.Name, isIrrigated_RSA__c, Consigned__c, Signed_RSA__c FROM Order__c WHERE ID=:OrderId];
        
        if(OrderRecord.Consigned__c)
            isConsigned=true;
            
  
                        
        if(OrderID !=null)
        {    
            if(OrderRecord.RecordType.Name=='Final Order') isFinal=true; 
            OrderProducts=(OrderRecord.RecordType.Name == 'Final Order'?finalItems(OrderID):preliminaryItems(OrderID));
            
            if(OrderRecord.RecordType.Name!='Final Order')
            {
                for(CampaignLineItem cli: orderProducts)
                {
                    if(cli.record.FinalOrderRef_RSA__c==null)
                    {
                        showEditDelete=true;
                        break;
                    }
                }
            }
            List<Order__c> relatedFinals=new List<Order__c>();
            if(OrderRecord.RecordType.Name !='Final Order')
                relatedFinals=[SELECT ID FROM Order__c WHERE PreliminaryOrderRef_RSA__c=:OrderRecord.id];
                
            if(OrderRecord.Status_RSA__c.equalsIgnoreCase('Draft') && !OrderRecord.Signed_RSA__c && !editMode && OrderRecord.RecordType.Name !='Final Order' && relatedFinals.Size()==0 )
                showSwitcher=true;                  
            //Util.addWarningMessage('isIrrigated'+orderRecord.isirrigated_RSA__c+'Status'+OrderRecord.Status_RSA__c+'signed'+OrderRecord.Signed_RSA__c+'Po'+OrderRecord.PreliminaryOrderRef_RSA__c+'em'+editMode+'ss'+showSwitcher);
        }
        //CR-00000450
        getMapSummarizedOrderFields(OrderProducts);
        //End //CR-00000450
        
    }
    
    public OrderDetailExtensions (ApexPages.StandardController stdController)
    {
        this.OrderRecord=(Order__c) stdController.getRecord();                
    }
    
    public PageReference doSwitch(){
        /*OrderRecord=[ SELECT ID, CreatedDate, Name, AccountRef_RSA__c,Type_RSA__c, OwnerId, Status_RSA__c, PreliminaryOrderRef_RSA__c,
                     RecordType.Name, isIrrigated_RSA__c, Consigned__c, Signed_RSA__c FROM Order__c WHERE ID=:OrderRecord.id];    
        OrderProducts=preliminaryItems(OrderRecord.id);*/               
        OrderRecord.isIrrigated_RSA__c = !OrderRecord.isIrrigated_RSA__c;
        List<CampaignLineItem__C> cliToUpdate= new List<CampaignLineItem__c>();
        for(CampaignLineItem clio : OrderProducts){
            clio.record.Ultrashort_Irrigation_RSA__c=!clio.record.Ultrashort_Irrigation_RSA__c;
            clitoUpdate.add(clio.record);
        }   
        Savepoint sp = Database.setSavepoint();
        try{
            update cliToUpdate;
            update OrderRecord;
            init();
            return null;
        }catch (Exception e){
                Util.addErrorMessage('ERROR: '+e);
                Database.rollback(sp);  
                init(); 
                reloadPage=false;                       
                return null;
        }
    }

    public PageReference Save()
    {
        Savepoint sp = Database.setSavepoint();
        
        TriggerOrderUpdateBudgetOnline.fromREST=true;
        TriggerCampaignLineItemUpdateStock.fromAdmin=true;
        TriggerOrderUpdateStocks2.fromAdmin=true;
        reloadPage=true;
        Boolean stockError=false;
        
        List<ID> productsId = new List<ID> ();
        List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
        List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
        List<CampaignLineItem> OrderProducts2 = new List<CampaignLineItem>();
        
        Set<Id> ProductIds =  new Set<Id>();
        Set<ID> cliIds = new Set<Id> ();
                            
        Map<String,Integer> proStockUsed = new Map<String, Integer>();
        Map<String,Integer> proStockAllocated = new Map<String,Integer>();
        Map<Id,String> prodNames = new Map<Id,String>(); // ProductID vs ProductName 
        Map<Id,String> hybNames = new Map<Id,String>(); // ProductCatalogEntryID vs HybridName
        Map<Id,String> prodVsHyb = new Map<Id,String>(); // ProductID vs HybridName
        Set<Id> pceToCheck = new Set<Id>();
                
        User Manager;        
                
        try{            
            for(CampaignLineItem cli : OrderProducts)
            {
                if(cli.lookupValue.id!=null && cli.lookupValue.id!='')
                {   OrderProducts2.add(cli);
                    ProductIds.add(cli.lookupValue.id);
                    cliIds.add(cli.record.ID);
                }
            }
            if (isFinal && isConsigned){system.debug('***** 1 isFinal && isConsigned');
                Map<Id,Id> prodVsPCE = new Map<Id,Id>();                
                for(ProductCatalogEntry__c pce: [SELECT ID, ProductRef__c, ProductRef__r.Name, prodDesc__c FROM ProductCatalogEntry__C 
                                                WHERE ProductRef__c in:ProductIds AND ProductCatalogRef__c in:UtilREST.activeRegularCatalogRSA]){
                    hybNames.put(pce.Id, pce.prodDesc__c);
                    prodVsHyb.put(pce.ProductRef__c, pce.prodDesc__c);
                    prodNames.put(pce.ProductRef__c,pce.ProductRef__r.Name);
                    pceToCheck.add(pce.ID);
                    prodVsPCE.put(pce.ProductRef__c, pce.id);   
                }
                for(CampaignLineItem cli : OrderProducts){
                    if(cli.lookupValue.id!=null && cli.lookupValue.id!='' && cli.record.ID==null)
                        cli.record.ProductCatalogEntryRef__c=prodVsPCE.get(cli.lookupvalue.Id);
                }                               
            }
                        
            else if(isFinal && (OrderRecord.Type_RSA__c.equalsIgnoreCase('Tax')||  OrderRecord.Type_RSA__c.equalsIgnoreCase('General')))
            {system.debug('***** 1 isFinal && Tax OR General');
                Manager=[SELECT Manager.ManagerID FROM User WHERE Id=:orderRecord.OwnerID LIMIT 1];
                for(ProductCatalogEntry__c pce: [SELECT ID, ProductRef__c, ProductRef__r.Name, prodDesc__c FROM ProductCatalogEntry__C 
                                                WHERE ProductRef__c in:ProductIds AND ProductCatalogRef__c in:UtilREST.activeTaxCatalogRSA])    
                {
                    hybNames.put(pce.Id, pce.prodDesc__c);
                    prodVsHyb.put(pce.ProductRef__c, pce.prodDesc__c);
                    prodNames.put(pce.ProductRef__c,pce.ProductRef__r.Name);
                    pceToCheck.add(pce.ID); 
                }
            }else if(isFinal && (OrderRecord.Type_RSA__c.equalsIgnoreCase('Regular') || OrderRecord.Type_RSA__c.equalsIgnoreCase('Feb Receipt')))
            {system.debug('***** 1 isFinal && Regular OR FebReceipt');
                Manager=[SELECT ManagerID FROM User WHERE Id=:orderRecord.OwnerID LIMIT 1];
                for(ProductCatalogEntry__c pce: [SELECT ID, ProductRef__c, ProductRef__r.Name, prodDesc__c FROM ProductCatalogEntry__C 
                                                WHERE ProductRef__c in:ProductIds AND ProductCatalogRef__c in:UtilREST.activeRegularCatalogRSA])                    
                {
                    hybNames.put(pce.Id, pce.prodDesc__c);
                    prodVsHyb.put(pce.ProductRef__c, pce.prodDesc__c);
                    prodNames.put(pce.ProductRef__c, pce.ProductRef__r.Name);                       
                    pceToCheck.add(pce.ID);                         
                }                   
            }
            
            if(isFinal){system.debug('*****2 isFinal ');
                for(Id pId : ProductIds){
                    proStockUsed.put(prodvsHyb.get(pID),0);
                }
                if(isConsigned){system.debug('*****2 isCOnsigned ');
                    
                    for(ID pceId : pceToCheck){
                        proStockAllocated.put(hybNames.get(pceId),0);    
                    }               
                    Set<String> hybToCheck = proStockAllocated.keySet();    
                    for(ConsignmentWarehouse__c cw:[SELECT Id, Allocation__c, Name FROM ConsignmentWarehouse__c 
                                            WHERE name in:hybToCheck AND UserRef__c=:orderRecord.OwnerId]){
                        proStockAllocated.put(cw.Name,(Integer)cw.Allocation__c);
                    }

                                        
                    for(AggregateResult ar: [SELECT SUM(PoG__c) SUM_PoG, ConsignedWarehouseRef__r.Name hyb FROM CampaignLineItem__c  
                                             WHERE ProductCatalogEntryRef__c in :pceToCheck AND (NOT ID in:cliIds ) AND FinalOrderRef_RSA__r.Signed_RSA__c = True 
                                             AND FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled' AND ConsignedWarehouseRef__r.UserRef__c=:OrderRecord.OwnerId
                                             AND CatalogType_RSA__c=:orderRecord.Type_RSA__c AND Consigned__c=true
                                             GROUP BY ConsignedWarehouseRef__r.Name, CatalogType_RSA__c]){
                        proStockUsed.put((String)ar.get('hyb'),Integer.valueOf(ar.get('SUM_PoG')));
                     }                                      
                        
                }else{  system.debug('*****2 NotConsigned ');
                    set<id> pceWithStock = New set<Id>();
                    for(Stock__c stk: [SELECT Id, HybridRef__r.TaxAllocation__c, HybridRef__r.Allocation__c, HybridName__c, ProductCatalogEntryRef_RSA__c
                                       FROM Stock__c WHERE ProductCatalogEntryRef_RSA__c in:pceToCheck
                                       AND User_RSA__c=:((orderRecord.Type_RSA__c.equalsIgnoreCase('Tax') || orderRecord.Type_RSA__c.equalsIgnoreCase('General'))?Manager.Manager.ManagerID:Manager.ManagerID) ])
                    {
                        if(orderRecord.Type_RSA__c.equalsIgnoreCase('Tax') || orderRecord.Type_RSA__c.equalsIgnoreCase('General'))
                            proStockAllocated.put(stk.HybridName__c,(Integer)stk.HybridRef__r.TaxAllocation__c);
                        else
                            proStockAllocated.put(stk.HybridName__c,(Integer)stk.HybridRef__r.Allocation__c);                   
                        pceWithStock.add(stk.ProductCatalogEntryRef_RSA__c);
                    }
                    
                    list <Stock__c> stockToAdd = new List<Stock__c>();
                    for(ID pceId : pceToCheck)
                    {
                        if(!pceWithStock.contains(pceID))
                        {
                            stockToAdd.add(new Stock__c(Allocation_RSA__c=0,TaxAllocation_RSA__c=0,ProductCatalogEntryRef_RSA__c=pceId,User_RSA__c=(orderRecord.Type_RSA__c.equalsIgnoreCase('Tax') || orderRecord.Type_RSA__c.equalsIgnoreCase('General'))?Manager.Manager.ManagerID:Manager.ManagerID));
                            if(!proStockAllocated.containsKey(hybNames.get(pceID)))
                                proStockAllocated.put(hybNames.get(pceId),0);
                        }
                    }
                                        
                    insert stockToAdd;
                    
                    for(AggregateResult ar:  [
                        SELECT
                            SUM(PoG__c) SUM_PoG,
                            GlobalStock_RSA__r.HybridRef__r.Name hyb
                        FROM
                            CampaignLineItem__c
                        WHERE
                            ProductCatalogEntryRef__c in :pceToCheck AND
                            (NOT ID in:cliIds ) AND
                            FinalOrderRef_RSA__r.Signed_RSA__c = True AND
                            FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled' AND
                            FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'
                            AND GlobalStock_RSA__r.User_RSA__c=:((orderRecord.Type_RSA__c.equalsIgnoreCase('Tax') || orderRecord.Type_RSA__c.equalsIgnoreCase('General'))?Manager.Manager.ManagerID:Manager.ManagerID)
                            AND CatalogType_RSA__c=:orderRecord.Type_RSA__c
                        GROUP BY
                            GlobalStock_RSA__r.HybridRef__r.Name,
                            CatalogType_RSA__c
                        ])
                     {
                        proStockUsed.put((String)ar.get('hyb'),Integer.valueOf(ar.get('SUM_PoG')));
                     }
                }   
                for(CampaignLineItem cli : OrderProducts)
                {
                    if(cli.lookupValue.id!=null && cli.lookupValue.id!='')
                    {   
                        if(cli.record.POG__c>(proStockAllocated.get(prodVsHyb.get(cli.lookupValue.id))-proStockUsed.get(prodVsHyb.get(cli.lookupValue.id))))
                        {
                            // STOCK NOK
                            Util.addErrorMessage('Not enough Stock for '+prodNames.get(cli.lookupValue.Id) +' (Requested: '+cli.record.POG__c +', Available: '+(proStockAllocated.get(prodVsHyb.get(cli.lookupValue.id))-proStockUsed.get(prodVsHyb.get(cli.lookupValue.id)))+')'); 
                            cli.record.PoG__c=0;
                            stockError=true;    
                        }
                        else
                        {
                            // STOCK OK
                            proStockUsed.put(prodVsHyb.get(cli.lookupValue.id),(proStockUsed.get(prodVsHyb.get(cli.lookupValue.id))+(Integer)cli.record.PoG__c));
                        }
                    }
                }
                
                if(stockError)
                    reloadPage=false;           
            }
                
            Order__c PreliminaryOrder = new Order__c();                 
            if(OrderRecord.PreliminaryOrderRef_RSA__c!=null)
            {
                PreliminaryOrder= [SELECT Id, Status_RSA__C FROM Order__c WHERE Id=:OrderRecord.PreliminaryOrderRef_RSA__c];
                PreliminaryOrder.Status_RSA__c='Draft'; 
                update PreliminaryOrder;
            }                   
            
            OrderRecord.Status_RSA__c='Draft';
            update OrderRecord;
            
            //RESET old Product if Product is changed
            Map<Id,Decimal> newPog = new Map<Id, Decimal>();
                            
            for(CampaignLineItem oi : OrderProducts2)
            {
                if(oi.lookupValue.id!=null && oi.lookupValue.id!=oi.record.ProductRef__c && oi.record.ProductRef__c!=null)
                {
                    productsId.add(oi.record.ProductRef__c);
                    newPog.put(oi.record.Id,oi.record.Pog__c);
                    oi.record.PoG__c=0;
                    toModify.add(oi.record);
                }                   
            }   
            
            update toModify;
            toModify.clear();               
            
            for(CampaignLineItem oi : OrderProducts2)
            {
                if(oi.lookupValue.id!=null && oi.lookupValue.id!=oi.record.ProductRef__c && oi.record.ProductRef__c!=null)
                {
                    productsId.add(oi.record.ProductRef__c);
                    if(newPog.get(oi.record.id)!=null)
                        oi.record.Pog__c=newPog.get(oi.record.id);
                    oi.record.ProductRef__c=null;
                    oi.record.ProductCatalogEntryRef__c=null;
                }
                
            }     
                                          
                            
            for(CampaignLineItem oi : OrderProducts2)
            {
                if(isFinal || (!isFinal && oi.record.FinalOrderRef_RSA__c==null))
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != ''){
                        oi.record.ProductRef__c = oi.lookupValue.id;
                        (oi.record.id == null?toInsert:toModify).add(oi.record);
                    }
                productsId.add(oi.record.ProductRef__c);
            }
            insert toInsert; 
            toModify.addAll(toInsert);
            update toModify; 
            
            if(OrderRecord.PreliminaryOrderRef_RSA__c!=null)                        
            {
                    PreliminaryOrder.Status_RSA__c='Closed';
                    update PreliminaryOrder;              
            }
              
            OrderRecord.Status_RSA__c='Closed';
            update OrderRecord;
            
            try{
                UtilREST.BudgetUpdater(productsId,new List<ID>{OrderRecord.OwnerId});                               
            }catch (Exception e)
            {
                
            }                
        }catch(Exception e){
                Util.addErrorMessagE('ERROR: '+e);
                Database.rollback(sp);
                init(); 
                reloadPage=false;                       
                return null;
       }
        editMode=false;
        init();
        return null;
    }
    
    public PageReference DeleteAll()
    {           
        List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
        List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
        List<ID> productsId = new List<ID> ();              
        
        TriggerOrderUpdateBudgetOnline.fromREST=true;
        reloadPage=false;
        
        Savepoint sp = Database.setSavepoint();         
            
        try{                
            if(isFinal)
            {                   
                Order__c PreliminaryOrder = new Order__c();                 
                if(OrderRecord.PreliminaryOrderRef_RSA__c!=null)
                {
                    PreliminaryOrder= [SELECT Id, Status_RSA__C FROM Order__c WHERE Id=:OrderRecord.PreliminaryOrderRef_RSA__c];
                    PreliminaryOrder.Status_RSA__c='Draft'; 
                    update PreliminaryOrder;
                }                   
                OrderRecord.Status_RSA__c='Draft';
                update OrderRecord;
        
                for(CampaignLineItem oi : OrderProducts)
                {
                    if(oi.checked)
                    {
                       oi.record.Agreed__c=0;   
                       oi.record.Pog__c=0;      
                       toModify.add(oi.record);                     
                    }
                    productsId.add(oi.record.ProductREf__c);
                }
                update toModify;
                                   
                OrderRecord.Status_RSA__c='Closed'; 
                
                update OrderRecord;               
                delete toModify;
                
                if(OrderRecord.PreliminaryOrderRef_RSA__c!=null)                        
                {
                    PreliminaryOrder.Status_RSA__c='Closed';
                    update PreliminaryOrder;              
                }
                
                try{
                    UtilREST.BudgetUpdater(productsId,new List<ID>{OrderRecord.OwnerId});                               
                }catch (Exception e)                    
                {
                }   
                
            }else
            {
                OrderRecord.Status_RSA__c='Draft';
                update OrderRecord;
        
                for(CampaignLineItem oi : OrderProducts)
                {
                    if(oi.checked && oi.record.FinalOrderRef_RSA__c==null)
                    {
                       oi.record.Agreed__c=0;       
                       toModify.add(oi.record);                     
                    }
                    productsId.add(oi.record.ProductREf__c);                        
                }
                update toModify;
                delete toModify;                                       
                OrderRecord.Status_RSA__c='Closed';                     
                update OrderRecord;               
            }                   
            try{
                    UtilREST.BudgetUpdater(productsId,new List<ID>{OrderRecord.OwnerId});                               
            }catch (Exception e)               
            {
            }   
         
        }catch(Exception e){
                Util.addErrorMessagE('ERROR: '+e);          
                Database.rollback(sp);                          
                ApexPages.addMessages(e);
                init();
                return null;
       }   
        reloadPage=true;  
        return null;
    }    
    
    public PageReference Cancel()
    {   
        init(); 
        editMode=false; 
        showEditDelete=true;
        return null;
    }

    public PageReference Edit()
    {   
        showEditDelete=false;
        editMode=true;  
        return null;
    }    
    
    public PageReference Add()
    {
        List<Id> prodIds = new List<Id>();
        
            for(CampaignLineItem cli:  OrderProducts)
            {
                if(cli.lookupValue.id!=null && cli.lookupValue.id!='')
                    prodIds.add(cli.lookupValue.id);
            }
     
            
            for(Product2 prod: [SELECT ID, Name FROM Product2 WHERE id in: prodIds])
            {
                prodNames.put(prod.Id,prod.Name);           
            }  
            
            for(CampaignLineItem cli:  OrderProducts)
            {
                if(cli.lookupValue.id!=null && cli.lookupValue.id!='' && cli.lookupvalue.text==null)
                {
                    cli.lookupvalue.text=prodNames.get(cli.lookupvalue.id);
                }
            }
                        
            editMode=true;
            showEditDelete=true;
            
            Campaign cCorn = currentCornCampaign(OrderRecord.OwnerId, Date.valueOf(OrderRecord.CreatedDate));
            if(cCorn.Id==null)
            {   
                Util.addErrorMessage('Order owner does not have a valid campaign for the date the order was created');
                editMode=false;
                showEditDelete=true;            
            }
            else
            {   
                    
                OrderProducts.add(new CampaignLineItem(new CampaignLineItem__c(OwnerId=OrderRecord.OwnerId, RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                        FarmRef__c = OrderRecord.AccountRef_RSA__c, CatalogType_RSA__c = OrderRecord.Type_RSA__c, CampaignRef__c = cCorn.ID, shouldCopy_RSA__c=true, PlantingDensity__c='0',
                        Forecast__c=0, Pog__c=0, Agreed__c=0, Consigned__c=isConsigned, PreliminaryOrderRef_RSA__c=(isFinal?OrderRecord.PreliminaryOrderRef_RSA__c:OrderRecord.Id),
                        Type__c = 'Charged',Ultrashort_Irrigation_RSA__c = OrderRecord.isIrrigated_RSA__c,  
                        FinalORderRef_RSA__c=(isFinal?OrderRecord.Id:null))));
            }
        return null;
    } 
    
     private static Campaign currentCornCampaign (Id userId, date cDate)
     {
         
         Campaign currentCornCampaign= new Campaign();
     
         for(Campaign c : [SELECT ID, YearV2__c, Name, TrialPCMRef__c, GiveAwayPCMRef__c, CompetitorPCMRef__c , TaxSalesPCMRef_RSA__c, 
                                      SalesPCMRef__c, DivisionRef__r.name                      
                              FROM Campaign WHERE StartDate<=:cDate AND EndDate>:cDate AND
                              OwnerId = :userId  AND DivisionRef__r.Name = 'Corn'
                              LIMIT 1])
                        {
                            currentCornCampaign = c;
                        }
          
        
          return currentCornCampaign ;

     }
     private static List<CampaignLineItem> finalItems (Id oId)
     {
        
        List<CampaignLineItem> cliList = new List<CampaignLineItem>();
        for(CampaignLineItem__c cli: [SELECT ID,LastModifiedBy.Name, LastModifiedDate, Ultrashort_Irrigation_RSA__c, DistributorRef__c, PlantingDensity__c, PoS__c, 
                                            Name,ProductRef__c,ProductRef__r.DivisionRef__c, ProductRef__r.Name, ProductRef__r.ProductTreatment__c , Agreed__c, Pog__c, 
                                            FarmRef__c, Price__c, CatalogType_RSA__c, GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c, GlobalStock_RSA__r.HybridRef__r.StockLeft__c,
                                            ProductCatalogEntryRef__r.Price__c,ProductCatalogEntryRef__r.PriceOld__c, ProductCatalogEntryRef__r.NUM_PriceGeneral__c,Forecast__c, ConsignedWarehouseRef__r.StockLeft__c,
                                            PreliminaryOrderRef_RSA__r.Name, FinalOrderRef_RSA__r.Name, GlobalStock_RSA__r.TaxStockLeft_RSA__c, GlobalStock_RSA__r.StockLeft_RSA__c                                        
                                            FROM CampaignLineItem__c WHERE FinalOrderRef_RSA__C=:oId])
        {
                
               cliList.add(new CampaignLineItem(cli));
        }
        return cliList;
     }

     public static List<CampaignLineItem> preliminaryItems (Id oId)
     {
        
        List<CampaignLineItem> cliList = new List<CampaignLineItem>();
        for(CampaignLineItem__c cli: [SELECT ID,LastModifiedBy.Name, LastModifiedDate, Ultrashort_Irrigation_RSA__c, DistributorRef__c, PlantingDensity__c, PoS__c, 
                                            Name,ProductRef__c,ProductRef__r.DivisionRef__c, ProductRef__r.Name, ProductRef__r.ProductTreatment__c , Agreed__c, Pog__c, 
                                            FarmRef__c, Price__c, CatalogType_RSA__c, GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c, GlobalStock_RSA__r.HybridRef__r.StockLeft__c,
                                            ProductCatalogEntryRef__r.Price__c,ProductCatalogEntryRef__r.PriceOld__c, ProductCatalogEntryRef__r.NUM_PriceGeneral__c,Forecast__c,ConsignedWarehouseRef__r.StockLeft__c,
                                            PreliminaryOrderRef_RSA__r.Name, FinalOrderRef_RSA__r.Name, GlobalStock_RSA__r.TaxStockLeft_RSA__c, GlobalStock_RSA__r.StockLeft_RSA__c                                        
                                            FROM CampaignLineItem__c WHERE PreliminaryOrderRef_RSA__c=:oId])
        {       
               cliList.add(new CampaignLineItem(cli));
        }
        return cliList;
        
     }

    public Boolean getIsAdmin()
    {
        return UtilREST.hasAdminPermissionsRSA;     
    }

    //CR-00000450
    public void getMapSummarizedOrderFields(List<CampaignLineItem> lines){
        Map<String,Decimal> Map_Summarized_Order_Fields_Temp = new Map <String,Decimal>();

        //Initialize map
        Map_Summarized_Order_Fields_Temp.put('Forecast', Decimal.valueOf('0'));
        Map_Summarized_Order_Fields_Temp.put('Agreed', Decimal.valueOf('0'));
        Map_Summarized_Order_Fields_Temp.put('POG', Decimal.valueOf('0'));

        for(CampaignLineItem line : lines) {
            if(line.record.Forecast__c > 0){
                Map_Summarized_Order_Fields_Temp.put('Forecast', (Decimal)Map_Summarized_Order_Fields_Temp.get('Forecast') + (Decimal)(line.record.Forecast__c == null ? Decimal.valueOf('0') : line.record.Forecast__c));
            }
            if(line.record.Agreed__c > 0){
                Map_Summarized_Order_Fields_Temp.put('Agreed', (Decimal)Map_Summarized_Order_Fields_Temp.get('Agreed') + (Decimal)(line.record.Agreed__c == null ? Decimal.valueOf('0') : line.record.Agreed__c));
            }
            if(line.record.POG__c > 0){
                Map_Summarized_Order_Fields_Temp.put('POG', (Decimal)Map_Summarized_Order_Fields_Temp.get('POG') + (Decimal)(line.record.POG__c == null ? Decimal.valueOf('0') : line.record.POG__c));
            }
        }
        Map_Summarized_Order_Fields = Map_Summarized_Order_Fields_Temp;
    }
    //End CR-00000450  
}