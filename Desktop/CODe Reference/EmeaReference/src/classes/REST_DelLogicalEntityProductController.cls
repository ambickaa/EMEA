@RestResource(urlMapping='/getDeletedLogicalEntity/Product_5/*')
global with sharing class REST_DelLogicalEntityProductController{

    @HttpPost
    global static REST_DelLogicalEntity_Product getDeletedProducts(REST_DelLogicalEntity_Product paramInfo)
    {
        REST_DelLogicalEntity_Product returned = new REST_DelLogicalEntity_Product();
        
        User currentUser = [SELECT managerID, ManagersManagerID_RSA__c FROM User WHERE id = :UserInfo.getUserId()];
               
   
        
        returned.ProductCatalogEntries = new List<ProductCatalogEntry__c>();
        Map<ID,ProductCatalogEntry__c> paramInfoProductCatalogEntries = new Map<ID,ProductCatalogEntry__c>(paramInfo.ProductCatalogEntries);
        Set<ID> paramInfoProductCatalogEntryIDs = paramInfoProductCatalogEntries.keySet();
        
        Set<ID> currentProductCatalogEntryIDs = new set<ID>();
        Set<ID> productsInCatalogs = new set<ID>();
        
        for(ProductCatalogEntry__c pce: [
	        SELECT ID,ProductRef__c FROM ProductCatalogEntry__c 
	        WHERE  ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA
	        ])
	    {
	    	productsInCatalogs.add(pce.ProductRef__c); 
	    	currentProductCatalogEntryIDs.add(pce.ID);	
	    	 	
	    }
               
        paramInfoProductCatalogEntryIDs.removeAll(currentProductCatalogEntryIDs);
        for(ID i : paramInfoProductCatalogEntryIDs){
            returned.ProductCatalogEntries.add(paramInfoProductCatalogEntries.get(i));
        }
        
       returned.products = new List<Product2>();
        Map<ID,Product2> paramInfoProducts = new Map<ID,Product2>(paramInfo.Products);
        Set<ID> paramInfoProductIDs = paramInfoProducts.keySet();
        
        Map<ID,Product2> currentProducts = new Map<ID,Product2>([
        SELECT ID FROM Product2 WHERE  ID in: productsInCatalogs]);
        Set<ID> currentProductIDs = currentProducts.keySet();
        
        paramInfoProductIDs.removeAll(currentProductIDs);
        for(ID i : paramInfoProductIDs){
            returned.Products.add(paramInfoProducts.get(i));
        }       
        
        
        
        returned.ProductCatalogs = new List<ProductCatalog__c>();
        Map<ID,ProductCatalog__c> paramInfoProductCatalogs = new Map<ID,ProductCatalog__c>(paramInfo.ProductCatalogs);
        Set<ID> paramInfoProductCatalogIDs = paramInfoProductCatalogs.keySet();
        
        Map<ID,ProductCatalog__c> currentProductCatalogs = new Map<ID,ProductCatalog__c>([
        	SELECT ID FROM ProductCatalog__c 
        	WHERE /*ID IN :paramInfoProductCatalogIDs AND*/ Id in: UtilREST.activeSalesCatalogsRSA        	
        ]);
        
        Set<ID> currentProductCatalogIDs = currentProductCatalogs.keySet();
        
        paramInfoProductCatalogIDs.removeAll(currentProductCatalogIDs);
        for(ID i : paramInfoProductCatalogIDs){
            returned.ProductCatalogs.add(paramInfoProductCatalogs.get(i));
        }
        
        
        returned.Stocks = new List<Stock__c>();
        Map<ID,Stock__c> paramInfoStocks = new Map<ID,Stock__c>(paramInfo.Stocks);
        Set<ID> paramInfoStockIDs = paramInfoStocks.keySet();
        
        Map<ID,Stock__c> currentStocks = new Map<ID,Stock__c>([
       		 SELECT ID FROM Stock__c WHERE /*ID IN :paramInfoStockIDs
	       		 AND*/  (/*User_RSA__c = :currentUser.ID OR */User_RSA__c = :currentUser.managerID OR User_RSA__c = :currentUser.ManagersManagerID_RSA__c)
	       		 AND ProductCatalogEntryRef_RSA__c in : currentProductCatalogEntryIDs 
	    ]);
	    
        Set<ID> currentStockIDs = currentStocks.keySet();
        
        paramInfoStockIDs.removeAll(currentStockIDs);
        for(ID i : paramInfoStockIDs){
            returned.Stocks.add(paramInfoStocks.get(i));
        }
        
        returned.budgets = new List<Budget__c>();
        Map<ID,Budget__c> paramInfoBudgets = new Map<ID,Budget__c>(paramInfo.budgets);
        Set<ID> paramInfoBudgetIDs = paramInfoBudgets.keySet();
        
        Map<ID,Budget__c> currentBudgets = new Map<ID,Budget__c>([
	        SELECT ID FROM Budget__c WHERE /*ID IN :paramInfoBudgetIDs
	        AND*/ SalesRep__c= :Util.currentUser.ID AND YearRef__c=: UtilREST.currentYearRSA
	        AND ProductRef__c in: currentProductIDs]);
	        
        Set<ID> currentBudgetIDs = currentBudgets.keySet();
        
        paramInfoBudgetIDs.removeAll(currentBudgetIDs);
        for(ID i : paramInfoBudgetIDs){
            returned.budgets.add(paramInfoBudgets.get(i));
        }
        
        
        returned.hybrids = new List<Hybrid__c>();
        Map<ID,Hybrid__c> paramInfoHybrids = new Map<ID,Hybrid__c>(paramInfo.hybrids);
        Set<ID> paramInfoHybridIDs = paramInfoHybrids.keySet();
        
        Map<ID,Hybrid__c> currentHybrids = new Map<ID,Hybrid__c>([
	        SELECT ID FROM Hybrid__c WHERE 
	        		ID IN :paramInfoHybridIDs
			        AND (NOT( UserRef__c != :currentUser.managerID 
			        AND UserRef__c != :currentUser.ManagersManagerID_RSA__c))
					AND ProductCatalogRef__c in: UtilREST.activeSalesCatalogsRSA]);
	        
        Set<ID> currentHybridIDs = currentHybrids.keySet();
        
        paramInfoHybridIDs.removeAll(currentHybridIDs);
        for(ID i : paramInfoHybridIDs){
            returned.hybrids.add(paramInfoHybrids.get(i));
        }
        
        
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Product getExample()
    {
        REST_DelLogicalEntity_Product returned = new REST_DelLogicalEntity_Product();
        User currentUser = [SELECT managerID, ManagersManagerID_RSA__c FROM User WHERE id = :UserInfo.getUserId()];
        returned.productCatalogEntries = [SELECT ID, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c in: UtilREST.activeSalesCatalogsRSA ];
        
        returned.products=new List<Product2>();
        List<ID> productsinPCE = new List<ID> ();
        
        for(ProductCatalogEntry__c pce : returned.productCatalogEntries)
        {
        	productsinPCE.add(pce.ProductRef__c);
        }
  
  		returned.products = [SELECT ID FROM Product2 WHERE ID in:productsinPCE];
  		
  	
        returned.productCatalogs = [SELECT ID FROM ProductCatalog__c WHERE ID in:UtilREST.activeSalesCatalogsRSA ];
        returned.stocks = [SELECT ID FROM Stock__c WHERE User_RSA__c =:currentUser.managerID ];
        returned.budgets = [SELECT ID FROM Budget__c WHERE SalesRep__c=:Util.currentUser.ID ];
        returned.hybrids = [SELECT ID FROM Hybrid__c  LIMIT 10 ];
         
        return returned;
    } 
    
    global class REST_DelLogicalEntity_Product {
        public List<Product2> products;
        public List<ProductCatalogEntry__c> productCatalogEntries;
        public List<ProductCatalog__c> productCatalogs;
        public List<Stock__c> stocks;
        public List<Budget__c> budgets;
        public List<Hybrid__c> hybrids;
    }
    
    
    
    static testMethod void testRest() {
        // set up the request object
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/getDeletedLogicalEntity/Product_5';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');
        // Invoke the method directly
        
        REST_DelLogicalEntity_Product param = new REST_DelLogicalEntity_Product();
        param.products = new List<Product2>();
        param.productCatalogEntries = new List<ProductCatalogEntry__c>();
        param.productCatalogs = new List<ProductCatalog__c>();
        param.stocks = new List<Stock__c>();
        param.budgets = new List<Budget__C>();
        param.hybrids = new List<Hybrid__c>();
        
        try {REST_DelLogicalEntityProductController.getDeletedProducts(param);
        }
        catch(Exception e)
        {
        	
        }
    }
    
    
    
    
}