@RestResource(urlMapping='/getDeletedLogicalEntity/ProductEast/*')
global with sharing class REST_DelLogicalEntityProductEast{

    @HttpPost
    global static REST_DelLogicalEntity_Product getDeletedProducts(REST_DelLogicalEntity_Product paramInfo)
    {
        REST_DelLogicalEntity_Product returned = new REST_DelLogicalEntity_Product();
        
        returned.products = new List<Product2>();
        Map<ID,Product2> paramInfoProducts = new Map<ID,Product2>(paramInfo.Products);
        Set<ID> paramInfoProductIDs = paramInfoProducts.keySet();
        
        Map<ID,Product2> currentProducts = new Map<ID,Product2>([SELECT ID FROM Product2 WHERE ID IN :paramInfoProductIDs]);
        Set<ID> currentProductIDs = currentProducts.keySet();
        
        paramInfoProductIDs.removeAll(currentProductIDs);
        for(ID i : paramInfoProductIDs){
            returned.Products.add(paramInfoProducts.get(i));
        }
        
        Set<ID> activeCatalogs = new Set<Id>();
        activeCatalogs = UtilREST.activeSalesCatalogs;
        for(Id catalogue : UtilREST.activeTrialCatalogs)   
        	activeCatalogs.add(catalogue);

        returned.ProductCatalogEntries = new List<ProductCatalogEntry__c>();
        Map<ID,ProductCatalogEntry__c> paramInfoProductCatalogEntries = new Map<ID,ProductCatalogEntry__c>(paramInfo.ProductCatalogEntries);
        Set<ID> paramInfoProductCatalogEntryIDs = paramInfoProductCatalogEntries.keySet();
        
        Map<ID,ProductCatalogEntry__c> currentProductCatalogEntries = new Map<ID,ProductCatalogEntry__c> ([
            SELECT ID FROM ProductCatalogEntry__c 
            WHERE ID IN :paramInfoProductCatalogEntryIDs AND ProductCatalogRef__c in: activeCatalogs
            ]);
        Set<ID> currentProductCatalogEntryIDs = currentProductCatalogEntries.keySet();
        
        paramInfoProductCatalogEntryIDs.removeAll(currentProductCatalogEntryIDs);
        for(ID i : paramInfoProductCatalogEntryIDs){
            returned.ProductCatalogEntries.add(paramInfoProductCatalogEntries.get(i));
        }
        
        
        returned.ProductCatalogs = new List<ProductCatalog__c>();
        Map<ID,ProductCatalog__c> paramInfoProductCatalogs = new Map<ID,ProductCatalog__c>(paramInfo.ProductCatalogs);
        Set<ID> paramInfoProductCatalogIDs = paramInfoProductCatalogs.keySet();
        
        Map<ID,ProductCatalog__c> currentProductCatalogs = new Map<ID,ProductCatalog__c>([
            SELECT ID FROM ProductCatalog__c 
            WHERE /*ID IN :paramInfoProductCatalogIDs AND*/ ID in : activeCatalogs
            ]);
        Set<ID> currentProductCatalogIDs = currentProductCatalogs.keySet();
        
        paramInfoProductCatalogIDs.removeAll(currentProductCatalogIDs);
        for(ID i : paramInfoProductCatalogIDs){
            returned.ProductCatalogs.add(paramInfoProductCatalogs.get(i));
        }
        
        
        returned.Stocks = new List<Stock__c>();
     
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Product getExample()
    {
        REST_DelLogicalEntity_Product returned = new REST_DelLogicalEntity_Product();
        
        returned.stocks = [SELECT ID FROM Stock__c LIMIT 2];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Product {
        public List<Product2> products;
        public List<ProductCatalogEntry__c> productCatalogEntries;
        public List<ProductCatalog__c> productCatalogs;
        public List<Stock__c> stocks;
    }
    
    
    
    
    
    
    
    
}