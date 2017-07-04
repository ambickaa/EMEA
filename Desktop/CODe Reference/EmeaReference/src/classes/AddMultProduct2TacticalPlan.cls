public class AddMultProduct2TacticalPlan extends ProductVirtualGenericSearch
{
	public List<ProductCatalogEntry__c>productsInCatalog {get; set;}
	private List<Id>productSetInCatalog = new List<Id>();
	
	public String mode
	{
		get
		{
			mode = Util.urlParameters.get('mode');
				if(mode == 'tacticalEdit')
				{
					mode = 'Sales';
				}
			return mode;
		}
		set;
	}
	
	
	// fields for the search section
	public FieldSetMemberxManager searchFieldSet
	{
		get
		{
			if(searchFieldSet == null)
			{
				Util.addConfirmMessage('*****'+ Util.currentDivision.name);
				
				
				
				if(mode == 'Sales')
				{
					Util.addConfirmMessage(Util.currentDivision.name);
					try
					{
					searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, mode,'SearchLookup'+ Util.currentDivision.name, '');
					}
					catch(Exception e)
					{
						searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, mode,'SearchLookup', Util.currentDivision.name);
					}
				}
				else
				{
					try
					{
					searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, mode,'SearchLookup'+ Util.currentDivision.name, '');
					}catch(Exception e)
					{
						searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, mode,'SearchLookup', Util.currentDivision.name);
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
				if(mode == 'Sales')
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
	
	
	
	
	
	
	public AddMultProduct2TacticalPlan()
	{
		// get products in catalog
		al.SoqlBuilder query = new al.SoqlBuilder();
		query.selectx(new List<Object> {'ProductRef__r.Id', 'ProductRef__r.name', 'ProductRef__r.ProductTreatment__c', 
										'ProductRef__r.ProductBagSize__c', 'ProductRef__r.ProductKernelSize__c', 
										'ProductRef__r.Description'})
		.fromx('ProductCatalogEntry__c');

		// add search fields from Product
		al.AndCondition andConditions = Product2xHelper.getAndConditionForProduct('ProductRef__r.', searchProduct);
		
		andConditions.add
		(
			new al.FieldCondition('ProductCatalogRef__c').equals( Util.currentCampaign.SalesPCMRef__c )
		);
		
		filter();
	}
	
	public PageReference filter()
	{
		results = new List<Product2x>();
		al.SoqlBuilder query = new al.SoqlBuilder();
		query.selectx(new List<Object> {'Id', 'name', 'ProductTreatment__c', 'ProductBagSize__c', 'ProductKernelSize__c', 
										'Description'})
		.fromx('Product2');

		// add search fields from Product
		al.AndCondition andConditions = Product2xHelper.getAndConditionForProduct('', searchProduct);
		
		if (Util.urlParameters.containsKey('division'))
		{
			andConditions.add(new al.FieldCondition('DivisionRef__c' ).equals( Util.urlParameters.get('division') ));
		}
		
		query.wherex(andConditions);
		
		query.limitx(200);
		
		//Util.addInfoMessage('Query:'+query.toSOQL());
		
		for (Product2 p : Database.query(query.toSOQL()))
		{
			results.add(new Product2x(p));
		}
		
		return null;
	}
	
	public PageReference saveExistringRecords()
	{
		if (productsInCatalog.size()>0)
		{
			update productsInCatalog;
		}
		return null;
	}
	
	public PageReference saveNewRecords()
	{
		List<CampaignLineItem__c> newProducts = new List<CampaignLineItem__c>();
		
		for (Product2x p : results)
		{
			if(p.checked)
			{
				newProducts.add(new CampaignLineItem__c(CampaignRef__c = Util.currentCampaign.id, 
					  FarmRef__c = Util.currentAccount.id, ProductRef__c = p.Id, Type__c = 'Charged', 
					  Forecast__c = 0, Status__c = 'Forecast'));
			}
		}
		
		if (newProducts.size()>0)
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