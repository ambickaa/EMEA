public with sharing class ProductCatalogAddLineItemsController extends ProductVirtualGenericSearch{
    
    
     
    public List<ProductCatalogEntry__c>productsInCatalog {get; set;}
    private List<Id>productSetInCatalog = new List<Id>();
    
    public ProductCatalogAddLineItemsController()
    {
        // get products in catalog
        productsInCatalog = [SELECT Id, Name, ProductRef__c, ProductRef__r.Name,  IsActive__c, ProductRef__r.ProductTreatment__c, ProductRef__r.ProductBagSize__c, ProductRef__r.ProductKernelSize__c, ProductRef__r.Description FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c = :Util.urlParameters.get('id')];
        
        for(ProductCatalogEntry__c p : productsInCatalog)
        {
            
                productSetInCatalog.add(p.ProductRef__c);
            
            
        }
        filter();
    }
    
    
    
    public PageReference filter()
    {
        results = new List<Product2x>();
        al.SoqlBuilder query = new al.SoqlBuilder();
        query.selectx(new List<Object> {'Id', 'name', 'ProductTreatment__c', 'ProductBagSize__c', 'ProductKernelSize__c', 'Description'})
        .fromx('Product2');

        // add search fields from Product
        al.AndCondition andConditions = Product2xHelper.getAndConditionForProduct('', searchProduct);
        
        if(Util.urlParameters.containsKey('division'))
        {
            andConditions.add(new al.FieldCondition('DivisionRef__c' ).equals( Util.urlParameters.get('division') ));
        }
        if(productSetInCatalog.size()>0)
        {
            andConditions.add(
                new al.SetCondition('id').notin(productSetInCatalog)
            );
        }
        
        
        query.wherex(andConditions);
        
        query.limitx(200);
        
        //Util.addInfoMessage('Query:'+query.toSOQL());
        
        for(Product2 p : Database.query(query.toSOQL()))
        {
            results.add(new Product2x(p));
        }
        
        
        return null;
    }
    
    
    public PageReference saveExistringRecords()
    {
        if(productsInCatalog.size()>0)
        {
            update productsInCatalog;
        }
        return null;
    }
    
    public PageReference saveNewRecords()
    {
        List<ProductCatalogEntry__c> newProducts = new List<ProductCatalogEntry__c>();
        
        for(Product2x p : results)
        {
            if(p.checked)
            {
                newProducts.add(new ProductCatalogEntry__c(ProductRef__c = p.record.id, isActive__c = true, ProductCatalogRef__c = Util.urlParameters.get('id')));
            }
        }
        if(newProducts.size()>0)
        {
            insert newProducts;
        }
        return null;
    }
    
    
    public PageReference backToProductCatalog()
    {
        return new PageReference('/'+Util.urlParameters.get('id'));
    }
    
    
    
    
    
}