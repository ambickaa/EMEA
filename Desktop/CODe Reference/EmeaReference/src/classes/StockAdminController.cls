public without sharing class StockAdminController {

    public String tempDelete {get;set;}
    /*[Stock Pagination] Resolution to load Stock Page (view state limit error)*/
    public transient List<Fila> products {get;set;}
    public List<User> users {get;set;}
    public Map<ID,User> usersMap {get;set;}
    /*[Stock Pagination] Resolution to load Stock Page (view state limit error)*/
    public transient Map<ID,Map<ID,Stock__c>> stocksMap {get;set;}
    public List<User> currentUser {get;set;}
    public  Map<ID,Map<ID,Stock__c>> currentStockMap {get;set;}

    public Integer offset {get{if(offset == null) offset = 0; return offset;}set;}
    public Integer pageSize {get{if(pageSize == null) pageSize = (SystemSettings__c.getValues('RSA_STOCK_PAGE_SIZE') == null?1:Integer.valueOf(SystemSettings__c.getValues('RSA_STOCK_PAGE_SIZE').Value__c)); return pageSize;} private set;}
    
    public StockAdminController(){
        getInfo();
    }

    public void Save() {
        List<Stock__c> stocksToUpdate = new List<Stock__c>();
        List<Stock__c> stocksToInsert = new List<Stock__c>();
        
        ID currentUserID = UserInfo.getUserID();
        Boolean cancelDML = false;
        //pdte sumaStock a 0
        for(Map<ID,Stock__c> stocksRow : stocksMap.values()){
            Integer currentCount = 0;
            Integer currentMax;
            for(Stock__c s : stocksRow.values()){
                if(s.User_RSA__c == currentUserID){
                    currentMax = Integer.valueOf(s.Allocation_RSA__c);
                }else{
                    if(s.id==null) stocksToInsert.add(s);
                    else stocksToUpdate.add(s);
                    
                    if(Util.urlParameters.get('Catalog') == null || Util.urlParameters.get('Catalog') == 'Regular'){
                        if(s.Allocation_RSA__c == null)s.Allocation_RSA__c = 0;
                        currentCount += Integer.valueOf(s.Allocation_RSA__c);
                    }else{
                        if(s.TaxAllocation_RSA__c == null) s.TaxAllocation_RSA__c = 0;
                    }
                }
                
            }
            if(currentMax != null && currentCount > currentMax && !cancelDML){
                Util.addErrorMessage('You can not allocate more bags than the ones you have allocated ');
                cancelDML = true;
            }
                
        }
        
        if(!cancelDML){
            try{
                insert stocksToInsert;
                update stocksToUpdate;
                Util.addConfirmMessage('Saved');
            }catch(Exception e){
                ApexPages.addMessages(e);
            }
        }

    }
    

    public void getInfo(){

        ID adminProfileID = '00eD0000001lv5N';
        if(UserInfo.getProfileId() == adminProfileID){
            users = [SELECT Name, isActive FROM User WHERE Is_Country_Manager__c = true AND CountryISOCode__c = 'RSA' AND IsActive=True ]; //A
        }else{
            users = [SELECT Name, isActive FROM User WHERE CountryISOCode__c = 'RSA' AND ManagerID = :UserInfo.getUserId() AND IsActive=True]; //A

        }
        usersMap = new Map<ID,User>(users);
        List<Stock__c> usersStocks= new List<Stock__c>();
        
        if(Util.urlParameters.get('Catalog') == null || Util.urlParameters.get('Catalog') == 'Regular'){
         	
     
            usersStocks = [SELECT ProductCatalogEntryRef_RSA__c, Allocation_RSA__c, Quantity_RSA__c, StockLeft_RSA__c, User_RSA__c FROM Stock__c WHERE (User_RSA__c in :users OR User_RSA__c = :UserInfo.getUserId()) AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c = :Util.currentYear.id]; // B
        }else{
            usersStocks = [SELECT ProductCatalogEntryRef_RSA__c, TaxAllocation_RSA__c, TaxQuantity_RSA__c, TaxStockLeft_RSA__c, User_RSA__c FROM Stock__c WHERE User_RSA__c in :users AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c = :Util.lastYear.id]; // B
        }
        stocksMap = new Map<Id,Map<Id,Stock__c>>(); // Map<ProductID,Map<UserID,Stock__c>>
        
        currentUser = [SELECT Name FROM User WHERE CountryISOCode__c = 'RSA' AND ID = :UserInfo.getUserId()];
        List<Stock__c> currentUserStock = [SELECT ProductCatalogEntryRef_RSA__c, Allocation_RSA__c, Quantity_RSA__c, StockLeft_RSA__c, User_RSA__c FROM Stock__c WHERE User_RSA__c = :currentUser];
        currentStockMap = new Map<Id,Map<Id,Stock__c>>();
                
        for(Stock__c stock : usersStocks){
            if(stocksMap.get(stock.ProductCatalogEntryRef_RSA__c) == null){
                stocksMap.put(stock.ProductCatalogEntryRef_RSA__c,new Map<ID,Stock__c>{stock.User_RSA__c=>stock});
            }else{
                stocksMap.get(stock.ProductCatalogEntryRef_RSA__c).put(stock.User_RSA__c,stock);
            } 
            if(currentStockMap.get(stock.ProductCatalogEntryRef_RSA__c)==null){	
               currentStockMap.put(stock.ProductCatalogEntryRef_RSA__c,new Map<ID,Stock__c>{UserInfo.getUserId()=>new Stock__c()});
            }   
        }    
        
        for(Stock__c stock2 : currentUserStock ){
            if(currentStockMap.get(stock2.ProductCatalogEntryRef_RSA__c) == null){
                currentStockMap.put(stock2.ProductCatalogEntryRef_RSA__c,new Map<ID,Stock__c>{stock2.User_RSA__c=>stock2});
            }else{
                currentStockMap.get(stock2.ProductCatalogEntryRef_RSA__c).put(stock2.User_RSA__c,stock2);
            }   
        }    
        
        products = new List<Fila>();
        List<Stock__c> toInsert = new List<Stock__c>();
        for(ProductCatalogEntry__c pce : [SELECT ProductRef__r.Name, ProductRef__r.ProductKernelSize__c, ProductRef__r.ProductTreatment__c FROM ProductCatalogEntry__c WHERE ID IN :stocksMap.keySet()]){ // C
            Map<ID,Stock__c> StocksForLoop = stocksMap.get(pce.ID);
            products.add(new Fila(pce));
            
            for(User u : users){
                if(stocksForLoop.get(u.id) == null){
                    stocksForLoop.put(u.id,new Stock__c(ProductCatalogEntryRef_RSA__c=pce.id, Allocation_RSA__c = 0, User_RSA__c = u.ID, Quantity_RSA__c = 0));
                }
            }
        }
    }
    
    public List<Fila> getPagedProducts(){
    	
    	/*[Stock Pagination] Resolution to load Stock Page (view state limit error)*/
        List<Stock__c> usersStocks= new List<Stock__c>();
        if(Util.urlParameters.get('Catalog') == null || Util.urlParameters.get('Catalog') == 'Regular'){
            usersStocks = [SELECT ProductCatalogEntryRef_RSA__c, Allocation_RSA__c, Quantity_RSA__c, StockLeft_RSA__c, User_RSA__c FROM Stock__c WHERE (User_RSA__c in :users OR User_RSA__c = :UserInfo.getUserId()) AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c = :Util.currentYear.id]; // B
        }else{
            usersStocks = [SELECT ProductCatalogEntryRef_RSA__c, TaxAllocation_RSA__c, TaxQuantity_RSA__c, TaxStockLeft_RSA__c, User_RSA__c FROM Stock__c WHERE User_RSA__c in :users AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__r.YearRef__c = :Util.lastYear.id]; // B
        }
        stocksMap = new Map<Id,Map<Id,Stock__c>>();
        for(Stock__c stock : usersStocks){
            if(stocksMap.get(stock.ProductCatalogEntryRef_RSA__c) == null){
                stocksMap.put(stock.ProductCatalogEntryRef_RSA__c,new Map<ID,Stock__c>{stock.User_RSA__c=>stock});
            }else{
                stocksMap.get(stock.ProductCatalogEntryRef_RSA__c).put(stock.User_RSA__c,stock);
            }    
        }
        products = new List<Fila>();
        List<Stock__c> toInsert = new List<Stock__c>();
        for(ProductCatalogEntry__c pce : [SELECT ProductRef__r.Name, ProductRef__r.ProductKernelSize__c, ProductRef__r.ProductTreatment__c FROM ProductCatalogEntry__c WHERE ID IN :stocksMap.keySet()]){ // C
            Map<ID,Stock__c> StocksForLoop = stocksMap.get(pce.ID);
            products.add(new Fila(pce));
            
            for(User u : users){
                if(stocksForLoop.get(u.id) == null){
                    stocksForLoop.put(u.id,new Stock__c(ProductCatalogEntryRef_RSA__c=pce.id, Allocation_RSA__c = 0, User_RSA__c = u.ID, Quantity_RSA__c = 0));
                }
            }
        }   
        /* END [Stock Pagination] Resolution to load Stock Page (view state limit error)*/   
      
        List<Fila> returned = new List<Fila>();
        for(Integer i = offset; i < products.size() && i < offset + pageSize;  i++){
            returned.add(products.get(i));
        }

        return returned;
    }
    
    public List<Stock__c> getMyStock(){
        return [Select ProductCatalogEntryRef_RSA__c, Allocation_RSA__c, User_RSA__c From Stock__c];
    }
    
    public PageReference gotoProductStockPicker() {
        PageReference returned = Page.ProductStockPicker.setRedirect(true);
        if(Util.urlParameters.get('catalog') == null || Util.urlParameters.get('catalog') == 'Regular'){
            returned.getParameters().put('catalog','Regular');
        }else{
            returned.getParameters().put('catalog','Tax');
        }
        return returned;
    }
    
    public PageReference gotoStockTax(){
        PageReference returned = Page.Stock.setRedirect(true);
        returned.getParameters().put('catalog','Tax');
        return returned;
    }
    
    public PageReference gotoStockRegular(){
        PageReference returned = Page.Stock.setRedirect(true);
        returned.getParameters().put('catalog','Regular');
        return returned;
    }

    public class Fila{
        public productCatalogEntry__c product {get;set;}
        public Boolean selected {get;set;}
        public Fila(ProductCatalogEntry__c productParam){
            selected = false;
            product = productParam;
        }
    }

    public static testMethod void testStockAdminController(){
    	Year__c year1= new Year__c();year1.Name='2013';year1.Current_Year__c=true;
    	year1.YearEndDate__c=date.newinstance(2013, 2, 17);
    	year1.YearStartDate__c=date.newinstance(2013, 2, 17);
    	insert year1;
        StockAdminController controller = new StockAdminController();
        controller.Save();
        controller.getMyStock();
        controller.gotoProductStockPicker();
        controller.gotoStockTax();
        controller.gotoStockRegular();
       
    }
}