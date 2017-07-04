@isTest

private class TriggerStockAssignHybridTest {
	
	static testMethod void mainTest()
	{
		Test.startTest();
		
		Country__c c = new Country__c(Name ='South Africa', TacticalPlanSetting__c = 'Standard');
		insert c;
		
		Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
        insert Divi;
		
		Product2 pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id, Description='PRODUCTO');
		insert pr1;
		Product2 prtest = [SELECT Id, Description, ProductDisplayName__c FROM Product2 WHERE ProductSAPCode__c='12123213'];
	

		Product2 pr2 = new Product2(Name='Monsanto Producto2',ProductSAPCode__c = '12123214',DivisionRef__c=Divi.id, Description='PRODUCTO2');
		insert pr2;
		
		ProductCatalog__c procat = new ProductCatalog__c(name = 'Catalog ii',countryRef__c=c.id);
		insert procat;
		
		ProductCatalog__c procat2 = new ProductCatalog__c(name = 'Catalog iii',countryRef__c=c.id);
		insert procat2;
		
		ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=procat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c (ProductCatalogRef__c=procat2.id, NewProduct__c=true, Price__c=500, productRef__c=pr2.id, 
                                          Ownerid=Util.CurrentUser.id);                                 
		insert pce;
		insert pce2;
		
// Add Stock without HybridRef, create a new Hybrid and assign it to the Stock		
		Stock__c stk1 = new Stock__c(HybridRef__c=null, ProductCatalogEntryRef_RSA__c=pce.id, User_RSA__c=Util.CurrentUser.id, Allocation_RSA__c=123987);  
		List<Hybrid__c> hybridNumPRE = [SELECT id FROM Hybrid__c];
		insert stk1;
		List<Hybrid__c> hybridNumPOST = [SELECT id FROM Hybrid__c];		
		system.assertEquals(hybridNumPRE.size(), (hybridNumPOST.size()-1));
		
		Stock__c stkTest1 = [SELECT Id, HybridRef__c FROM Stock__c WHERE Allocation_RSA__c=123987];
		system.assert(stkTest1.HybridRef__c!=null);
		
// Add Stock without HybridRef, search the proper Hybrid and assign it to the Stock     
		Hybrid__c hyb2= new Hybrid__c(Name='PRODUCTO2', ProductCatalogRef__c=procat2.id,  UserRef__c=Util.CurrentUser.id);
		insert hyb2;		
		
		Stock__c stk2 = new Stock__c(HybridRef__c=null, ProductCatalogEntryRef_RSA__c=pce2.id, User_RSA__c=Util.CurrentUser.id, Allocation_RSA__c=123988);  
		List<Hybrid__c> hybridNumPRE2 = [SELECT id FROM Hybrid__c];
		insert stk2;
		List<Hybrid__c> hybridNumPOST2 = [SELECT id FROM Hybrid__c];
		system.assertEquals(hybridNumPRE2.size(), hybridNumPOST2.size());
		
		Stock__c stkTest2 = [SELECT Id, HybridRef__c FROM Stock__c WHERE Allocation_RSA__c=123988];
		system.assert(stkTest2.HybridRef__c!=null);
		
		
	 Test.StopTest();	
		
	}

}