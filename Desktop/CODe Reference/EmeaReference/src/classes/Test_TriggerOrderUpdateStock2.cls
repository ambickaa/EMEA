@isTest

private class Test_TriggerOrderUpdateStock2 {
    
    static testMethod void mainTest(){
        
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
               
        User admin = [select Id from User where Id = :UserInfo.getUserId()];
        User salesRep;
        User regionalManager;
        System.runAs(admin){
        	UserRole rmRole = new UserRole();
        	UserRole srRole = new UserRole();
        	for(UserRole ur : [SELECT PortalType, PortalAccountId, DeveloperName FROM UserRole WHERE DeveloperName IN ('Regional_Manager_RSA', 'Sales_Representative_RSA')])
        	{
        		if(ur.DeveloperName == 'Regional_Manager_RSA') rmRole = ur;
        		if(ur.DeveloperName == 'Sales_Representative_RSA') srRole = ur;
        	}
        	Profile rmprofile = new Profile();
        	Profile srprofile = new Profile();
        	for(Profile up : [SELECT Id, Name FROM Profile WHERE Name IN ('RSA_Regional Manager', 'RSA_Sales Representative')])
        	{
        		if(up.Name == 'RSA_Regional Manager') rmprofile = up;
        		if(up.Name == 'RSA_Sales Representative') srprofile = up;
        	}
            regionalManager =  new User(Alias = 'RM123', Email='rm1232@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test321', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='rm123@test.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SR321', Email='sr3213@test.com', ManagerID= regionalManager.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test123', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='sr321@test.com');
            insert salesRep;
        }    
        
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=salesRep.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=salesRep.id);
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=regionalManager.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 pr1 = new Product2(Name='Monsanto Product 1', Description='MP1', ProductSAPCode__c = '1111', DivisionRef__c=divi.id);
        
        Product2 pr1b = new Product2(Name='Monsanto Product 1B', Description='MP1', ProductSAPCode__c = '1112', DivisionRef__c=divi.id);
        
        
        Product2 pr2 = new Product2(Name='Monsanto Product 2', Description='MP2', ProductSAPCode__c = '2222', DivisionRef__c=divi.id);
        
        Product2 pr2b = new Product2(Name='Monsanto Product 2B', Description='MP2', ProductSAPCode__c = '2223', DivisionRef__c=divi.id);
          
        
        insert new List<Product2> {pr1,pr1b,pr2,pr2b};  
                                                  
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=100, productRef__c=pr1.id, PriceOld__c=111,
                                                                  Ownerid=salesRep.id, consigned__c=true);  
        
        ProductCatalogEntry__c pce1b = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=100, productRef__c=pr1b.id, PriceOld__c=111,
                                                                  Ownerid=salesRep.id, consigned__c=true);  
        
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=200, productRef__c=pr2.id, PriceOld__c=222,
                                                                  Ownerid=salesRep.id, consigned__c=false);  
                 
        ProductCatalogEntry__c pce2b = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=200, productRef__c=pr2b.id, PriceOld__c=222,
                                                                  Ownerid=salesRep.id, consigned__c=false);  
        
        insert new List<ProductCatalogEntry__C> {pce1, pce1b, pce2, pce2b};
        
        
        Hybrid__c hyb1 = new Hybrid__c(Ownerid=regionalManager.id, Name='MP1', UserRef__c=regionalManager.id, ProductCatalogRef__c=salesCat.id);
        Hybrid__c hyb2 = new Hybrid__c(Ownerid=regionalManager.id, Name='MP2', UserRef__c=regionalManager.id, ProductCatalogRef__c=salesCat.id);

        insert new List<Hybrid__c> {hyb1, hyb2};
        
        
        Stock__c sto1 = new Stock__c (HybridRef__c=hyb1.id, user_RSA__c=regionalManager.id, Allocation_RSA__c=1000, ProductCatalogEntryRef_RSA__c=pce1.id );
        Stock__c sto1b = new Stock__c (HybridRef__c=hyb1.id, user_RSA__c=regionalManager.id, Allocation_RSA__c=1000, ProductCatalogEntryRef_RSA__c=pce1b.id );
        Stock__c sto2 = new Stock__c (HybridRef__c=hyb2.id, user_RSA__c=regionalManager.id, Allocation_RSA__c=2000, ProductCatalogEntryRef_RSA__c=pce2.id );
        Stock__c sto2b = new Stock__c (HybridRef__c=hyb2.id, user_RSA__c=regionalManager.id, Allocation_RSA__c=2000, ProductCatalogEntryRef_RSA__c=pce2b.id );
        insert new List<Stock__c> {sto1, sto1b, sto2, sto2b};
        
        
        ConsignmentWarehouse__c cw1 = new ConsignmentWarehouse__c (ProductCatalogRef__c=salesCat.id, Ownerid=salesRep.id, UserRef__c=salesRep.id );
        insert cw1;
        
        Consignment__c cons1 = new Consignment__c (ProductCatalogEntryRef__c=pce1.id, WarehouseRef__c=cw1.id, UserRef__c=salesRep.id, GlobalStockRef__c=sto1.id, Requested__c=100, Status__c='Accepted' );
        insert cons1;
         
        Order__c oc1= new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true, Consigned__c=true);
                
        Order__c oc2= new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Signed_RSA__c=true, Consigned__c=true, PreliminaryOrderRef_RSA__c=oc1.id,
                                       Bank_Name_Copy_RSA__c='testCl1');
        
        Order__c or1= new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true, Consigned__c=false);      
        
        Order__c or2= new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Signed_RSA__c=true, Consigned__c=false, PreliminaryOrderRef_RSA__c=or1.id,
                                        Bank_Name_Copy_RSA__c='testCl1');
        insert new List<Order__c> {oc1, oc2, or1, or2};
        
        Test.startTest();
        CampaignLineItem__c cli1a = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                ProductCatalogEntryRef__c= pce1.id, FinalOrderRef_RSA__c=oc2.id, 
                                                                Ownerid=regionalManager.ID, FarmRef__c= farm.id, CampaignRef__c= caYear.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '101', ProductRef__c= pr1.id, consigned__c=true, ConsignedWarehouseRef__c=cw1.id); 
/*
        CampaignLineItem__c cli1b = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                            DistributorRef__c=provider.id, Agreed__c=26, CatalogType_RSA__c = 'Regular',
                                                            ProductCatalogEntryRef__c= pce1b.id, FinalOrderRef_RSA__c=oc2.id, 
                                                                Ownerid=regionalManager.ID, FarmRef__c= farm.id, CampaignRef__c= caYear.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '102', ProductRef__c= pr1b.id, consigned__c=true); 
*/
        CampaignLineItem__c cli2 = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=27, CatalogType_RSA__c = 'Regular',
                                                                ProductCatalogEntryRef__c= pce2.id, FinalOrderRef_RSA__c=or2.id, PersonalStock_RSA__c=sto2.id, 
                                                                Ownerid=regionalManager.ID, FarmRef__c= farm.id, CampaignRef__c= caYear.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '201', ProductRef__c= pr2.id, consigned__c=false, GlobalStock_RSA__c=sto2.id); 
/*
        CampaignLineItem__c cli2b = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                            DistributorRef__c=provider.id, Agreed__c=28, CatalogType_RSA__c = 'Regular',
                                                                ProductCatalogEntryRef__c= pce2b.id, FinalOrderRef_RSA__c=or2.id, 
                                                                Ownerid=regionalManager.ID, FarmRef__c= farm.id, CampaignRef__c= caYear.id,
                                                            Type__c= 'Charged', PlantingDensity__c= '202', ProductRef__c= pr2b.id, consigned__c=false); 
	    insert new List<CampaignLineItem__c> {cli1a, cli1b, cli2, cli2b};*/ 
	    insert new List<CampaignLineItem__c> {cli1a, cli2};
	
		/*List<Id> ordersIds = new List<Id>();*/
	    List<Order__c> orders = new List<Order__c>{oc2, or2};
	    /*
	    for(Order__c o : orders)
	    {
	    	ordersIds.add(o.Id);
	    }
	    */
	    List<CampaignLineItem__c> clistest = new List<CampaignLineItem__c>{cli1a, cli2};
	    for(CampaignLineItem__c cli : clistest)
	    {
	    	cli.Agreed__c = 88;
	    }

	    update clistest;
	    
	    Test.stopTest();
	    update orders;	    
        
    }
}