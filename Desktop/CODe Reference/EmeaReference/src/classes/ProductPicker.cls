/*
	@description Virtual class ProductPicker.
	@copyright PARX
*/
public virtual with sharing class ProductPicker
{
	public static Set<String> STANDARD_FIELDS = new Set<String> {'Id', 'Name', 'ProductTreatment__c',
				  'ProductBagSize__c', 'ProductKernelSize__c', 'Description'};
	
	public List<Product2x> selectedObjects {get; set;}
	public List<Product2> selectedProducts
	{
		get
		{
			List<Product2> aResult = new List<Product2>();
			for (Product2x anObj: selectedObjects)
			{
				aResult.add(anObj.record);
			}
			return aResult;
		}
	}
	
	//Products wich selected by filter parameters.
	public List<Product2x> currentResult {get;set;}
	
	//Fields this Product use for filter parameters as apex:inputField
	public Product2 searchProduct {get;set;}
	public al.Condition filters {get;set;}
	
	protected Set<Id> selectedIds = new Set<Id>();
	public List<String> fieldsToSelect {get; set;}
	
	/*
		@description Constructor
	*/
	public ProductPicker()
	{
		searchProduct = new Product2();
		fieldsToSelect = new List<String>();
		selectedIds = new Set<Id>();
		selectedObjects = new List<Product2x>();
		
		fieldsToSelect.add('Id');
		fieldsToSelect.add('ProductRef__c');
		for (String aField: STANDARD_FIELDS)
		{
			fieldsToSelect.add('ProductRef__r.' + aField);
		}
	}
	
	/*
		@description Add Products from filtered Products to selected Products for creating CampaignLiteItem__c records.
	*/
	public PageReference doAddSelected()
	{
		for (Product2x aProduct: currentResult)
		{
			if (aProduct.checked && !selectedIds.contains(aProduct.Id))
			{
				selectedObjects.add(aProduct);
				aProduct.checked = false;
				selectedIds.add(aProduct.Id);
			}
		}
		return doFilter();
	}
	
	/*
		@description Delete selected Products from list for create CampaignlineItem__c records.
	*/
	public PageReference doDeleteSelected()
	{
		List<Product2x> aNewList = new List<Product2x>();
		selectedIds = new Set<Id>();
		for (Product2x aProd: selectedObjects)
		{
			if (!aProd.checked)
			{
				aNewList.add(aProd);
				selectedIds.remove(aProd.Id);
			}
		}
		selectedObjects = aNewList;
		return doFilter();
	}
	
	/*
		@description Add filter by Product Id into SOQL request.
	*/
	public virtual PageReference doFilter()
	{
		currentResult = new List<Product2x>();
		
		al.AndCondition aFiltersCondition = Product2xHelper.getAndConditionForProduct('ProductRef__r.', searchProduct);
		if (filters != null)
		{
			aFiltersCondition.add(filters);
		}
		al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(fieldsToSelect).fromx('ProductCatalogEntry__c')
			  .wherex(aFiltersCondition).orderByx(new al.OrderBy('ProductRef__r.name').ascending()).limitx(300);
		//Util.addConfirmMessage(aBuilder.toSOQL());
		for (ProductCatalogEntry__c aProduct : Database.query(aBuilder.toSOQL()))
		{
			if (aProduct.ProductRef__c != null && !selectedIds.contains(aProduct.ProductRef__c))
			{
				currentResult.add(new Product2x(aProduct.ProductRef__r));
			}
		}
		return null;
	}
	
	/*
		@description virtual method saveResults
	*/
	public virtual void saveResults()
	{
	}
}