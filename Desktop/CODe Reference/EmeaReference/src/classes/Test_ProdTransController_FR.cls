////// ProdTransController
@isTest
public with sharing class Test_ProdTransController_FR 
{
	private static List<Country__c> countries= new List<Country__c>();
	private static List<Product_Grouping__c> productgroupings= new List<Product_Grouping__c>();
	private static List<ProductTranslation__c> producttranslations= new List<ProductTranslation__c>();
	
	private static void init(){
		
		
		Map<String, Object> countryVall = new Map<String, Object> {'Name' => 'Country1', 'ProductTranslation__c' => true};
		Map<String, Object> countryVal2 = new Map<String, Object> {'Name' => 'Country2', 'ProductTranslation__c' => false};
		countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVall ) );
		countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal2 ) );
		insert countries;
		
		
		Map<String, Object> productgroupingVall = new Map<String, Object> {'Name' => 'ProductGrouping1'};
		Map<String, Object> productgroupingVal2 = new Map<String, Object> {'Name' => 'ProductGrouping2'};
		productgroupings.add( ( Product_Grouping__c ) SmartFactory.createSObject( 'Product_Grouping__c', productgroupingVall ) );
		productgroupings.add( ( Product_Grouping__c ) SmartFactory.createSObject( 'Product_Grouping__c', productgroupingVal2 ) );
		insert productgroupings;
		
		
		Map<String, Object> producttranslationVal1 = new Map<String, Object> {'ProductGroupingRef__C' => productgroupings[0].Id, 'CountryRef__C' => countries[0].Id, 'Translation__C' => 'texto1'};
		Map<String, Object> producttranslationVal2 = new Map<String, Object> {'ProductGroupingRef__C' => productgroupings[1].Id, 'CountryRef__C' => countries[1].Id, 'Translation__C' => 'texto2'};
		producttranslations.add(( ProductTranslation__c ) SmartFactory.createSObject( 'ProductTranslation__c', producttranslationVal1 )) ;
		producttranslations.add(( ProductTranslation__c ) SmartFactory.createSObject( 'ProductTranslation__c', producttranslationVal2 )) ;
		insert producttranslations;
				
	}
	
	private static testMethod void ProductTranslation()
{
		
		
		init();
		
		
		Test.startTest();
		User user = Util.currentUser;
		user.Country = countries[0].Name;
		update(user);
		System.runAs(user){		
			System.debug('ID DEL USER: '+UserInfo.getUserId());
			String result= ProdTransController.getTranslation(productgroupings[0].Id);
			System.assertEquals('texto1', result);
			boolean istrans=ProdTransController.isTranslatable();
			System.assertEquals(true,istrans);
		}
		Test.stopTest();
		
		
		
			
}

private static testMethod void ProductTranslation2()
{
		init();
		
		
		Test.startTest();
		User user = Util.currentUser;
		user.Country = countries[1].Name;
		update(user);
		System.runAs(user){		
			System.debug('ID DEL USER: '+UserInfo.getUserId());
			String result= ProdTransController.getTranslation(productgroupings[0].Id);
			System.assertEquals('ProductGrouping1', result);
			boolean istrans=ProdTransController.isTranslatable();
			System.assertEquals(false,istrans);	
		} 
		Test.stopTest();
		
}
	private static testMethod void ProductTranslation3()
{
		init();
	
		
		List<Id> listaIds = new List<Id> ();
		listaIds.add(productgroupings[0].Id);
		listaIds.add(productgroupings[1].Id);
		
		Test.startTest();
		User user = Util.currentUser;
		user.Country = countries[1].Name;
		update(user);
		System.runAs(user){		
			System.debug('ID DEL USER: '+UserInfo.getUserId());
			Map<id, string> result= ProdTransController.getTranslation(listaIds);
			System.assertEquals(2, result.size());
			System.assertEquals(result.get(listaIds[0]),'ProductGrouping1');
			System.assertEquals(result.get(listaIds[1]),'ProductGrouping2');
		} 
		Test.stopTest();	
	
}
}