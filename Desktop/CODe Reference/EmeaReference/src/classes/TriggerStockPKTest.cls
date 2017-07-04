@isTest

private class TriggerStockPKTest {


	static testMethod void mainTest(){
	
		Test.startTest();
		
		Country__c c = new Country__c(Name ='South Africa', TacticalPlanSetting__c = 'Standard');
		insert c;
		
		Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
        insert Divi;
		
		Product2 pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id, Description='PRODUCTO');
		insert pr1;
		
		ProductCatalog__c procat = new ProductCatalog__c(name = 'Catalog ii',countryRef__c=c.id);
		insert procat;
		
		ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=procat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
        insert pce;
		String idPrCatEn = (String)pce.id;
		String idUser = (String)Util.CurrentUser.id;
		
		Stock__c stk1 = new Stock__c(HybridRef__c=null, ProductCatalogEntryRef_RSA__c=pce.id, User_RSA__c=Util.CurrentUser.id, Allocation_RSA__c=123987);
		
		insert stk1;
		
		Stock__c stkTest1 = [SELECT Id, PK__c FROM Stock__c WHERE Allocation_RSA__c=123987];
		
		
		String PKStr = idUser+'-'+idPrCatEn;
		
		system.assertEquals(stkTest1.PK__c, PKStr);
		
		
	
	Test.stopTest();
		
	
	}





}