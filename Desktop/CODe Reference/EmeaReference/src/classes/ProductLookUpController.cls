public class ProductLookUpController extends ProductVirtualGenericSearch
{
    String accountId;
    Boolean isConsigned=false;
    Boolean isRequested=false;
    // constructor
    public ProductLookUpController()
    {
        accountId = Util.urlParameters.get('accountId');
        Util.setCurrentAccount(accountId);
        if(ApexPages.currentPage().getParameters().get('consignment')!=null && ApexPages.currentPage().getParameters().get('consignment').equals('true'))
        	isConsigned=true;  
        if(ApexPages.currentPage().getParameters().get('consignment')!=null && ApexPages.currentPage().getParameters().get('consignment').equals('request'))
        	isRequested=true;          	  
        filter();
    }

    // shows message if needed
    public boolean getIsMessage()
    {
        return false;
    }
    // fields for the search section
    public FieldSetMemberxManager searchFieldSet
    {
        get
        {
            if(searchFieldSet == null)
            {
                if(Util.currentLookupMode == 'Sales')
                {
                    Util.addConfirmMessage(Util.currentDivision.name);
                    try
                    {
                    searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup'+ Util.currentDivision.name, '');
                    }
                    catch(Exception e)
                    {
                        searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup', Util.currentDivision.name);
                    }
                }
                else
                {
                    try
                    {
                    searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup'+ Util.currentDivision.name, '');
                    }catch(Exception e)
                    {
                        searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchLookup', Util.currentDivision.name);
                    }
                }
            }
            return searchFieldSet;
        }
        set;
    }
    
    public FieldSetMemberxManager resultFieldSet
    {
        get
        {
            if(resultFieldSet == null)
            {
                if(Util.currentLookupMode == 'Sales')
                {
                    try
                    {
                    resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult'+Util.currentDivision.name, '');
                    }
                    catch(Exception e)
                    {
                        resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', Util.currentDivision.name);
                    }
                }
                else
                {
                    resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, Util.currentLookupMode,'SearchResult', '');
                }
            }
            return resultFieldSet;
        }
        set;
    }

    // generates QueryString
    public String getQueryString()
    {
        al.SoqlBuilder query = new al.SoqlBuilder();
        
        Set<Object>selectedFields = new Set<Object> {'ProductRef__c', 'ProductRef__r.Id', 'ProductRef__r.name'};
        
        for(String s : resultFieldSet.getSOQLFields())
        {
            selectedFields.add('ProductRef__r.'+s);
        }
        
        query.selectx(selectedFields)
        .fromx('ProductCatalogEntry__c');

        // add search fields from Product
        al.AndCondition andConditions = Product2xHelper.getAndConditionForProduct('ProductRef__r.', searchProduct);
        if (Util.urlParameters.get('mode') == 'GiveAway')
        {
            andConditions.add
            (
                new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.GiveAwayPCMRef__c )
            );
        }
        else if (Util.urlParameters.get('mode') == 'Trial')
        {
            andConditions.add
            (
                (new al.OrCondition())
                .add(
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.TrialPCMRef__c )
                )
                .add(
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.CompetitorPCMRef__c )
                )
            );
        }
        else if (Util.urlParameters.get('mode') == 'Sales')
        {
            String Catalog = Util.urlParameters.get('Catalog');
            if(Catalog != null && Catalog.equals('Tax'))
            {
                andConditions.add
                (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.TaxSalesPCMRef_RSA__c )
                );
               
  				andConditions.add
                (
                    new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0)    
                );               
                
            }else if(Catalog != null && Catalog.equals('Regular') && !isConsigned && !isRequested)
            {
                andConditions.add
                (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
                );
                
                andConditions.add
                (
                    new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0)    
                );                              
                
            }else if(Catalog != null && Catalog.equals('General'))
            {
                andConditions.add
                (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.TaxSalesPCMRef_RSA__c )
                );
                 /* This sentence is commented because prices will not be applied until April 
  				andConditions.add
                (
                    new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0)    
                );                              
    */            
            }
            else if(Catalog != null && Catalog.equals('Feb Receipt'))
            {
            		
            	andConditions.add
                (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
                );
 				andConditions.add
                (
                    new al.FieldCondition('PriceOld__c', al.Operator.GREATER_THAN,0)    
                );               
            }else if(Catalog != null && Catalog.equals('Regular') && isConsigned )
            {
            
              List<Id> consignedProducts = new List<Id>();
              for(Consignment__c cw : [select ProductCatalogEntryRef__c from Consignment__c 
              									WHERE ProductCatalogId__c=:Util.currentCampaign.SalesPCMRef__c 
              									AND UserRef__c=:Util.currentAccount.OwnerId
              									AND Status__c ='Accepted'])
              {
              	consignedProducts.add(cw.ProductCatalogEntryRef__c);
              }
              
              andConditions.add
              (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
              );	
   			  andConditions.add
              (
                    new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0)    
              );                                           
              andConditions.add
             (
              	new al.SetCondition('id',al.Operator.INX, consignedProducts)
              	
             );
            
            
            }else if(Catalog != null && Catalog.equals('Regular') && isRequested )
            {

              andConditions.add
              (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
              );	
   			  andConditions.add
              (
                    new al.FieldCondition('Price__c', al.Operator.GREATER_THAN,0)    
              );                                           
              andConditions.add
             (
                    new al.FieldCondition('Consigned__c', al.Operator.EQUALS,true)    
              	
             );
            
            
            }else
	  	   {
	     	andConditions.add
                (
                    new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
                );	    
	    }
            
        }
        else if (Util.urlParameters.get('mode') == 'Case' && Util.currentCampaign != null)
        {
            andConditions.add
            (
                new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
            );
        }
        // error handling 
        else if (Util.currentCampaign == null)
        {
            andConditions.add
            (
                new al.FieldCondition('ProductCatalogRef__r.name').equals( '' )
            );
        }
		
        query.wherex( andConditions );

        query.orderByx(new al.OrderBy('ProductRef__r.name').ascending());
        query.Limitx(300);
        
        
        return query.toSOQL();
    }

    // search for Products
    public PageReference filter()
    {
        if (accountId != null)
        {
            Util.setCurrentAccount(accountId);
        }
        
        results = new List<Product2x>();
        
        for (ProductCatalogEntry__c p : Database.query(getQueryString()))
        {
            if (p.ProductRef__c != null)
            {
                results.add(new Product2x(p.ProductRef__r));
            }
        }
        return null;
    }
}