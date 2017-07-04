@RestResource(urlMapping='/getLogicalEntity/ProductEast_2/*')
global with sharing class REST_LogicalEntityProductEast{

    @HttpPost
    global static REST_LogicalEntity_Product getProducts(REST_Request paramInfo)
    {
       
        REST_Request pRequest = paramInfo;
        
        REST_LogicalEntity_Product returned = new REST_LogicalEntity_Product();
        returned.pagetimestamp=pRequest.pagetimestamp;        
        returned.lastItem=pRequest.lastItem;
        returned.mode=pRequest.mode;       
        returned.lastId='';
        

        Set<ID> productIDs = new Set<ID>();
        Set<ID> productIDsNoTs = new Set<ID>();        
        Set<ID> productCatalogIDs = new Set<ID>();
        returned.productCatalogLines=new List<ProductCatalogEntry__c>();
        
     	pRequest.pagetimestamp=UtilREST.resetTimestamp(pRequest.pagetimestamp); 

        
        for(ProductCatalogEntry__c pce: [
            SELECT 
                Name,
                isActive__c,
                isUsed__c,
                isEarlyOrderProduct__c,
                productRef__c,
                productCatalogRef__c,
                Price__c,
                LastModifiedDate,
                VoucherProduct__c,
                Left__c,
                In_use__c,
                allocation__c,
                isFOCallowed__c              
                FROM ProductCatalogEntry__c
                WHERE 
                ProductRef__c!=null AND
                ProductCatalogRef__c!=null AND
		ProductRef__r.DivisionRef__c!=null AND
                ProductCatalogRef__r.CountryRef__c!=null AND   
                (ProductCatalogRef__c in:UtilREST.activeSalesCatalogs OR ProductCatalogRef__c in:UtilREST.activeTrialCatalogs)

              ])
              {
         		   productIDs.add(pce.ProductRef__c);
         		   if(pce.lastModifiedDate > pRequest.pagetimestamp)
         		   {
         		   	 returned.productCatalogLines.add(pce);         		   	 
         		   }	 
              }
                
                    
        
        for(ProductCatalogEntry__c pce : returned.productCatalogLines)
        {
            productCatalogIDs.add(pce.ProductCatalogRef__c);
            productIDsNoTs.add(pce.ProductRef__c);
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
                IsYgard__c,
                ProductMaturity__c,
                ProductHybridGroup__c
            FROM
                Product2
            WHERE               
                (lastModifiedDate > :pRequest.pagetimestamp AND ID in :productIDs)
                OR ID in: productIDsNoTs ];
        
    
                
        returned.productCatalogs = [
            SELECT
                Name,
                RecordTypeId,
                CountryID__c,
                CountryRef__c,
                YearRef__c,
                DivisionRef__c,
                LastModifiedDate
            FROM
                ProductCatalog__c
            WHERE
                (ID in :UtilREST.activeSalesCatalogs OR ID in :UtilREST.activeTrialCatalogs)
                AND  lastModifiedDate > :pRequest.pagetimestamp ];   
        
		returned.calculateTimestamp(pRequest.maxtimestamp);  
        	
        return returned;
    }
    
    global class REST_LogicalEntity_Product{
        public List<ProductCatalogEntry__c> productCatalogLines {get;set;}
        public List<Product2> products {get;set;}
        public List<ProductCatalog__c> productCatalogs {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime maxtimestamp {get;set;}     
        public DateTime pagetimestamp {get;set;}
        public Boolean queryMore {get;set;}        
        public Integer mode {get;set;}         
        public Integer lastItem {get;set;}  
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
        	maxtimestamp=reqMaxTimestamp;         
            
            for(ProductCatalogEntry__c pce : productCatalogLines){
                if(maxtimestamp == null || maxtimestamp < pce.LastModifiedDate)maxtimestamp = pce.LastModifiedDate;
            }
            
            for(Product2 pdt : products){
                if(maxtimestamp == null || maxtimestamp < pdt.LastModifiedDate)maxtimestamp = pdt.LastModifiedDate;
            }
            
            for(ProductCatalog__c pc : productCatalogs){
                if(maxtimestamp == null || maxtimestamp < pc.LastModifiedDate)maxtimestamp = pc.LastModifiedDate;
            }
            
            timestamp=maxtimestamp;
			queryMore=false;
			pagetimestamp=maxtimestamp;
	        mode=0;
	        lastItem=0;
	        LastId='';
        }
        
    }
    
}