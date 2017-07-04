/**
* Run updates for all acreages, related to selected products.
*/
public class TriggerProduct2UpdateAcreages implements Triggers.Handler
{
	private static final List<String> PRODUCT_FIELDS_TO_CHECK = new List<String> {'ProductGroupRef__c',
			  'ProductTypeRef__c', 'ProductVendor__c'};
	
	public void handle()
	{
		//Get all Products with modified data
		Set<Id> aProducts = new Set<Id>();
		for (Product2 aProduct: (List<Product2>)Trigger.new)
		{
			Boolean anUpdate = false;
			for (String aField: PRODUCT_FIELDS_TO_CHECK)
			{
				anUpdate |= aProduct.get(aField) != Trigger.oldMap.get(aProduct.Id).get(aField);
			}
			if (anUpdate)
			{
				aProducts.add(aProduct.Id);
			}
		}
		
		//Get and update all the related acreages.
		if (aProducts.size() > 0)
		{
			List<Acreage__c> anAcreages = [SELECT Id FROM Acreage__c WHERE AcrProductRef__c IN :aProducts
					  ORDER BY LastModifiedDate DESC LIMIT 10000];
			update anAcreages;
		}
	}
}