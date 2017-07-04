/**
* Contains some useful features to control Acreages
*/
public class AcreagesManager
{
	/**
	* Create Acreages for account in accordance to current tactical plan.
	*/
	public static List<Acreage__c> createAcreagesByTacticalPlans(Id theAccountId)
	{
		TacticalPlanFactory aFactory = new TacticalPlanFactory();
		//Get products from current acreages.
		List<CampaignLineItem> aList = (List<CampaignLineItem>) aFactory.createObjectWrapperForAccountId(theAccountId);
		Set<Id> aCurrentList = getAcreageProductsCurrentYear(theAccountId);
		
		//Filter prodcuts (we should have only one acreage per product).
		Map<Id, CampaignLineItem__c> aProducts = new Map<Id, CampaignLineItem__c>();
		for (CampaignLineItem aCLI: aList)
		{
			if (aCLI.record.ProductRef__c != null && !aCurrentList.contains(aCLI.record.ProductRef__c))
			{
				aProducts.put(aCLI.record.ProductRef__c, aCLI.record);
			}
		}
		System.debug('*** Current Products: ' + aCurrentList);
		System.debug('*** New Products: ' + aProducts);
		//Create acreages for the filetered list of products.
		List<Acreage__c> aResult = generateAcreagesForProducts(theAccountId, aProducts.values());
		insert aResult;
		return aResult;
	}
	
	/**
	* Get all products relates to current acreages for account.
	*/
	public static Set<Id> getAcreageProductsCurrentYear(Id theAccountId)
	{
		al.AndCondition aCondition = new al.AndCondition();
		aCondition.add(new al.FieldCondition('RecordTypeId', Util.recordType.get('Acreage__c:AcreagesPerProduct')));
		aCondition.add(new al.FieldCondition('AcrFarmRef__c', theAccountId));
		aCondition.add(new al.FieldCondition('AcrYearRef__c', Util.currentYear.Id));
		List<Acreage__c> aResList = (List<Acreage__c>) Database.query(new al.SoqlBuilder().selectx('AcrProductRef__c')
				  .fromx('Acreage__c').wherex(aCondition).toSoql());
		Set<Id> aResult = new Set<Id>();
		for (Acreage__c anObj: aResList)
		{
			if (anObj.AcrProductRef__c != null)
			{
				aResult.add(anObj.AcrProductRef__c);
			}
		}
		return aResult;
	}
	
	/**
	* Generate acreages for filetered list of tactical plans.
	*/
	private static List<Acreage__c> generateAcreagesForProducts(Id theAccountId, List<CampaignLineItem__c> theCLIs)
	{
		al.AndCondition aCondition = new al.AndCondition();
		aCondition.add(new al.FieldCondition('AcrFarmRef__c', theAccountId));
		aCondition.add(new al.FieldCondition('AcrYearRef__c', Util.lastYear.Id));
		List<Acreage__c> aPrevYearAcreages = (List<Acreage__c>) Database.query(new al.SoqlBuilder().selectx(new List<String>{'Id', 'AcrProductRef__c'})
				  .fromx('Acreage__c').wherex(aCondition).toSoql());
		Map<Id, Id> aProductsMap = new Map<Id, Id>();
		for (Acreage__c anAcr: aPrevYearAcreages)
		{
			aProductsMap.put(anAcr.AcrProductRef__c, anAcr.Id);
		}
		List<Acreage__c> aResList = new List<Acreage__c>();
		for (CampaignLineItem__c aCLI: theCLIs)
		{
			Acreage__c anAcr = new Acreage__c();
			anAcr.RecordTypeId = Util.recordType.get('Acreage__c:' + AcreageFactory.ACREAGE_RT_PRODUCT);
			anAcr.AcrFarmRef__c = theAccountId;
			anAcr.AcrProductRef__c = aCLI.ProductRef__c;
			anAcr.AcrYearRef__c = Util.currentYear.Id;
			Decimal aDensity = 0;
			try
			{
				aDensity = Decimal.valueOf(aCLI.PlantingDensity__c);
			} catch (Exception theException)
			{
				System.debug('***Got exception: ' + theException.getMessage());
			}
			System.debug('*** Quantity' + aDensity + ' - ' + aCLI.Quantity__c);
			anAcr.AcrTotalAcreages__c = aDensity * aCLI.Quantity__c;
			Id aPrevAcr = aProductsMap.get(aCLI.ProductRef__c);
			if (aPrevAcr != null)
			{
				anAcr.PreviousAcreageRef__c = aPrevAcr;
			}
			aResList.add(anAcr);
		}
		System.debug('*** New Acreages: ' + aResList);
		return aResList;
	}
}