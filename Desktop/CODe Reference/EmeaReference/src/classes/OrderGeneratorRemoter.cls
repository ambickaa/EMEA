global with sharing class OrderGeneratorRemoter
 {


    public String preliminaryOrderID { get; set; }
    public static LIST<CampaignLineItem__c> clis{ get; set; }
    public static LIST<CampaignLineItem__c> pclis{ get; set; }  
    public static LIST<CampaignLineItem__c> uclis{ get; set; }
    global String stringListIds {get;set;}
    
    public Boolean txtPanel {get;set;}
    public Boolean renderButton {get;set;}
    
    public String orderOption;	
    public String currentAccount;
    public ID currentAccountID  { get; set; }    
     
    public List<OrderItem2> OrderItems { get; set; }
    public List<String> ListIds { get; set; } 
    
    public String orderType; 
    public String catalogType;
    public Boolean consigned;
    
    public OrderGeneratorRemoter()
    {
        renderButton=false;   
    } // empty constructor
    
    public String getorderType ()
    {
        return (String)ApexPages.currentPage().getParameters().get('orderType');  
    }
    
    public void setorderType (String orderType)
    {
        this.orderType= orderType;
    }

// consigna
    public Boolean getconsigned ()
    {
        if((String)ApexPages.currentPage().getParameters().get('consigned')=='true')
            return true;
        else
            return false;
    }
    
    public void setconsigned (Boolean consigned)
    {
        this.consigned= consigned;
    }


    public String getcatalogType ()
    {
        return (String)ApexPages.currentPage().getParameters().get('catalogType'); 
    }
    
    public void setcatalogType (String catalogType)
    {
        this.catalogType= catalogType;
    }

    public String getcurrentAccount ()
    {
        return (String)ApexPages.currentPage().getParameters().get('accountId'); 
    }
    
    public void setcurrentAccount (String currentAccount)
    {
        this.currentAccount= currentAccount;
    }

    @RemoteAction
    global static string foo(String str) {
        return 'OK';
    }

       
    @RemoteAction
    global static LIST<CampaignLineItem__c> getActionPlanItems(String preliminaryOrderId, String orderType, String catalogType, Boolean consigned, String currentAccount) {

         ID accID=(ID)currentAccount;
         
         if(preliminaryOrderID=='INIT' && orderType=='Preliminary') 
         {
             preliminaryOrderId='New Order';
         }
         else if(preliminaryOrderId=='INIT' && orderType=='Final')
         {
             List<Order__c> tempList = [ SELECT ID FROM Order__c WHERE RecordTypeId=:Util.recordType.get('Order__c:PreliminaryOrder') AND AccountRef_RSA__c=:(ID)accID AND Status_RSA__c='Closed' AND Type_RSA__c=:catalogType AND consigned__c=:consigned
           ORDER BY Name ];
             preliminaryOrderId=tempList[0].Id;
         }
         

         clis=new List<CampaignLineItem__c>();
         if(preliminaryOrderId=='New Order')  
         {      
             clis =  [SELECT Id, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, CatalogType_RSA__c, 
                      PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c,  ProductName_RSA__c, TaxStockLeft_RSA__c, RegStockLeft_RSA__c, HybridName__c,
                      GlobalStock_RSA__r.HybridRef__r.Stockleft__c, GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c
                      FROM CampaignLineItem__c
                      WHERE FinalOrderRef_RSA__c=null AND PreliminaryOrderRef_RSA__c=null AND (Agreed__c>0) AND FarmRef__c=:accID AND CatalogType_RSA__c=:catalogType 
                      AND consigned__c=:consigned ORDER BY LastModifiedDate ASC];      
         }
         else if(orderType=='Preliminary') 
         {
             pclis =  [ SELECT Id, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, CatalogType_RSA__c, 
             			PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c,  ProductName_RSA__c , TaxStockLeft_RSA__c, RegStockLeft_RSA__c, HybridName__c,
             			GlobalStock_RSA__r.HybridRef__r.Stockleft__c, GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c
                    	FROM CampaignLineItem__c
                    	WHERE PreliminaryOrderRef_RSA__c=:(ID)preliminaryOrderID AND FinalOrderRef_RSA__c=null  AND (Agreed__c>0) AND FarmRef__c=:accID 
                    	AND CatalogType_RSA__c=:catalogType AND consigned__c=:consigned  ORDER BY LastModifiedDate ASC];
             uclis =  [ SELECT Id, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, CatalogType_RSA__c, 
             			PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c,  ProductName_RSA__c, TaxStockLeft_RSA__c, RegStockLeft_RSA__c, HybridName__c,
             			GlobalStock_RSA__r.HybridRef__r.Stockleft__c, GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c
	                    FROM CampaignLineItem__c
	                    WHERE FinalOrderRef_RSA__c=null AND PreliminaryOrderRef_RSA__c=null  AND (Agreed__c>0) AND FarmRef__c=:accID AND CatalogType_RSA__c=:catalogType 
	                    AND consigned__c=:consigned ORDER BY LastModifiedDate ASC]; 
             
             if(pclis.size()>0) clis.addAll(pclis);
             if(uclis.size()>0) clis.addAll(uclis);               
 
         }else if(orderType=='Final') 
         {
             pclis =  [ SELECT Id, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, CatalogType_RSA__c, 
             			PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c,  ProductName_RSA__c ,TaxStockLeft_RSA__c, RegStockLeft_RSA__c,HybridName__c,
             			GlobalStock_RSA__r.HybridRef__r.Stockleft__c, GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c
	                    FROM CampaignLineItem__c
	                    WHERE PreliminaryOrderRef_RSA__c=:(ID)preliminaryOrderID AND FinalOrderRef_RSA__c=null  AND (Agreed__c>0) AND (POG__c>0) AND FarmRef__c=:accID 
	                    AND CatalogType_RSA__c=:catalogType AND consigned__c=:consigned ORDER BY LastModifiedDate ASC];
             uclis =  [ SELECT Id, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, CatalogType_RSA__c, 
            			PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c,  ProductName_RSA__c ,TaxStockLeft_RSA__c, RegStockLeft_RSA__c, HybridName__c,
             			GlobalStock_RSA__r.HybridRef__r.Stockleft__c, GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c
	                    FROM CampaignLineItem__c
	                    WHERE FinalOrderRef_RSA__c=null AND PreliminaryOrderRef_RSA__c=null  AND (POG__c>0) AND FarmRef__c=:accID AND CatalogType_RSA__c=:catalogType 
	                    AND consigned__c=:consigned  ORDER BY LastModifiedDate ASC];   
             if(pclis.size()>0) clis.addAll(pclis);
             if(uclis.size()>0) clis.addAll(uclis);               
                       
        }
        return clis;
    }    

    public PageReference launcher()
    {
    txtPanel=true;
    return null;
    }

    public void idHandler()  
    {   
        renderButton=true;
    }
    
    
    public List<SelectOption> getorderOptions() {
    
         currentAccount= ApexPages.currentPage().getParameters().get('accountId');
         orderType= ApexPages.currentPage().getParameters().get('orderType');
         catalogType= ApexPages.currentPage().getParameters().get('catalogType');
         consigned = (ApexPages.currentPage().getParameters().get('consigned')=='true'?true:false);
          
         String ordStatus='Draft';
         if(orderType=='Final') ordStatus='Closed';                   
        List<SelectOption> options = new List<SelectOption>();
        
        if(orderType=='Preliminary')
            options.add(new SelectOption('New Order','New Order'));

        for(Order__c pO: [SELECT ID, Name,RecordTypeId, Type_RSA__c,Status_RSA__c,LastModifiedDate, (select ID FROM Attachments) ,Signed_RSA__c FROM Order__c 
         WHERE RecordTypeId=:Util.recordType.get('Order__c:PreliminaryOrder') AND AccountRef_RSA__c=:(ID)currentAccount AND Status_RSA__c=:ordStatus AND Type_RSA__c=:catalogType
          AND consigned__C=:consigned ORDER BY Name])
        {
                options.add(new SelectOption(pO.ID,pO.Name));
        }
        if(orderOption==null)
        {
            if(orderType=='Preliminary')
                orderOption='New Order';
            else if(orderType=='Final')
            {
                List<Order__c> tempList = [ SELECT ID FROM Order__c WHERE RecordTypeId=:Util.recordType.get('Order__c:PreliminaryOrder') AND AccountRef_RSA__c=:(ID)currentAccount AND Status_RSA__c='Closed' AND Type_RSA__c=:catalogType AND Consigned__c=:consigned
                   ORDER BY Name ];
                 orderOption=tempList[0].Id;
            }
        }
        
        return options;
    }
    
      
    
    public String getorderOption() {
    
        if(orderOption==null) orderOption='New Order';
        return orderOption;
    }
            
    public void setorderOption(String orderOption) {
        //stringListIds='';
        this.orderOption= orderOption;
    }

   public List<OrderItem2> OrderItemHandler(Boolean isUpdate)
    {
        List<OrderItem2> wrapperaux = new List<OrderItem2>();
        if(stringListIds!='[]' && stringListIds!=null && stringListIds!='')  
        {
            //ListIds=(List<ID>)((stringListIds.substringAfter('["')).substringBefore('"]')).split('","');  
            ListIds=(List<ID>)(stringListIds.split(','));  
                       
            for(CampaignLineItem__c cli: [
                SELECT ID, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, ProductRef__r.Name, 
                PreliminaryOrderRef_RSA__c,FinalOrderRef_RSA__c, GlobalStock_RSA__r.TaxStockLeft_RSA__c, CatalogType_RSA__c, GlobalStock_RSA__r.HybridRef__r.Stockleft__c, 
                GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c, GlobalStock_RSA__r.StockLeft_RSA__c, PersonalStock_RSA__r.StockLeft_RSA__c, HybridName__c
                FROM CampaignLineItem__c where ID in:ListIds])
            {
               wrapperaux.add(new OrderItem2(cli,false,true));
            }
        }
          
        if(isUpdate)
        {
            Set<ID> testSet = new Set<ID>();

            if(stringListIds!='[]' && stringListIds!=null && stringListIds!='')  
            {
                 //ListIds=((stringListIds.substringAfter('["')).substringBefore('"]')).split('","');                
                 ListIds=(List<ID>)stringListIds.split(',');  
                 testSet.addAll((List<ID>)ListIds);

            }
            for(CampaignLineItem__c cli: [
                SELECT ID, BagSizeConversion_RSA__c,Ultrashort_Irrigation_RSA__c , POG__c, Agreed__c, Forecast__c, PlantingDensity__c, ProductRef__r.Name, 
                PreliminaryOrderRef_RSA__c,FinalOrderRef_RSA__c, GlobalStock_RSA__r.TaxStockLeft_RSA__c, CatalogType_RSA__c, GlobalStock_RSA__r.HybridRef__r.Stockleft__c, 
                GlobalStock_RSA__r.HybridRef__r.TaxStockleft__c, GlobalStock_RSA__r.StockLeft_RSA__c, PersonalStock_RSA__r.StockLeft_RSA__c, HybridName__c
                FROM CampaignLineItem__c where PreliminaryOrderRef_RSA__c=:(ID)orderOption ])
            {
                if(!testSet.contains(cli.Id))
                    wrapperaux.add(new OrderItem2(cli,false,false));
            }
        }

        return wrapperaux;
    }
     
    public PageReference createPreliminaryOrder(){
    
            ListIds=(List<ID>)((stringListIds.substringAfter('["')).substringBefore('"]')).split('","');                
            OrderItems=new List<OrderItem2>();
            OrderItems=OrderItemHandler(false); 
            if(consigned){
                if(checkPreliminaryRequested(OrderItems))
                    return createPreliminaryOrder(OrderItems,catalogType,consigned);
                else
                    return null;
            } else {
                if(checkPreliminaryStock(OrderItems))
                    return createPreliminaryOrder(OrderItems,catalogType,consigned);
                else
                    return null;
            }        
    }

    public PageReference updatePreliminaryOrder(){
        
            if (stringListIds!=null && stringListIds!='')
            ListIds=(List<ID>)((stringListIds.substringAfter('["')).substringBefore('"]')).split('","'); 
            else 
                ListIds=new List<ID>();             
            OrderItems=new List<OrderItem2>();
            OrderItems=OrderItemHandler(true);       
            List<OrderItem2> OrderItemsAux=new List<OrderItem2> ();
            
            for(OrderItem2 oi : OrderItems)
            {
                if(oi.selected==true)
                    OrderItemsAux.add(oi);        
            }
            if(OrderItems.size()<1)
            {
                Util.addErrorMessage('You have not done any change. The order was already empty ');                      
                return null;
            }
            if(consigned){
                if(checkPreliminaryRequested(OrderItemsAux))
                    return updatePreliminaryOrder(OrderItemsAux,catalogType);
                else
                    return null;
            } else {
                if(checkPreliminaryStock(OrderItemsAux))
                    return updatePreliminaryOrder(OrderItemsAux,catalogType);
                else
                    return null; 
            }              
    }  

    public PageReference deletePreliminaryOrder(){
        
        
        if (stringListIds!=null && stringListIds!='')
            ListIds=(List<ID>)((stringListIds.substringAfter('["')).substringBefore('"]')).split('","'); 
        else 
            ListIds=new List<ID>();             
        return deletePreliminaryOrder((ID)orderOption);
           
    } 
    
    public PageReference createFinalOrder(){
        
        ListIds=(List<ID>)((stringListIds.substringAfter('["')).substringBefore('"]')).split('","');     
        
        if(orderOption=='--Select an Order--')
        {
            Util.addErrorMessage('You must select a Preliminary Order to create a Final Order');                          
            return null;
        }     
        OrderItems=new List<OrderItem2>();
        OrderItems=OrderItemHandler(false); 
        if(OrderItems.size()<1)
        {
            Util.addErrorMessage('It is not allowed to create a final order empty. Please select a product');           
            return null;
        }
   
        if(CheckRequiredFields())
        {
            if(consigned){
                if(checkRequested(OrderItems))
                    return createFinalOrder(OrderItems,catalogType,consigned);
                else
                    return null;            
            }
            else{
                if(checkStock(OrderItems))
                    return createFinalOrder(OrderItems,catalogType,consigned);
                else
                    return null;
            }
        }
        else
            return null;    
    }   
    
     private boolean CheckRequiredFields()
    {
        Account AccountInfo= [SELECT ID, BankAccountHolder_RSA__c FROM Account WHERE ID=:(ID)currentAccount];
        if(AccountInfo.BankAccountHolder_RSA__c==null)
        {
            Util.addErrorMessage('The field "Bank Account Holder" must be filled in before creating a final order');
            return false;
        }
        else return true;       
    }
   
    private boolean checkPreliminaryStock(List<OrderItem2> paramItems){
    
            Boolean returned = true;
            Map<String,Integer> currentlyAllocated = new Map<String,Integer>();
            for(OrderItem2 oi : paramItems){
                if((oi.item.FinalOrderRef_RSA__c == null || 
                !oi.item.FinalOrderRef_RSA__r.Signed_RSA__c) &&
                oi.item.Agreed__c > 0 ){
                    if(currentlyAllocated.get(oi.item.HybridName__c) == null){
                        currentlyAllocated.put(oi.item.HybridName__c, Integer.valueOf(oi.item.Agreed__c));
                    }else{
                        currentlyAllocated.put(oi.item.HybridName__c,currentlyAllocated.get(oi.item.HybridName__c) + Integer.valueOf(oi.item.Agreed__c));
                    }
                    if('Tax'.equalsIgnoreCase(oi.item.CatalogType_RSA__c) || 'General'.equalsIgnoreCase(oi.item.CatalogType_RSA__c)){
                        if(oi.item.GlobalStock_RSA__c == null || currentlyAllocated.get(oi.item.HybridName__c) > oi.item.GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c){
                            returned = false;
                            Util.addErrorMessage('Stock missing for ' + oi.item.HybridName__c + '( ' + oi.item.Agreed__c + ' / ' + oi.item.GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c + ' )');
                        }
                    }else{
                        if(oi.item.GlobalStock_RSA__c == null || currentlyAllocated.get(oi.item.HybridName__c) > oi.item.GlobalStock_RSA__r.HybridRef__r.StockLeft__c){
                            returned = false;
                            Util.addErrorMessage('Stock missing for ' + oi.item.HybridName__c + '( ' + oi.item.Agreed__c + ' / ' + oi.item.GlobalStock_RSA__r.HybridRef__r.StockLeft__c + ' )');
                        }
                    }
                }
            }           
            return returned;
    } 
    private boolean checkStock(List<OrderItem2> paramItems){
            Boolean returned = true;
            Map<String,Integer> currentlyAllocated = new Map<String,Integer>();
            for(OrderItem2 oi : paramItems){
                if((oi.item.FinalOrderRef_RSA__c == null || 
                !oi.item.FinalOrderRef_RSA__r.Signed_RSA__c) &&
                oi.item.PoG__c > 0 ){
                    if(currentlyAllocated.get(oi.item.HybridName__c) == null){
                        currentlyAllocated.put(oi.item.HybridName__c, Integer.valueOf(oi.item.PoG__c));
                    }else{
                        currentlyAllocated.put(oi.item.HybridName__c,currentlyAllocated.get(oi.item.HybridName__c) + Integer.valueOf(oi.item.PoG__c));
                    }
                    if('Tax'.equalsIgnoreCase(oi.item.CatalogType_RSA__c) || 'General'.equalsIgnoreCase(oi.item.CatalogType_RSA__c)){
                        if(oi.item.GlobalStock_RSA__c == null || currentlyAllocated.get(oi.item.HybridName__c) >oi.item.GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c ){
                            returned = false;
                            Util.addErrorMessage('Stock missing for ' + oi.item.HybridName__c + '( ' + oi.item.PoG__c + ' / ' + oi.item.GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c + ' )');
                        }
                    }else{
                        if(oi.item.GlobalStock_RSA__c == null || currentlyAllocated.get(oi.item.HybridName__c) > oi.item.GlobalStock_RSA__r.HybridRef__r.StockLeft__c){
                            returned = false;
                            Util.addErrorMessage('Stock missing for ' + oi.item.HybridName__c + '( ' + oi.item.PoG__c + ' / ' +oi.item.GlobalStock_RSA__r.HybridRef__r.StockLeft__c + ' )');
                        }
                    }
                }
            }
            
            return returned;
    }   

    private boolean checkRequested(List<OrderItem2> paramItems)
    {
        Boolean returned = true;
        Map<String,Decimal> currentlyRequested = new Map<String,Decimal>(); //Product Id, Quantity
        currentAccountID=getcurrentAccount();
        Account currentAcc = [SELECT OwnerID FROM Account WHERE id=:currentAccountID]; 
        
        for (ConsignmentWarehouse__c co : [SELECT Name, StockLeft__c FROM ConsignmentWarehouse__c WHERE UserRef__c=:currentAcc.OwnerID ]){ 
        	currentlyRequested.put(co.Name, co.StockLeft__c);   
        }
        
        Map<String,Decimal> toCheck = new Map<String,Decimal>(); //Product Id, Quantity
        for(OrderItem2 oi : paramItems)
        {
            if(oi.item.POG__c>0 && (oi.item.FinalOrderRef_RSA__c == null||! oi.item.FinalOrderRef_RSA__r.Signed_RSA__c ))
            {
                if(toCheck.get(oi.item.HybridName__c)==null)
                    toCheck.put(oi.item.HybridName__c, oi.item.POG__c);
                else
                { 
                    Decimal sum = oi.item.POG__c + toCheck.get(oi.item.HybridName__c);
                    toCheck.put(oi.item.HybridName__c, sum);   
                }
            }               
        }

        for(String pro : toCheck.keySet())
        {
            if(currentlyRequested.get(pro)==null || toCheck.get(pro)>currentlyRequested.get(pro))
            {
                Util.addWarningMessage('There is not enough Stock Requested for Hybrid: '+ pro);
                returned = false;
            }
        }
        
        return returned;
    }  
    
    private boolean checkPreliminaryRequested(List<OrderItem2> paramItems)
    {
        Boolean returned = true;
        Map<String,Decimal> currentlyRequested = new Map<String,Decimal>(); //Product Id, Quantity
        currentAccountID=getcurrentAccount();
        Account currentAcc = [SELECT OwnerID FROM Account WHERE id=:currentAccountID]; 
        
        for (ConsignmentWarehouse__c co : [SELECT Name, StockLeft__c FROM ConsignmentWarehouse__c WHERE UserRef__c=:currentAcc.OwnerID]){ 
        	currentlyRequested.put(co.Name, co.StockLeft__c);   
        }
        
        Map<String,Decimal> toCheck = new Map<String,Decimal>(); //Product Id, Quantity
        for(OrderItem2 oi : paramItems)
        {
            if(oi.item.Agreed__c>0 && (oi.item.FinalOrderRef_RSA__c == null||! oi.item.FinalOrderRef_RSA__r.Signed_RSA__c ))
            {
                if(toCheck.get(oi.item.HybridName__c)==null)
                    toCheck.put(oi.item.HybridName__c, oi.item.Agreed__c);
                else
                { 
                    Decimal sum = oi.item.Agreed__c + toCheck.get(oi.item.HybridName__c);
                    toCheck.put(oi.item.HybridName__c, sum);   
                }
            }               
        }

        for(String pro : toCheck.keySet())
        {
            if(currentlyRequested.get(pro)==null || toCheck.get(pro)>currentlyRequested.get(pro))
            {
                Util.addWarningMessage('There is not enough Stock Requested for Hybrid: '+ pro);
                returned = false;
            }
        }
        
        return returned;
    }       
    private PageReference createPreliminaryOrder(List<OrderItem2> paramItems, String paramOrderType, Boolean isConsigned){
            
            Savepoint sp = Database.setSavepoint();
            try{
            currentAccountID=(ID)currentAccount;
            Set<ID> campaignLineItemsToQuery = new Set<ID>();
                      
            for(OrderItem2 oi: paramItems)
            {
                    campaignLineItemsToQuery.add(oi.item.ID);
            }
            
            // Load from DB updated records (just in case they have been updated)
            List<CampaignLineItem__c> queriedCampaignLineItems = [SELECT Agreed__c, PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c, PreliminaryOrderRef_RSA__r.Name, FinalOrderRef_RSA__r.Name, PreliminaryOrderRef_RSA__r.Status_RSA__c, FinalOrderRef_RSA__r.Status_RSA__c FROM CampaignLineItem__c WHERE ID in :campaignLineItemsToQuery];
            List<CampaignLineItem__c> involvedCampaignLineItems = new List<CampaignLineItem__c>();
            ID preliminaryOrderToUse, finalOrderToUse;
            
            Set<ID> preliminaryOrdersLocked = new Set<ID>();
    
            for(CampaignLineItem__c cli : queriedCampaignLineItems){
                   // if its not locked
                         if(!preliminaryOrdersLocked.contains(cli.PreliminaryOrderRef_RSA__c))
                         {
                                // if it has no Preliminary Order, it should be added to the Preliminary we are creating
                               if(cli.PreliminaryOrderRef_RSA__c == null)
                               {
                                involvedCampaignLineItems.add(cli);                     
                               }
                         }
            }
            
            if(involvedCampaignLineItems.size() > 0){
                Integer count = 0;
                for(CampaignLineItem__c cli : involvedCampaignLineItems){
                    if(cli.Agreed__c != null && cli.Agreed__c != 0)
                    {
                        count++;
                    }
                }
                if(count > 0){
                    if(preliminaryOrderToUse == null){
                        Order__c toInsert = new Order__c(AccountRef_RSA__c = currentAccountID, Type_RSA__c =paramOrderType,VAT_RSA__c = 14.0, RecordTypeID = Util.recordType.get('Order__c:PreliminaryOrder'), Status_RSA__c = 'Draft', Signed_RSA__c = false, consigned__C=isConsigned);
                        insert toInsert;
                        preliminaryOrderToUse = toInsert.id;    
                    }
                    
                    for(CampaignLineItem__c cli : involvedCampaignLineItems){
                        if(cli.Agreed__c != null && cli.Agreed__c != 0)
                            cli.PreliminaryOrderRef_RSA__c = preliminaryOrderToUse;
                        else
                            cli.PreliminaryOrderRef_RSA__c = null;
                    }
                    update involvedCampaignLineItems;
                    update new Order__c(ID = preliminaryOrderToUse, /* Status_RSA__c = 'Draft' ,*/ /*Signed_RSA__c = false,*/ shouldCopy_RSA__c = true);

                    PageReference returned = new PageReference('/' + preliminaryOrderToUse).setRedirect(true);
                    return returned;    
                }else{
                    Util.addErrorMessage('A preliminary Order cannot be empty');
                    return null;
                }        
            }else{
                Util.addErrorMessage('There are no items to add to the order');
                return null;
            }
            }catch(Exception e){
               Database.rollback(sp);
               Apexpages.addMessages(e);
               return null;
          }
    }
    
    private PageReference updatePreliminaryOrder(List<OrderItem2> paramItem, String paramOrderType){
  
        Savepoint sp = Database.setSavepoint();
        try{
            List<CampaignLineItem__c> campaignLineItemsToUpdate= new List<CampaignLineItem__c>();
            ID preliminaryOrderToUse;
            preliminaryOrderToUse=(ID)orderOption;
    
            integer counter=0;
            for(OrderItem2 cw: ParamItem)
            {               
                if(cw.selected==true)
                {   
                     cw.item.PreliminaryOrderRef_RSA__c=preliminaryOrderToUse;
                     counter++;
                     campaignLineItemsToUpdate.add(cw.item);     
                }else if(cw.item.PreliminaryOrderRef_RSA__c==preliminaryOrderToUse)        
                {
                    cw.item.PreliminaryOrderRef_RSA__c=null;         
                    campaignLineItemsToUpdate.add(cw.item);
                    counter++; 
                }                     
            }            
            update(campaignLineItemsToUpdate);
   
            if(counter>0)
            { PageReference returned = new PageReference('/' + preliminaryOrderToUse).setRedirect(true);
               return returned; 
            }  
            else return null;
               

        }catch(Exception e){
               Database.rollback(sp);
               Apexpages.addMessages(e);
               return null;
        }
    }
    
    private PageReference deletePreliminaryOrder(ID paramOrderID)
    {
     
        Savepoint sp = Database.setSavepoint();
        try{
            List<CampaignLineItem__c> campaignLineItemsToCheck= new List<CampaignLineItem__c>();
            Order__c Order2delete=[SELECT ID FROM Order__c WHERE ID=:paramOrderID];            
            campaignLineItemsToCheck=[ SELECT ID FROM CampaignLineItem__c WHERE PreliminaryOrderRef_RSA__c=:paramOrderID];
            List<Order__c> finalOrders = [ SELECT ID FROM Order__c where PreliminaryOrderRef_RSA__c=:paramOrderId];
            
            if(finalOrders.size()>0)
            {
                Util.addErrorMessage('It is not allowed to delete a Preliminary Order if there are final orders related');
                return null;            
            }          
            if(campaignLineItemsToCheck.size()>0)
            {
                Util.addErrorMessage('It is not allowed to delete a Preliminary Order if it contains items. First you must update the order');
                return null;
            }else                      
            {
                delete(Order2delete); 
                PageReference returned = new PageReference('/apex/OrderGeneratorRemoter?accountId=' +(ID)currentAccount +'&orderType='+orderType+'&catalogType='+catalogType).setRedirect(true);
                return returned;
            }
               

        }catch(Exception e){
               Database.rollback(sp);
               Apexpages.addMessages(e);
               return null;
        }
    }   
    
    private PageReference createFinalOrder(List<OrderItem2> paramItems, String paramOrderType, Boolean isConsigned){
        Savepoint sp = Database.setSavepoint();
        try{       
            
            Set<ID> campaignLineItemsToQuery = new Set<ID>();
            list<id> productIds = new list<id>();
            currentAccountID=(ID)currentAccount;
            
            
            for( OrderItem2 oi : paramItems)
            {
                    campaignLineItemsToQuery.add(oi.item.id);          
            }
            
            List<CampaignLineItem__c> queriedCampaignLineItems = [SELECT shouldCopy_RSA__c, PoG__c, PreliminaryOrderRef_RSA__c, FinalOrderRef_RSA__c, FinalOrderRef_RSA__r.Status_RSA__c, Ultrashort_Irrigation_RSA__c, ProductRef__c FROM CampaignLineItem__c WHERE ID in :campaignLineItemsToQuery];
            List<CampaignLineItem__c> involvedCampaignLineItems = new List<CampaignLineItem__c>();
            ID preliminaryOrderToUse, finalOrderToUse;
            for(CampaignLineItem__c cli : queriedCampaignLineItems){
                productIds.add(cli.ProductRef__c);
                if(cli.FinalOrderRef_RSA__c == null){
                    cli.shouldCopy_RSA__c = true;
                    involvedCampaignLineItems.add(cli);
                    
                }else if('Draft'.equalsIgnoreCase(cli.FinalOrderRef_RSA__r.Status_RSA__c)){
                    finalOrderToUse = cli.FinalOrderRef_RSA__c;
                    cli.shouldCopy_RSA__c = true;
                    involvedCampaignLineItems.add(cli);
                }
                
                if(cli.PreliminaryOrderRef_RSA__c != null && (cli.FinalOrderRef_RSA__c==null || cli.FinalOrderRef_RSA__r.Status_RSA__c=='Draft')){
                    preliminaryOrderToUse = cli.PreliminaryOrderRef_RSA__c;
              
                }
            }
            preliminaryOrderToUse = (ID)orderOption;
           
            if(involvedCampaignLineItems.size() > 0){    
                
                if(finalOrderToUse == null){
                
                    AggregateResult maxVersion = [SELECT Max(Version_Id_RSA__c) from Order__c WHERE AccountRef_RSA__c = :currentAccountID AND PreliminaryOrderRef_RSA__c = :preliminaryOrderToUse];                    
                    Decimal version=0;
                    if (maxVersion.get('expr0') != null)
                        version =  (Decimal)maxVersion.get('expr0')+1;
                    Order__c toInsert = new Order__c(AccountRef_RSA__c = currentAccountID, Type_RSA__c = paramOrderType,VAT_RSA__c = 14.0,PreliminaryOrderRef_RSA__c = preliminaryOrderToUse, RecordTypeID = Util.recordType.get('Order__c:FinalOrder'), Status_RSA__c = 'Draft', Version_Id_RSA__c = version, isIrrigated_RSA__c = involvedCampaignLineItems[0].Ultrashort_Irrigation_RSA__c, consigned__C=isConsigned);
                    insert toInsert;
                    finalOrderToUse = toInsert.id;  
                }
                Integer cliOnFinalOrder = 0;
                for(CampaignLineItem__c cli : involvedCampaignLineItems){
                    
                    if(cli.PoG__c != null && cli.PoG__c != 0){
                        cli.FinalOrderRef_RSA__c = finalOrderToUse; 
                        cli.shouldcopy_RSA__c = true;
                        cli.Price_Copy__c=null;
                        cliOnFinalOrder++;
                    }else{
                        cli.FinalOrderRef_RSA__c = null;
                    }
                    
                }
                
                update involvedCampaignLineItems;
                for(CampaignLineItem__c cli : involvedCampaignLineItems){
                    if(cli.PoG__c != null && cli.PoG__c != 0){
                        cli.shouldcopy_RSA__c = true;
                    }
                }

                update involvedCampaignLineItems;
                
      
                if(cliOnFinalOrder > 0){
                    update new Order__c(ID = finalOrderToUse,EarlyPayment_RSA__c = null, shouldCopy_RSA__c = true);
                
                    PageReference returned = new PageReference('/' + finalOrderToUse + '/e').setRedirect(true);
                    returned.getParameters().put('retURL', '/apex/AccountView?id=' + currentAccountID);
                    returned.getParameters().put('saveURL', '/' + finalOrderToUse);
                    
                    try{
                        UtilREST.BudgetUpdater(productIds,new List<ID>{Util.currentUser.Id});                               
                    }catch (Exception e)
                    {
                    }  
                    return returned;
                }else{
                    delete new Order__c(ID = finalOrderToUse);
                    Util.addWarningMessage('There are no items to add to the order');
                    return null;
                }
            }else{              
                Util.addErrorMessage('There are no items to add to the order');
                return null;
            }
   
            }catch(Exception e){
                Database.rollback(sp);
                Apexpages.addMessages(e);
                return null;
            } 
   
    }       
 
    public class OrderItem2
    {
        public CampaignLineItem__c item{get; set;}
        public Boolean selected {get; set;}
        public Boolean disabled {get; set;}
        public Boolean hasPreliminar {get; set;}
              
        public OrderItem2(CampaignLineItem__c aux, Boolean hp,  Boolean sel)
        {
            item = aux;
            selected = sel;
            disabled = false;
            hasPreliminar=hp;
        }
    }   
}