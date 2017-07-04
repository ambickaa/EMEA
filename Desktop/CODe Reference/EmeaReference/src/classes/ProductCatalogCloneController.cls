public class ProductCatalogCloneController {
	
	private ProductCatalog__c currentProductCatalog;
	private ProductCatalog__c newProductCatalog;
	private List<ProductCatalogEntry__c> newProductCatalogEntries = new List<ProductCatalogEntry__c>();
    public ProductCatalogCloneController(ApexPages.StandardController controller) {
		
		for(ProductCatalog__c p : [Select p.YearRef__c, p.RecordTypeId, p.Name, p.Id, p.DivisionRef__c, p.CountryRef__c, p.CountryID__c From ProductCatalog__c p WHERE ID = :controller.getId()])
		{
			currentProductCatalog = p;
		}
    }
    
    public PageReference redirect()
    {
    	newProductCatalog = currentProductCatalog.clone();
    	
    	insert newProductCatalog;
    	for(ProductCatalogEntry__c p : [SELECT ID, isActive__c, ProductRef__c, Price__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c = :currentProductCatalog.id])
    	{
    		ProductCatalogEntry__c tempCatalogEntry = p.clone();
    		tempCatalogEntry.ProductCatalogRef__c = newProductCatalog.id;
    		newProductCatalogEntries.add(tempCatalogEntry);
    	}
    	
    	if(newProductCatalogEntries.size()>0)
    	{
    		insert newProductCatalogEntries;
    	}
    	return new PageReference('/'+newProductCatalog.id);
    }
    
    

}