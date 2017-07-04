public with sharing class AccountTacticalPlanRSAController  extends AccountListVirtualController
{
  
    public AccountTacticalPlanRSAController()
    {
        objectFactory = new TacticalPlanItalyFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
    }
    private ActionPlan theActionPlan;
    
     
    public ID getpopupAccount()
    {
        return Util.currentAccount.ID;
    }
    
    public ActionPlan getActionPlan()
    {
        if(theActionPlan == null)
        {
            theActionPlan = new ActionPlan();
        }
        return theActionPlan;
    }
    
    public PageReference doLoadProductPickerTax(){
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',jumperTag);
        returned.getParameters().put('mode',mode);
        returned.getParameters().put('catalog','Tax');
        return returned;
    }
    
    public PageReference doLoadProductPickerRegular(){
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',jumperTag);
        returned.getParameters().put('mode',mode);
        returned.getParameters().put('catalog','Regular');
        return returned;
    }
    
    public PageReference doLoadProductPickerGeneral(){
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',jumperTag);
        returned.getParameters().put('mode',mode);
        returned.getParameters().put('catalog','General');
        return returned;
    }
 
    public PageReference doLoadProductPickerFebReceipt(){
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',jumperTag);
        returned.getParameters().put('mode',mode);
        returned.getParameters().put('catalog','Feb Receipt');
        return returned;
    }
    
    public PageReference doLoadProductPickerConsigned(){ 
        PageReference returned = Page.AccountProductPicker.setRedirect(true);
        returned.getParameters().put('id',accountId);
        returned.getParameters().put('division',Util.divisionId);
        returned.getParameters().put('jumperTag',jumperTag);
        returned.getParameters().put('mode',mode);
        returned.getParameters().put('catalog','Regular');
        returned.getParameters().put('consignment','true');
        return returned;
    }
    public class ActionPlan
    {
        public List<OrderItem> taxOrders {get;set;}
        public List<OrderItem> regularOrders {get;set;}
        public List<OrderItem> FebReceiptOrders  {get;set;}
        public List<OrderItem> generalOrders  {get;set;}
        public List<OrderItem> consignedOrders  {get;set;}
        
        public List<CampaignLineItem__c> toDeleteTax {get;set;}
        public List<CampaignLineItem__c> toDeleteRegular {get;set;}
        public List<CampaignLineItem__c> toDeleteFebReceipt {get;set;}
        public List<CampaignLineItem__c> toDeleteGeneral {get;set;}        
        public List<CampaignLineItem__c> toDeleteConsigned {get;set;}
        
        
        public String taxFinalOrderNames {get;set;}
        public String regularFinalOrderNames {get;set;}
        public String febReceiptFinalOrderNames { get;set; }
        public String generalFinalOrderNames {get;set;}
        public String consignedFinalOrderNames { get;set; }
        
        private ID currentAccountID {get;set;}
        
        public Boolean editModeTax {get; set;}
        public Boolean editModeRegular {get; set;}
        public Boolean editModeFebReceipt {get; set;}
        public Boolean editModeGeneral {get; set;}        
        public Boolean editModeConsigned {get; set;}
        
        public Boolean draftPreliminaryTax {get;set;}
        public Boolean draftPreliminaryRegular {get;set;}
        public Boolean draftPreliminaryFebReceipt {get;set;}
        public Boolean draftPreliminaryGeneral {get;set;}        
        public Boolean draftPreliminaryConsigned {get;set;}
        
        public Boolean frozen {get;set;}

        public ActionPlan()
        {
            internalVarsInit();
            init();
        }
        
        private void internalVarsInit() 
        {
            editModeTax = false;
            editModeRegular = false;
            editModeFebReceipt = false;
            editModeGeneral = false;
            editModeConsigned = false;
            taxFinalOrderNames = '';
            regularFinalOrderNames = '';
            febReceiptFinalOrderNames = '';
            generalFinalOrderNames = '';
            consignedFinalOrderNames = '';
        }
        
        public void init()
        {
            Campaign currentCampaign = Util.currentCampaign;
            if(currentCampaign == null) return; 
            SET<ID> productIDs = new SET<Id>();
            
            List<CampaignLineItem__c> allItems = new List<CampaignLineItem__c>();
            
            for(CampaignLineItem__c cli:            
                [
                    SELECT 
                        CatalogType_RSA__c,
                        Forecast__c,
                        Agreed__c,
                        PoG__c,
                        ProductRef__c,
                        ProductRef__r.Name,
                        ProductRef__r.ProductKernelSize__c,
                        ProductRef__r.ProductTreatment__c,
                        PoGPY__c,
                        
                        GlobalStock_RSA__r.TaxStockLeft_RSA__c,
                        GlobalStock_RSA__r.StockLeft_RSA__c,
                        GlobalStock_RSA__r.Quantity_RSA__c,
                        GlobalStock_RSA__r.TaxQuantity_RSA__c, 
                                                                    
                        PlantingDensity__c,
                        DistributorRef__c,
                        PoS__c,
                        
                        BagSizeConversion_RSA__c,
                        Ultrashort_Irrigation_RSA__c,
                        Price_copy__c,
                        
                        PreliminaryOrderRef_RSA__c,
                        PreliminaryOrderRef_RSA__r.Name,
                        PreliminaryOrderRef_RSA__r.Status_RSA__c,
                        PreliminaryOrderRef_RSA__r.Signed_RSA__c,
                        FinalOrderRef_RSA__c,
                        FinalOrderRef_RSA__r.Name,
                        FinalOrderRef_RSA__r.Signed_RSA__c,
                        FinalOrderRef_RSA__r.Status_RSA__c,
                        
                        Consigned__c,
                        HybridName__c,
                        ConsignedWarehouseRef__r.Consumed__c,
                        ConsignedWarehouseRef__r.StockLeft__c,
                        
                        GlobalStock_RSA__r.HybridRef__r.TaxStockLeft__c,
                        GlobalStock_RSA__r.HybridRef__r.StockLeft__c,
                        GlobalStock_RSA__r.HybridRef__r.Quantity__c,
                        GlobalStock_RSA__r.HybridRef__r.TaxQuantity__c                         
                    FROM CampaignLineItem__c 
                    WHERE FarmRef__c = :Util.currentAccount.ID
                        AND CampaignRef__c = :currentCampaign.ID
                        AND FinalOrderRef_RSA__r.Status_RSA__c != 'Cancelled'
                    ORDER BY ID ASC
                ])
            {
                allItems.add(cli);
                productIDs.add(cli.ProductRef__c);
            }
            currentAccountID = Util.currentAccount.ID;
            Map<Id,Integer> budgetMap = new Map<Id,Integer>();
            Map<Id,Integer> salesMap = new Map<Id,Integer>();
            
            for(ID iter: productIds)
            {
                budgetMap.put(iter,0);
                salesMap.put(iter,0);               
            }
             
             
            for(Budget__c b : [ SELECT TotalBudget__c, TotalSales__c, ProductRef__c FROM Budget__c WHERE ProductRef__c in :productIDs and SalesRep__c=:Util.currentAccount.OwnerId ])
            {         
                budgetMap.put(b.ProductRef__c,Integer.valueOf(b.TotalBudget__c));
                salesMap.put(b.ProductRef__c,Integer.valueOf(b.TotalSales__c));
            }

            if(!editModeTax){
                taxOrders = new List<OrderItem>();
                //taxFinalOrderNames = '';
            }
            if(!editModeRegular){
                regularOrders = new List<OrderItem>();
                //regularFinalOrderNames = '';
            }
            if(!editModeGeneral){
                generalOrders = new List<OrderItem>();
                //generalFinalOrderNames = '';
            }
            if(!editModeFebReceipt){
                FebReceiptOrders = new List<OrderItem> ();
            }
            if(!editModeConsigned){
                consignedOrders = new List<OrderItem> ();
            }            
            if(Util.currentCampaign != null){
                String campaignApprovalStatus = Util.currentCampaign.ApprovalStatus_RSA__c;
                frozen = (
                    'Submitted'.equals(campaignApprovalStatus) || 'Approved'.equals(campaignApprovalStatus));
            }
            
            draftPreliminaryTax = true;
            draftPreliminaryRegular = true;
            draftPreliminaryFebReceipt = true;
            draftPreliminaryGeneral = true;
            draftPreliminaryConsigned = true;
            
            integer freeTax=0;
            integer freeRegular=0;
            integer freeFebReceipt=0;
            integer freeGeneral=0;
            integer freeConsigned=0;
           
            for(CampaignLineItem__c cli : allItems)
            {
                if('Tax'.equals(cli.CatalogType_RSA__c))
                {
                    if (!editModeTax){
                        taxOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c)));                       
                    }                
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryTax = draftPreliminaryRegular &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;                
                    }                 
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        taxFinalOrderNames += cli.FinalorderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL && cli.FinalOrderRef_RSA__c == NULL){
                        freeTax++;
                    }
                    
                }
                else if('Regular'.equals(cli.CatalogType_RSA__c) && cli.consigned__c != true )
                { 

                    
                    if (!editModeRegular){system.debug('1');
                        regularOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c))); 
                    }
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryRegular = draftPreliminaryRegular &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;
                    }
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        regularFinalOrderNames += cli.FinalOrderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL ){
                        freeRegular++;
                    }
                  
                }
 /*               else if('Regular'.equals(cli.CatalogType_RSA__c) && cli.consigned__c != true )
                { 

                    
                    if (!editModeRegular){system.debug('1');
                        regularOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c))); 
                    }
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryRegular = draftPreliminaryRegular &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;
                    }
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        regularFinalOrderNames += cli.FinalOrderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL ){
                        freeRegular++;
                    }
                  
                }
                */
                else if('Feb Receipt'.equals(cli.CatalogType_RSA__c))
                {                   
                    if (!editModeFebReceipt)
                        FebReceiptOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c)));
                           
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryFebReceipt = draftPreliminaryFebReceipt &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;
                    }
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        FebReceiptFinalOrderNames += cli.FinalOrderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL ){
                        freeFebReceipt++;
                    }
                }  
                else if('General'.equals(cli.CatalogType_RSA__c))
                {   
                	system.debug('stock: '+cli.GlobalStock_RSA__r.StockLeft_RSA__c);                
                    if (!editModeGeneral)
                        generalOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c)));
                           
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryGeneral = draftPreliminaryGeneral &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;
                    }
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        generalFinalOrderNames += cli.FinalOrderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL ){
                        freeGeneral++;
                    }
                } 
                else if('Regular'.equals(cli.CatalogType_RSA__c) && cli.consigned__c == true )
                {
                    
                    if (!editModeConsigned)
                        consignedOrders.add(new OrderItem(cli, frozen,budgetMap.get(cli.ProductRef__c),salesMap.get(cli.ProductRef__c))); 
                    if (cli.PreliminaryOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__c!=null){
                        draftPreliminaryConsigned = draftPreliminaryConsigned &&( cli.FinalOrderRef_RSA__r.Status_RSA__c =='Draft' ||  cli.FinalOrderRef_RSA__r.Status_RSA__c =='Closed' ) ;
                    }
                    if(cli.FinalOrderRef_RSA__c != NULL && cli.FinalOrderRef_RSA__r.Status_RSA__c != 'Draft'){
                        consignedFinalOrderNames += cli.FinalOrderRef_RSA__r.Name;
                    }
                    if(cli.PreliminaryOrderRef_RSA__c == NULL ){
                        freeConsigned++;
                    }
                }
            }
            
            if (taxOrders.size() == 0  || freeTax==0)
                draftPreliminaryTax = False;
            if (regularOrders.size() == 0 || freeRegular==0)
                draftPreliminaryRegular = False;
            if (FebReceiptOrders.size() == 0 || freeFebReceipt==0)
                draftPreliminaryFebReceipt = False; 
            if (generalOrders.size() == 0 || freeGeneral==0)
                draftPreliminaryGeneral = False;               
            if (consignedOrders.size() == 0 || freeConsigned==0)
                draftPreliminaryConsigned = False;
                
            if (taxFinalOrderNames.length() > 0) {
                for (OrderItem element :taxOrders) {
                    element.setFinalOrderNames(taxFinalOrderNames);
                }
            }
            if (regularFinalOrderNames.length() > 0) {
                for (OrderItem element :regularOrders) {
                    element.setFinalOrderNames(regularFinalOrderNames);
                }
            }
            if (FebReceiptFinalOrderNames.length() > 0) {
                for (OrderItem element :FebReceiptOrders) {
                    element.setFinalOrderNames(FebReceiptFinalOrderNames);
                }
            }
            if (generalFinalOrderNames.length() > 0) {
                for (OrderItem element :generalOrders) {
                    element.setFinalOrderNames(generalFinalOrderNames);
                }
            }      
            if (consignedFinalOrderNames.length() > 0) {
                for (OrderItem element :consignedOrders) {
                    element.setFinalOrderNames(consignedFinalOrderNames);
                }
            }         
     }
        public void editTax(){
            editModeTax = true;
            toDeleteTax = new List<CampaignLineItem__c>();
        }
        public void editRegular(){
            editModeRegular = true;
            toDeleteRegular = new List<CampaignLineItem__c>();
        }
        public void editFebReceipt(){
            editModeFebReceipt = true;
            toDeleteFebReceipt = new List<CampaignLineItem__c>();
        }
        public void editGeneral(){
            editModeGeneral = true;
            toDeleteGeneral = new List<CampaignLineItem__c>();
        }
        public void editConsigned(){
            editModeConsigned = true;
            toDeleteConsigned = new List<CampaignLineItem__c>();
        }        
        public void addNewTax(){
            taxOrders.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Tax', CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged'), frozen,0,0));
            editTax();
        }
        
        public void addNewFebReceipt(){
            FebReceiptOrders.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Feb Receipt', CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged'), frozen,0,0));
            editFebReceipt();
        }       
        public void addNewRegular(){
            regularOrders.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', Consigned__c=false), frozen,0,0));
            editRegular();
        }
        public void addNewGeneral(){
            generalOrders.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'General', CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', Consigned__c=false), frozen,0,0));
            editGeneral();
        } 
        public void addNewConsigned(){
            consignedOrders.add(new OrderItem(new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', Consigned__c=true), frozen,0,0));
            editConsigned();
        }         
        public void cancelTax(){
            editModeTax = false;
            init();
        }
        public void cancelRegular(){
            editModeRegular = false;
            init();
        }
        
        public void cancelFebReceipt(){
            editModeFebReceipt = false;
            init();
        }
        
        public void cancelGeneral(){
            editModeGeneral = false;
            init();
        }       
        
        public void cancelConsigned(){
            editModeConsigned = false;
            init();
        } 
                 
        public void checkTaxStock(){
            if(checkStock(taxOrders)){
                Util.addConfirmMessage('There is enough Stock');
            }
        }
        public void checkRegularStock(){
            if(checkStock(regularOrders)){
                Util.addConfirmMessage('There is enough Stock');
            }
        }
        
        public void checkFebReceiptStock(){
            if(checkStock(FebReceiptOrders)){
                Util.addConfirmMessage('There is enough Stock');
            }
        }
         public void checkGeneralStock(){
            if(checkStock(generalOrders)){
                Util.addConfirmMessage('There is enough Stock');
            }
        }
        
        public void checkConsignedStock(){
            if(checkRequested(consignedOrders)){
                Util.addConfirmMessage('There is enough Stock Requested');
            }
        }        
        private boolean checkStock(List<OrderItem> paramItems){ 
            Boolean returned = true;
            Map<String,Integer> currentlyAllocated = new Map<String,Integer>();
            for(OrderItem oi : paramItems){
                if((oi.item.FinalOrderRef_RSA__c == null || !oi.item.FinalOrderRef_RSA__r.Signed_RSA__c) && oi.item.PoG__c > 0 ){
                    if(currentlyAllocated.get(oi.item.HybridName__c) == null)
                        currentlyAllocated.put(oi.item.HybridName__c, Integer.valueOf(oi.item.PoG__c));
                    else
                        currentlyAllocated.put(oi.item.HybridName__c,currentlyAllocated.get(oi.item.HybridName__c) + Integer.valueOf(oi.item.PoG__c));
                        
                }else if(oi.item.Agreed__c>0 && (oi.item.FinalOrderRef_RSA__c == null||oi.item.FinalOrderRef_RSA__r.Status_RSA__c=='Draft' )){
                    if(currentlyAllocated.get(oi.item.HybridName__c) == null)
                        currentlyAllocated.put(oi.item.HybridName__c, Integer.valueOf(oi.item.Agreed__c));
                    else
                        currentlyAllocated.put(oi.item.HybridName__c,currentlyAllocated.get(oi.item.HybridName__c) + Integer.valueOf(oi.item.Agreed__c));
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
            return returned;
        }
        public boolean checkRequested(List<OrderItem> paramItems)
        {
            Boolean returned = true;
            Map<String,Decimal> currentlyRequested = new Map<String,Decimal>(); //Product Id, Quantity
            Account currentAcc = [SELECT OwnerID FROM Account WHERE id=:currentAccountID]; 
            

            for (ConsignmentWarehouse__c co : [SELECT Name, StockLeft__c FROM ConsignmentWarehouse__c WHERE UserRef__c=:currentAcc.OwnerID]){ 
                currentlyRequested.put(co.Name, co.StockLeft__c);   
            }

            Map<String,Decimal> toCheck = new Map<String,Decimal>(); //Product Id, Quantity
            for(OrderItem oi : paramItems)
            {
                if(oi.item.POG__c>0 && (oi.item.FinalOrderRef_RSA__c == null||oi.item.FinalOrderRef_RSA__r.Status_RSA__c=='Draft' ))
                {
                    if(toCheck.get(oi.item.HybridName__c)==null)
                        toCheck.put(oi.item.HybridName__c, oi.item.POG__c);
                    else
                    {
                        Decimal sum = oi.item.POG__c + currentlyRequested.get(oi.item.HybridName__c);
                        toCheck.put(oi.item.HybridName__c, sum);   
                    }
                }
                else if(oi.item.Agreed__c>0 && (oi.item.FinalOrderRef_RSA__c == null||oi.item.FinalOrderRef_RSA__r.Status_RSA__c=='Draft' ))
                {
                    if(toCheck.get(oi.item.HybridName__c)==null)
                        toCheck.put(oi.item.HybridName__c, oi.item.Agreed__c);
                    else
                    {
                        oi.item.Agreed__c = oi.item.POG__c + currentlyRequested.get(oi.item.HybridName__c);
                        toCheck.put(oi.item.HybridName__c, oi.item.Agreed__c); 
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
        public void saveTax(){
            try{
                List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
                List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
                for(OrderItem oi : taxOrders)
                {
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != ''){
                        oi.item.ProductRef__c = oi.lookupValue.id;
                        (oi.item.id == null?toInsert:toModify).add(oi.item);
                    }
                }
                insert toInsert;
                update toModify;
                delete toDeleteTax;
                editModeTax = false;
                init();
                Util.addConfirmMessage('Done');
            }catch(Exception e){
                ApexPages.addMessages(e);
                Util.addErrorMessage(e);
            }
        }
        
        public void saveRegular(){
            try{
                List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
                List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
                for(OrderItem oi : regularOrders)
                {
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != '' && oi.item.FinalOrderRef_RSA__r.Status_RSA__c != 'Waiting for discount approval'){

                        oi.item.ProductRef__c = oi.lookupValue.id;
                        (oi.item.id == null?toInsert:toModify).add(oi.item);
                    }
                }
                insert toInsert;
                update toModify;
                delete toDeleteRegular;
                editModeRegular = false;
                init();
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
    
        }

        public void saveFebReceipt(){
            try{
                List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
                List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
                for(OrderItem oi : FebReceiptOrders)
                {
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != ''){
                        oi.item.ProductRef__c = oi.lookupValue.id;
                        (oi.item.id == null?toInsert:toModify).add(oi.item);
                    }
                }
                insert toInsert;
                update toModify;
                delete toDeleteFebReceipt;
                editModeFebReceipt = false;
                init();
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
    
        }
        
        public void saveGeneral(){
            try{
                List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
                List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
                for(OrderItem oi : generalOrders)
                {
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != '' && oi.item.FinalOrderRef_RSA__r.Status_RSA__c != 'Waiting for discount approval'){

                        oi.item.ProductRef__c = oi.lookupValue.id;
                        (oi.item.id == null?toInsert:toModify).add(oi.item);
                    }
                }
                insert toInsert;
                update toModify;
                delete toDeleteGeneral;
                editModeGeneral = false;
                init();
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
    
        }
        
        public void saveConsigned(){
            try{
                List<CampaignLineItem__c> toInsert = new List<CampaignLineItem__c>();
                List<CampaignLineItem__c> toModify = new List<CampaignLineItem__c>();
                for(OrderItem oi : consignedOrders)
                {
                    if(oi.lookupValue.id!=null && oi.lookupValue.id != ''){
                        oi.item.ProductRef__c = oi.lookupValue.id;
                        (oi.item.id == null?toInsert:toModify).add(oi.item);
                    }
                }
                insert toInsert;
                update toModify;
                delete toDeleteConsigned;
                editModeConsigned = false;
                init();
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
    
        }       
        public void deleteSelectedTax(){
            if(!editModeTax) {
                toDeleteTax = new List<CampaignLineItem__c>();
            }
            List<OrderItem> newTaxOrders = new List<OrderItem>();
            for(OrderItem oi : taxOrders)
            {
                if(oi.selected)
                {
                    if(oi.item.id != null){
                        toDeleteTax.add(oi.item);
                    }
                }else{
                    newTaxOrders.add(oi);
                }
            }
            taxOrders = newTaxOrders;
            if(!editModeTax)saveTax();
        }
        
        public void deleteSelectedRegular(){
            if(!editModeRegular) toDeleteRegular = new List<CampaignLineItem__c>();
            List<OrderItem> newRegularOrders = new List<OrderItem>();
            for(OrderItem oi : regularOrders)
            {
                if(oi.selected){
                    if(oi.item.id != null){
                        toDeleteRegular.add(oi.item);
                    }
                }else{
                    newRegularOrders.add(oi);
                }
            }
            regularOrders = newRegularOrders;
            if(!editModeRegular)saveRegular();
        }

        public void deleteSelectedFebReceipt(){
            if(!editModeFebReceipt) toDeleteFebReceipt = new List<CampaignLineItem__c>();
            List<OrderItem> newFebReceiptOrders = new List<OrderItem>();
            for(OrderItem oi : FebReceiptOrders)
            {
                if(oi.selected){
                    if(oi.item.id != null){
                        toDeleteFebReceipt.add(oi.item);
                    }
                }else{
                    newFebReceiptOrders.add(oi);
                }
            }
            FebReceiptOrders = newFebReceiptOrders;
            if(!editModeFebReceipt)saveFebReceipt();
        }
        
         public void deleteSelectedGeneral(){
            if(!editModeGeneral) toDeleteGeneral = new List<CampaignLineItem__c>();
            List<OrderItem> newGeneralOrders = new List<OrderItem>();
            for(OrderItem oi : generalOrders)
            {
                if(oi.selected){
                    if(oi.item.id != null){
                        toDeleteGeneral.add(oi.item);
                    }
                }else{
                    newGeneralOrders.add(oi);
                }
            }
            generalOrders = newGeneralOrders;
            if(!editModeGeneral)saveGeneral();
        }
        
        public void deleteSelectedConsigned(){
            if(!editModeConsigned) toDeleteConsigned = new List<CampaignLineItem__c>();
            List<OrderItem> newConsignedOrders = new List<OrderItem>();
            for(OrderItem oi : consignedOrders)
            {
                if(oi.selected){
                    if(oi.item.id != null){
                        toDeleteConsigned.add(oi.item);
                    }
                }else{
                    newConsignedOrders.add(oi);
                }
            }
            consignedOrders = newConsignedOrders;
            if(!editModeConsigned)saveConsigned();
        }
        
//button display methods. Preliminary:

        public boolean getdisplayCreatePreliminarButton()
        {
            if(regularOrders.size()==0) 
               return false;
            else
            {
                for(OrderItem oi : regularOrders)
                {
                    if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.Agreed__c>0)
                     || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Draft'))
                        return true;
                      
                }
                return false;
            }
        }
        
         public boolean getdisplayCreateGeneralPreliminarButton()
        {
            if(generalOrders.size()==0) 
               return false;
            else
            {
                for(OrderItem oi : generalOrders)
                {
                    if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.Agreed__c>0)
                     || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Draft'))
                        return true;
                      
                }
                return false;
            }
        }
        
        public boolean getdisplayCreateTaxPreliminarButton()
        {
            if(TaxOrders.size()==0) 
               return false;
            else
            {
                for(OrderItem oi : TaxOrders)
                {
                    if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.Agreed__c>0)
                     || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Draft'))
                        return true;
                      
                }
                return false;
            }
        }
        
        public boolean getdisplayCreateFebReceiptPreliminarButton()
        {
            if(FebReceiptOrders.size()==0) 
               return false;
            else
            {
                for(OrderItem oi : FebReceiptOrders)
                {
                    if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.Agreed__c>0)
                     || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Draft'))
                        return true;
                      
                }
                return false;
            }
        }          
        
        public boolean getdisplayCreateConsignedPreliminarButton()
        {
            if(consignedOrders.size()==0) 
               return false;
            else
            {
                for(OrderItem oi : consignedOrders)
                {
                    if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.Agreed__c>0)
                     || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Draft'))
                        return true;
                      
                }
                return false;
            }
        }
//button display methods. Final:
                 
        public boolean getdisplayCreateFebReceiptFinalButton()
        {
            if(FebReceiptOrders.size()==0) 
               return false;
            else
            {
                Boolean isPreliminaryCreated=false;
                
                for(OrderItem oi : FebReceiptOrders)
                {
                    if(oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed')
                    {   isPreliminaryCreated=true;
                        break;
                    }
                }
                if(isPreliminaryCreated)
                {
                    for(OrderItem oi : FebReceiptOrders)
                    {
                        if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.PoG__c>0)
                            || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed' && oi.item.PoG__c>0 ))
                        return true;                        
                    }
                }    
                return false;
            }
        }     
        
        public boolean getdisplayCreateConsignedFinalButton()
        {
            if(consignedOrders.size()==0) 
               return false;
            else
            {
                Boolean isPreliminaryCreated=false;
                
                for(OrderItem oi : consignedOrders)
                {
                    if(oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed')
                    {   isPreliminaryCreated=true;
                        break;
                    }
                }
                if(isPreliminaryCreated)
                {
                    for(OrderItem oi : consignedOrders)
                    {
                        if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.PoG__c>0)
                            || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed' && oi.item.PoG__c>0 ))
                        return true;                        
                    }
                }    
                return false;
            }
        } 
        public boolean getdisplayCreateTaxFinalButton()
        {
            if(taxOrders.size()==0) 
               return false;
            else
            {
                Boolean isPreliminaryCreated=false;
                
                for(OrderItem oi : taxOrders)
                {
                    if(oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed')
                    {   isPreliminaryCreated=true;
                        break;
                    }
                }
                if(isPreliminaryCreated)
                {
                    for(OrderItem oi : taxOrders)
                    {
                        if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.PoG__c>0)
                            || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed' && oi.item.PoG__c>0 ))
                        return true;                        
                    }
                }    
                return false;
            }

        }            

        public boolean getdisplayCreateFinalButton()
        {
            if(regularOrders.size()==0) 
               return false;
            else
            {
                Boolean isPreliminaryCreated=false;
                
                for(OrderItem oi : regularOrders)
                {
                    if(oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed')
                    {   isPreliminaryCreated=true;
                        break;
                    }
                }
                if(isPreliminaryCreated)
                {
                    for(OrderItem oi : regularOrders)
                    {
                        if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.PoG__c>0)
                            || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed' && oi.item.PoG__c>0 ))
                        return true;                        
                    }
                }    
                return false;
            }
        }   
        
         public boolean getdisplayCreateGeneralFinalButton()
        {
            if(generalOrders.size()==0) 
               return false;
            else
            {
                Boolean isPreliminaryCreated=false;
                
                for(OrderItem oi : generalOrders)
                {
                    if(oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed')
                    {   isPreliminaryCreated=true;
                        break;
                    }
                }
                if(isPreliminaryCreated)
                {
                    for(OrderItem oi : generalOrders)
                    {
                        if((oi.item.PreliminaryOrderRef_RSA__c==null && oi.item.PoG__c>0)
                            || (oi.item.FinalOrderRef_RSA__c==null && oi.item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed' && oi.item.PoG__c>0 ))
                        return true;                        
                    }
                }    
                return false;
            }
        }    
                
        public PageReference getSelected()
        {
  
        return null;
   
        }
    }
    
    public class OrderItem
    {
        public CampaignLineItem__c item {get;set;}
        public LookupValue lookupValue {get;set;}
        public Boolean selected {get;set;}
        
        private String finalOrderNames = '';
        private Boolean actionPlanFrozen = false;
        
        public boolean hasPrelim {get; set;}
        public boolean couldBeIrrigated {get; set;}
        public boolean prelimNotInDraftStatus {get; set;}
        public boolean freezeRow {get; set;}
        public boolean freezeDiscussed {get; set;}
        public boolean freezeOrdered {get; set;}
        public boolean freezeDelete {get; set;}
        
        public Integer TotalBudget {get; set;}
        public Integer TotalSales {get; set;}
        
        public OrderItem(CampaignLineItem__c paramItem, boolean isActionPlanFrozen, Integer budget, Integer sales)
        {
            this.TotalBudget=budget;
            this.TotalSales=sales;
            this.item = paramItem.clone(true, true);
            this.selected = false;
            if(item.ProductRef__c != null) lookupvalue = new LookupValue(item.ProductRef__c,item.ProductRef__r.Name);
            else lookupValue = new LookupValue();
            actionPlanFrozen = isActionPlanFrozen;
            calculateBooleans();
        }
        
        public void setFinalOrderNames(String value) {
            finalOrderNames = value;
            calculateBooleans();
        }
        
        private void calculateBooleans() {
        
            hasPrelim = (item.PreliminaryOrderRef_RSA__c != NULL);            
            prelimNotInDraftStatus = (hasPrelim && !'Draft'.equals(item.PreliminaryOrderRef_RSA__r.Status_RSA__c));
            boolean prelimInFinalClosedOrders = (hasPrelim && finalOrderNames.contains(item.PreliminaryOrderRef_RSA__r.Name));
            boolean hasFinal = (item.FinalOrderRef_RSA__c != NULL);
            boolean finalNotInDraftStatus = (hasPrelim && !'Draft'.equals(item.FinalOrderRef_RSA__r.Status_RSA__c));
            boolean finalInFinalClosedOrders = (hasFinal && finalOrderNames.contains(item.FinalOrderRef_RSA__r.Name));
            boolean forecastInformed = (item.Forecast__c != NULL && item.Forecast__c != 0);
            
            freezeRow = ((hasPrelim && prelimInFinalClosedOrders && hasFinal) || (hasFinal && finalInFinalClosedOrders));
            freezeDiscussed = (freezeRow || item.PreliminaryOrderRef_RSA__r.Status_RSA__c=='Closed');
            freezeOrdered = (freezeRow || (hasFinal && finalNotInDraftStatus));
            freezeDelete = (freezeDiscussed || freezeOrdered || (actionPlanFrozen && forecastInformed));

        }
    }
    
    public List<CampaignLineItem> tacticalPlans
    {
        get
        {
             return ( List<CampaignLineItem> ) wrapperObjects;
        }
        set;
    }
    
    public Map<String, map<String,Double>> extraInformation
    {
        get
        {
            extraInformation = new Map<String, Map<String,Double>>();
            Set<ID> itemsOrderedByID = new Set<ID>();
            for(OrderItem oi : theActionPlan.taxOrders)
            {
                if(oi.item.ProductRef__c != null){
                    itemsOrderedByID.add(oi.item.ProductRef__r.id);
                    extraInformation.put(oi.item.ProductRef__r.id,new Map<String,Double>{'CHARGED_PY'=>0});
                }
            }
            for(OrderItem oi : theActionPlan.regularOrders)
            {
                if(oi.item.ProductRef__c != null){
                    itemsOrderedById.add(oi.item.ProductRef__r.id);
                    extraInformation.put(oi.item.ProductRef__r.id,new Map<String,Double>{'CHARGED_PY'=>0});
                }
            }

           for(OrderItem oi : theActionPlan.FebReceiptOrders)
            {
                if(oi.item.ProductRef__c != null){
                    itemsOrderedById.add(oi.item.ProductRef__r.id);
                    extraInformation.put(oi.item.ProductRef__r.id,new Map<String,Double>{'CHARGED_PY'=>0});
                }
            } 
            
           for(OrderItem oi : theActionPlan.consignedOrders)
            {
                if(oi.item.ProductRef__c != null){
                    itemsOrderedById.add(oi.item.ProductRef__r.id);
                    extraInformation.put(oi.item.ProductRef__r.id,new Map<String,Double>{'CHARGED_PY'=>0});
                }
            }  
                                
            if(Util.previewsCampaign != null){
                List<AggregateResult> itemsOrdered = [
                    SELECT
                        SUM(PoG__c) sumPoG,
                        ProductRef__c
                    FROM
                        CampaignLineItem__c
                    WHERE
                        ProductRef__c in :itemsOrderedByID AND
                        CampaignRef__c = :Util.previewsCampaign.ID
                    GROUP BY 
                        ProductRef__c];
                for(AggregateResult ag : itemsOrdered)
                {
                    if(ag.get('sumPoG')!=null){
                        extraInformation.get((String)ag.get('ProductRef__c')).put('CHARGED_PY',(Decimal)ag.get('sumPoG'));
                    }
                }
            }
            return extraInformation;
        }set;
    }
    
    private transient Map<String, Double> sumOfNumberFields;
    
    public Map<String,Double> getSumOfNumberFields()
    {
    if(sumOfNumberFields == null)
    {
        sumOfNumberFields = new Map<String, Double>();
        sumOfNumberFields.put('TAX_CY_FORECAST',0);
        sumOfNumberFields.put('TAX_CY_DISCUSSED',0);
        sumOfNumberFields.put('TAX_CY_ORDERED',0);
    
        sumOfNumberFields.put('REGULAR_CY_FORECAST',0);
        sumOfNumberFields.put('REGULAR_CY_DISCUSSED',0);
        sumOfNumberFields.put('REGULAR_CY_ORDERED',0);
        
        sumOfNumberFields.put('FEBRECEIPT_CY_FORECAST',0);
        sumOfNumberFields.put('FEBRECEIPT_CY_DISCUSSED',0);
        sumOfNumberFields.put('FEBRECEIPT_CY_ORDERED',0);
        
        sumOfNumberFields.put('GENERAL_CY_FORECAST',0);
        sumOfNumberFields.put('GENERAL_CY_DISCUSSED',0);
        sumOfNumberFields.put('GENERAL_CY_ORDERED',0);
        
        sumOfNumberFields.put('CONSIGNED_CY_FORECAST',0);
        sumOfNumberFields.put('CONSIGNED_CY_DISCUSSED',0);
        sumOfNumberFields.put('CONSIGNED_CY_ORDERED',0);        
       
        if(theActionPlan != null && theActionPlan.taxOrders != null && theActionPlan.regularOrders != null && theActionPlan.FebReceiptOrders != null && theActionPlan.consignedOrders != null){
            for(OrderItem oi : theActionPlan.taxOrders){
                if(oi.item.Forecast__c != null){
                    sumOfNumberFields.put('TAX_CY_FORECAST',sumOfNumberFields.get('TAX_CY_FORECAST') + oi.item.Forecast__c);
                }
                if(oi.item.Agreed__c != null){
                    sumOfNumberFields.put('TAX_CY_DISCUSSED',sumOfNumberFields.get('TAX_CY_DISCUSSED') + oi.item.Agreed__c);
                }
                if(oi.item.PoG__c != null){
                    sumOfNumberFields.put('TAX_CY_ORDERED',sumOfNumberFields.get('TAX_CY_ORDERED') + oi.item.PoG__c);
                }
            }
            
            for(OrderItem oi : theActionPlan.regularOrders){
                if(oi.item.Forecast__c != null){
                    sumOfNumberFields.put('REGULAR_CY_FORECAST',sumOfNumberFields.get('REGULAR_CY_FORECAST') + oi.item.Forecast__c);
                }
                if(oi.item.Agreed__c != null){
                    sumOfNumberFields.put('REGULAR_CY_DISCUSSED',sumOfNumberFields.get('REGULAR_CY_DISCUSSED') + oi.item.Agreed__c);
                }
                if(oi.item.PoG__c != null){
                    sumOfNumberFields.put('REGULAR_CY_ORDERED',sumOfNumberFields.get('REGULAR_CY_ORDERED') + oi.item.PoG__c);
                }
            }
            
            for(OrderItem oi : theActionPlan.FebReceiptOrders){
                if(oi.item.Forecast__c != null){
                    sumOfNumberFields.put('FEBRECEIPT_CY_FORECAST',sumOfNumberFields.get('FEBRECEIPT_CY_FORECAST') + oi.item.Forecast__c);
                }
                if(oi.item.Agreed__c != null){
                    sumOfNumberFields.put('FEBRECEIPT_CY_DISCUSSED',sumOfNumberFields.get('FEBRECEIPT_CY_DISCUSSED') + oi.item.Agreed__c);
                }
                if(oi.item.PoG__c != null){
                    sumOfNumberFields.put('FEBRECEIPT_CY_ORDERED',sumOfNumberFields.get('FEBRECEIPT_CY_ORDERED') + oi.item.PoG__c);
                }
            }
            
            for(OrderItem oi : theActionPlan.generalOrders){
                if(oi.item.Forecast__c != null){
                    sumOfNumberFields.put('GENERAL_CY_FORECAST',sumOfNumberFields.get('GENERAL_CY_FORECAST') + oi.item.Forecast__c);
                }
                if(oi.item.Agreed__c != null){
                    sumOfNumberFields.put('GENERAL_CY_DISCUSSED',sumOfNumberFields.get('GENERAL_CY_DISCUSSED') + oi.item.Agreed__c);
                }
                if(oi.item.PoG__c != null){
                    sumOfNumberFields.put('GENERAL_CY_ORDERED',sumOfNumberFields.get('GENERAL_CY_ORDERED') + oi.item.PoG__c);
                }
            }
            
            for(OrderItem oi : theActionPlan.consignedOrders){
                if(oi.item.Forecast__c != null){
                    sumOfNumberFields.put('CONSIGNED_CY_FORECAST',sumOfNumberFields.get('CONSIGNED_CY_FORECAST') + oi.item.Forecast__c);
                }
                if(oi.item.Agreed__c != null){
                    sumOfNumberFields.put('CONSIGNED_CY_DISCUSSED',sumOfNumberFields.get('CONSIGNED_CY_DISCUSSED') + oi.item.Agreed__c);
                }
                if(oi.item.PoG__c != null){
                    sumOfNumberFields.put('CONSIGNED_CY_ORDERED',sumOfNumberFields.get('CONSIGNED_CY_ORDERED') + oi.item.PoG__c);
                }
            }        }
    }
    return sumOfNumberFields;
    }

}