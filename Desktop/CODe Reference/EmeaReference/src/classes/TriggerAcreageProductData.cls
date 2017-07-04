/**
*	Trigger handler updates Acreages (Product realted) with information from Product
*/
public class TriggerAcreageProductData implements Triggers.Handler
{
	public void handle()
	{
		Set<Id> aProductsSet = new Set<Id>();
		List<Acreage__c> anAcrList = new List<Acreage__c>();
		//Get all the products from acreages.
		for (Acreage__c anAcreage : (List<Acreage__c>)Trigger.new)
		{
			if (anAcreage.RecordTypeId == Util.recordType.get('Acreage__c:AcreagesPerProduct') &&
					  anAcreage.AcrProductRef__c != null)
			{
				aProductsSet.add(anAcreage.AcrProductRef__c);
				anAcrList.add(anAcreage);
			}
		}
		
		Map<Id, Product2> aProductMap = new Map<Id, Product2> ([SELECT Name, ProductGroupRef__c, ProductTypeRef__c,
				  ProductVendor__c FROM Product2 WHERE Id IN :aProductsSet]);
		
		//Update Product grtoup, type, provider for all acreages.
		for (Acreage__c anAcreage: anAcrList)
		{
			Product2 aProduct = aProductMap.get(anAcreage.AcrProductRef__c);
			if (aProduct != null)
			{
				anAcreage.AcrProductGroupRef__c = aProduct.ProductGroupRef__c;
				anAcreage.AcrProductTypeRef__c = aProduct.ProductTypeRef__c;
				anAcreage.AcrProviderRef__c = aProduct.ProductVendor__c;
			}
		}
	}
}