/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_WS_Product {

    static testMethod void myUnitTest() {
		TestInit.setYear(1);
		List<Country__c> countries = new List<Country__c>();
		Map<String, Object> countryVal3 = new Map<String, Object> {'Name' => 'France', 'TacticalPlanSetting__c' => 'france'};
		Map<String, Object> countryVal4 = new Map<String, Object> {'Name' => 'United Kingdom', 'TacticalPlanSetting__c' => 'UK'};
		countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal3 ) );
		countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal4 ) );
		insert countries;
		System.assert(countries[0].Id != null);
		System.assert(countries[1].Id != null);
		Division__c aDivision = TestInit.getDivision(Util.DIVISION_OSR);
		System.debug('TEST DEBUG aDivision : '+aDivision);
		Account aFarmAccount = TestInit.createNewFarmer();
		aFarmAccount.CountryRef__c = countries[0].Id;
		aFarmAccount.CountryID__c = countries[0].Id;
		insert aFarmAccount;
		System.assert(aFarmAccount.Id != null);

		Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
	    {
	      'CountryRef__c' => aFarmAccount.CountryRef__c,
	      'OwnerId' => aFarmAccount.OwnerId,
	      'DivisionRef__c' => aDivision.Id,
	      'StartDate' => Date.today(),
	      'EndDate' => Date.today(),
	      'ArchiveDate__c' => Date.today().addDays(30),
	      'YearV2__c' => Util.lastYear.Id
	    };
		Campaign aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
    	insert aPreviousCampaign;
    	System.assert(aPreviousCampaign.Id != null);

    	Product2 product = TestInit.products[0];
    	insert product;
    	ProductCatalog__c prodCat = TestInit.productCatalogs.get('ProductCatalog__c:SalesProductCatalog');
    	prodCat.YearRef__c = Util.currentYear.Id;
    	prodCat.DivisionRef__c = aDivision.Id;
    	prodCat.CountryID__c = countries[0].Id;
    	prodCat.CountryRef__c = aFarmAccount.CountryRef__c;
    	prodCat.OwnerId = aFarmAccount.OwnerId;
    	update prodCat;
    	System.debug('TEST DEBUG prodCat : '+prodCat);

    	Map<String, Object> aCurrCampaignParam = new Map<String, Object>
	    {
	      'CountryRef__c' => aFarmAccount.CountryRef__c,
	      'OwnerId' => aFarmAccount.OwnerId,
	      'DivisionRef__c' => aDivision.Id,
	      'StartDate' => Date.today(),
	      'EndDate' => Date.today().addDays(10),
	      'ArchiveDate__c' => Date.today().addDays(30),
	      'YearV2__c' => Util.currentYear.Id,
	      'SalesPCMRef__c' => prodCat.Id
	    };
		Campaign aCurrCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrCampaignParam);
    	insert aCurrCampaign;
    	System.assert(aCurrCampaign.Id != null);
    	
    	Product2 product2 = TestInit.products[1];
    	Product2 product3 = TestInit.products[2];
    	Product2 product4 = TestInit.products[3];
    	
		Map<String, Object> aProductCatalogEntryParam = new Map<String, Object>
			{
				'ProductRef__c' => product.Id,
				'ProductCatalogRef__c' => prodCat.Id
			};
		
		ProductCatalogEntry__c prodCatEntry = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aProductCatalogEntryParam);
		insert prodCatEntry;
		System.assert(prodCatEntry.Id != null);
		Util.currentCampaign = aCurrCampaign;
		Util.previewsCampaign = aPreviousCampaign;
		Test.startTest();
		String result = WS_Product.getProductInjectFields(product.Id, aFarmAccount.Id, aDivision.Id);
		System.assert(result != null);
		Test.stopTest();
		
    }

}