/*
	@description Controller for ProductCatalogPicker page.
	@copyright PARX
*/
public with sharing class ProductCatalogPickerController
{
	public static final Map<String, String> PRODUCT_CATALOG_PRODUCT_RECORD_TYPES = new Map<String, String> {
			  'CompetitorProductCatalog' => 'CompetitorProduct', 'MarketingProductCatalog' => 'MarketingProduct'};
	
	public static Set<String> STANDARD_FIELDS = new Set<String> {'Id', 'Name', 'ProductTreatment__c',
			  'ProductBagSize__c', 'ProductKernelSize__c', 'Description'};
	
	private ProductCatalog__c catalog;
	
	private String fieldSetName;
	
	public List<Product2x> resultProducts {get; set;}
	public List<CatalogEntryAdapter> currentProducts{get; set;}
	public Product2 searchProduct{get;set;}
	
	public FieldSetMemberxManager searchFieldSet
	{
		get
		{
			
			if(searchFieldSet == null)
			{
				searchFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, '', fieldSetName, 'ProdMgmtSearch');
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
					resultFieldSet = new FieldSetMemberxManager(Schema.SObjectType.Product2, '', fieldSetName, 'ProdMgmtRes');
			}
			return resultFieldSet;
		}
		set;
	}
	
	/*
		@description Constructor with standard controller.
	*/
	public ProductCatalogPickerController(ApexPages.StandardController theController)
	{
		Id aCatalogId = theController.getRecord().Id;
		catalog = [SELECT Id, RecordType.DeveloperName, DivisionRef__c, DivisionRef__r.name FROM ProductCatalog__c WHERE Id = :aCatalogId LIMIT 1];
		fieldSetName = catalog.RecordType.DeveloperName;
		if(catalog.DivisionRef__c <> null && !fieldSetName.contains('Competitor') && !fieldSetName.contains('Marketing'))
		{
			if (((catalog.DivisionRef__r.name).replaceAll('(\\s+)', '')).length()>10) fieldSetName += ((catalog.DivisionRef__r.name).replaceAll('(\\s+)', '')).substring(0,10);
			else fieldSetName += (catalog.DivisionRef__r.name).replaceAll('(\\s+)', '');
		}
		searchProduct = new Product2();
		initCurrentProducts();
		doFilter();
	}
	
	/*
		@description Wrapper class CatalogEntryAdapter
	*/
	public class CatalogEntryAdapter
	{
		public ProductCatalogEntry__c record {get;set;}
		public boolean checked {get;set;}
		public boolean isDisabled {get; set;}
		
		public CatalogEntryAdapter(ProductCatalogEntry__c theRecord)
		{
			record = theRecord;
			this.isDisabled = record.isUsed__c;
		}
	} 
	
	/*
		@description Check created ProductCatalogEntry records and fill wrapper records
	*/
	private void initCurrentProducts()
	{
		currentProducts = new List<CatalogEntryAdapter>();
		List<String> aFieldsToSelect = new List<String>();
		aFieldsToSelect.add('Id');
		aFieldsToSelect.add('ProductRef__c');
		aFieldsToSelect.add('IsUsed__c');
		for (String aField: STANDARD_FIELDS)
		{
			aFieldsToSelect.add('ProductRef__r.' + aField);
		}
		for(String s : resultFieldSet.getSOQLFields())
		{
			aFieldsToSelect.add('ProductRef__r.'+s);
		}
		
		al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(aFieldsToSelect).fromx('ProductCatalogEntry__c')
				  .wherex(new al.FieldCondition('ProductCatalogRef__c', catalog.Id)).limitx(300);
		for (ProductCatalogEntry__c aProduct : Database.query(aBuilder.toSOQL()))
		{
			if (aProduct.ProductRef__c != null)
			{
				currentProducts.add(new CatalogEntryAdapter(aProduct));
			}
		}
		
		
		
	}
	
	/*
		@description Delete ProductCatalogEntry records which has been checked.
	*/
	public PageReference doDeleteProducts()
	{
		List<ProductCatalogEntry__c> aDeleteList = new List<ProductCatalogEntry__c>();
		for (CatalogEntryAdapter aProd: currentProducts)
		{
			if (aProd != null && aProd.checked!= null && aProd.checked && aProd.record != null)
			{
				aDeleteList.add(aProd.record);
			}
		}
		if(!aDeleteList.isEmpty())
		{
			delete aDeleteList;
		}
		
		initCurrentProducts();
		return doFilter();
	}
	
	/*
		@description Add and insert ProductCatalogEntry records by checked Products records.
	*/
	public PageReference doAddProducts()
	{
		List<ProductCatalogEntry__c> aResult = new List<ProductCatalogEntry__c>();
		for (Product2x aProduct: resultProducts)
		{
			if (aProduct.checked)
			{
				ProductCatalogEntry__c anEntry = new ProductCatalogEntry__c();
				anEntry.ProductCatalogRef__c = catalog.Id;
				anEntry.ProductRef__c = aProduct.Id;
				anEntry.isActive__c = true;
				aResult.add(anEntry);
			}
		}
		insert aResult;
		initCurrentProducts();
		return doFilter();
	}
	
	/*
		@description Add filter by Product Id into SOQL request.
	*/
	public PageReference doFilter()
	{
		resultProducts = new List<Product2x>();
		al.AndCondition aFiltersCondition = Product2xHelper.getAndConditionForProduct('', searchProduct);
		
		Set<String>selectedFields = new Set<String>();
		selectedFields.addAll(STANDARD_FIELDS);
		selectedFields.addAll( resultFieldSet.getSOQLFields());
		
		String aProductRT = PRODUCT_CATALOG_PRODUCT_RECORD_TYPES.get(catalog.RecordType.DeveloperName);
		if (aProductRT == null)
		{
			aFiltersCondition.add(new al.FieldCondition('DivisionRef__c', catalog.DivisionRef__c));
		} else
		{
			aFiltersCondition.add(new al.FieldCondition('RecordType.DeveloperName', aProductRT));
		}
		al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(selectedFields).fromx('Product2').wherex(aFiltersCondition);
		
		
		String aQuery = aBuilder.toSOQL();
		aQuery += ' AND Id NOT IN (' + new al.SoqlBuilder().selectx(new List<String>{'ProductRef__c'}).fromx('ProductCatalogEntry__c')
				  .wherex(new al.FieldCondition('ProductCatalogRef__c', catalog.Id)).toSoql() + ') ORDER BY Name LIMIT 300';
				  
		//Util.addConfirmMessage(aQuery);
		for (Product2 aProduct : Database.query(aQuery))
		{
			resultProducts.add(new Product2x(aProduct));
		}
		return null;
	}
	
	/*
		@description Redirect to ProductCatalog record/
	*/
	public PageReference doCancel()
	{
		return new PageReference('/' + catalog.Id);
	}
}