@RestResource(urlMapping='/getLogicalEntity/Product_5/*')
global with sharing class REST_LogicalEntityProductController{
   
    public static final Integer queryLimit = 500;
    @HttpPost
    global static REST_LogicalEntity_Product getProducts(REST_Request paramInfo)
    {
        REST_Request tRequest = paramInfo;          
        REST_LogicalEntity_Product returned = new REST_LogicalEntity_Product();
        
        returned.pagetimestamp=tRequest.pagetimestamp;        
        returned.lastItem=tRequest.lastItem;
        returned.lastId='';
        returned.mode=tRequest.mode;
        
        User currentUser = [select managerID, ManagersManagerID_RSA__c FROM User WHERE id = :UserInfo.getUserId()];
        Set<ID> ValidPce = new Set<ID>();
        Set<ID> ValidProducts = new Set<ID>();
        Set<ID> productsWithChangedStock = new Set<ID>();
        Set<ID> productsWithChangedBudget = new Set<ID>();
            
        Set<Id> additionalProducts = new Set<Id>();
        
        Set<Id> TaxCatalog = new Set<ID>();
        Set<Id> RegCatalog = new Set<ID>();
        
        if(UtilREST.currentCampaignRSA!= null && UtilREST.currentCampaignRSA.SalesPCMRef__c!=null)
            RegCatalog.add(UtilREST.currentCampaignRSA.SalesPCMRef__c);
        if(UtilREST.currentCampaignRSA!= null && UtilREST.currentCampaignRSA.TaxSalesPCMRef_RSA__c!=null)
            TaxCatalog.add(UtilREST.currentCampaignRSA.TaxSalesPCMRef_RSA__c);
              
        for(Stock__c s : [
            SELECT ProductCatalogEntryRef_RSA__c FROM Stock__c 
            WHERE (NOT ( User_RSA__c != :currentUser.managerID AND User_RSA__c != :currentUser.ManagersManagerID_RSA__c) )
            AND LastModifiedDate > :tRequest.pagetimestamp AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA])
            {
                productsWithChangedStock.add(s.ProductCatalogEntryRef_RSA__c);         
            }
            
        for(Budget__c b : [
            SELECT ProductRef__c FROM Budget__c 
            WHERE SalesRep__c = :currentUser.ID and YearRef__c =: UtilREST.currentYearRSA
            AND LastModifiedDate > :tRequest.pagetimestamp AND ProductRef__c in ( SELECT ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__r.RecordTypeId = :Util.RecordType.get('ProductCatalog__c:SalesProductCatalog')
                 AND ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA AND ProductRef__c!=null)])
            {
                productsWithChangedBudget.add(b.ProductRef__c);         
            }
 
 
        returned.hybrids = new List<Hybrid__c>();
        returned.productCatalogs = new List<ProductCatalog__c>();
        
        returned.productCatalogLines= new List<ProductCatalogEntry__c>();
        
        if(tRequest.mode==0)
        {
            for(Hybrid__c hy :  [SELECT Allocation__c,
                                        Consigned__c,
                                        IdDevice__c,
                                        LastModifiedDate,
                                        Name,
                                        ProductCatalogRef__c,
                                        Quantity__c,
                                        Stockleft__c,
                                        TaxAllocation__c,
                                        TaxQuantity__c,
                                        TaxStockleft__c,
                                        UserRef__c 
                                        FROM Hybrid__c
                                        WHERE LastModifiedDate > :tRequest.pagetimestamp
                                        AND  (NOT( UserRef__c != :currentUser.managerID AND UserRef__c != :currentUser.ManagersManagerID_RSA__c))
                                        AND ProductCatalogRef__c in: UtilREST.activeSalesCatalogsRSA
                                ])
            {
                returned.hybrids.add(hy);       
            }
            
           returned.productCatalogs = [
                SELECT
                    CountryID__c,
                    CountryRef__c,
                    YearRef__c,
                    DivisionRef__c,
                    LastModifiedDate
                FROM
                    ProductCatalog__c
                WHERE
                    ID in :UtilREST.activeSalesCatalogsRSA  ];  
            
        }

        
        for(ProductCatalogEntry__c pce: [
            SELECT 
                Name,
                isActive__c,
                isUsed__c,
                productRef__c,
                productCatalogRef__c,
                Price__c,
                PriceOld__c,
                LastModifiedDate,
                NUM_PriceGeneral__c,
                Consigned__c,
               (
                    SELECT
                        Quantity_RSA__c,
                        TaxQuantity_RSA__c,
                        Allocation_RSA__c,
                        TaxAllocation_RSA__c,
                        User_RSA__c,
                        Consigned__c,
                        HybridRef__c,
                        LastModifiedDate
                    FROM
                        Stocks__r
                    WHERE
                        (NOT ((NOT(User_RSA__c = :currentUser.managerID AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__c in : RegCatalog )) AND (NOT(
                        User_RSA__c = :currentUser.ManagersManagerID_RSA__c AND ProductCatalogEntryRef_RSA__r.ProductCatalogRef__c in : TaxCatalog ))))
                        AND LastModifiedDate > :tRequest.pagetimestamp
                  )              
                FROM ProductCatalogEntry__c
                WHERE 
                    ProductCatalogRef__r.RecordTypeId IN (:Util.RecordType.get('ProductCatalog__c:SalesProductCatalog'),:Util.RecordType.get('ProductCatalog__c:CompetitorProductCatalog'),:Util.RecordType.get('ProductCatalog__c:TrialsProductCatalog'))
                    AND ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA AND ProductRef__c!=null   
                    AND (NOT (lastModifiedDate <= :tRequest.pagetimestamp AND ID NOT IN :productsWithChangedStock) )
                    AND  Price__c!=null
                    AND ID> : tRequest.lastId
                    ORDER BY ID 
                    LIMIT : (queryLimit)                              
         ])
         {
            additionalProducts.add(pce.ProductRef__c);
            returned.productCatalogLines.add(pce);
         }
                  
        returned.products = [
            SELECT
                isActive,
                productCode,
                description,
                Name,
                RecordTypeId,
                ProductBagSize__c,
                ProductBagWeight__c,
                ProductBrandName__c,
                ProductGrdSizCD__c,
                ProductKernelSize__c,
                ProductLabel__c,
                ProductPkgSizCD__c,
                ProductPkgTypCD__c,
                ProductCategory__c,
                ProductDisplayName__c,
                ProductSAPCode__c,
                ProductTagGroup__c,
                ProductTreatment__c,
                DivisionRef__c,
                ProductVendor__c,
                lastModifiedDate,
                Product_Packing__c,
                  (
                    SELECT Id, LastModifiedDate, TotalSales__c, TotalBudget__c, SalesRep__c 
                    FROM Budgets__r
                    WHERE SalesRep__c =: currentUser.ID AND YearRef__c=: UtilREST.currentYearRSA AND LastModifiedDate > :tRequest.pagetimestamp
                  )               
            FROM
                Product2
            WHERE
                ID in : additionalProducts ];
      
                 
     returned.calculateTimestamp(tRequest.maxtimestamp);
          
     return returned;
    }
    
    
    global class REST_LogicalEntity_Product{
        public List<ProductCatalogEntry__c> productCatalogLines {get;set;}
        public List<Product2> products {get;set;}
        public List<ProductCatalog__c> productCatalogs {get;set;}
        public List<Hybrid__c> hybrids {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime pagetimestamp {get;set;}               
        public DateTime maxtimestamp {get;set;}
        public Boolean queryMore {get;set;}
        public Integer mode {get;set;} //1 owner, 2 shared, 3 others
        public Integer lastItem {get;set;}      
        public String lastId {get;set;}
                      
        
        public void calculateTimestamp(Datetime reqMaxTimestamp){
           
            maxtimestamp=reqMaxTimestamp;
             
            for(ProductCatalogEntry__c pce : productCatalogLines){
                if(maxtimestamp == null || maxtimestamp < pce.LastModifiedDate)maxtimestamp = pce.LastModifiedDate;   
                for(Stock__c s : pce.Stocks__r)
                {
                    if(maxtimestamp == null || maxtimestamp < s.LastModifiedDate)maxtimestamp = s.LastModifiedDate;               
                }                   
            }
            
            for(Product2 p : products){
                if(maxtimestamp == null || maxtimestamp < p.LastModifiedDate)maxtimestamp = p.LastModifiedDate;
                for(Budget__c b : p.Budgets__r)
                {
                    if(maxtimestamp == null || maxtimestamp < b.LastModifiedDate)maxtimestamp = b.LastModifiedDate;               
                }  
            }
            
            for(ProductCatalog__c pc : productCatalogs){
                if(maxtimestamp == null || maxtimestamp < pc.LastModifiedDate)maxtimestamp = pc.LastModifiedDate;
            }    

            for(Hybrid__c hy : hybrids){
                if(maxtimestamp == null || maxtimestamp < hy.LastModifiedDate)maxtimestamp = hy.LastModifiedDate;
            }    
           
            if(productCatalogLines.size()<queryLimit)
            {
                timestamp=maxtimestamp;
                queryMore=false;
                pagetimestamp=maxtimestamp;
                mode=0;
                lastItem=0;
                LastId='';              
            }
            else
            {
                queryMore=true;
                mode=1;
                lastId=(String)productCatalogLines.get(queryLimit-1).ID;          
            }
           timestamp=pagetimestamp;                            
        }
    }
       
   
}