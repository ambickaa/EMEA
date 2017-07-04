@IsTest

public class OrderGeneratorRemoterTest{

    public static testmethod void getterSetter(){
        
        /* General data insert: System Settings, Country, current and past Year, Division, Accounts, Campaign, Product, Product Catalog,
        Product Catalog Entry and a Preliminary Order */ 
        
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
                               
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
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.currentUser.id);
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id);
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular',
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular',
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=Util.currentUser.ID,  
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id);  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=Util.currentUser.ID,  
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordC.ID);     
                                     
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /* getters and setters */
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        
        String rot=controller.getorderType();
        controller.setorderType('Final');
        String rct=controller.getcatalogType();
        controller.setcatalogType('Regular');       
        Boolean consi=controller.getconsigned();
        controller.setconsigned(false);
        String rca=controller.getcurrentAccount();
        controller.setcurrentAccount(farm.id);
        String ok= OrderGeneratorRemoter.foo('Ok');
        controller.getOrderOption();
        controller.setorderOption(null);
        
        System.assertequals(controller.orderType,'Final');
        System.assertequals(controller.catalogType,'Regular');
        System.assertequals(controller.currentAccount, farm.id);  
              
        /* getActionPlanItems method test*/  
        
        List<CampaignLineItem__c> testList1 = New List<CampaignLineItem__c> ();
        testList1 = OrderGeneratorRemoter.getActionPlanItems('INIT', 'Preliminary', 'Regular',false, farm.id);
        System.assertequals(testList1.get(0).ID, cli1.ID);
        
        List<CampaignLineItem__c> testList2= New List<CampaignLineItem__c> ();
        testList2 = OrderGeneratorRemoter.getActionPlanItems('INIT', 'Final', 'Regular',false, farm.id );
        System.assertEquals(testList2.size(),2);
        
        List<CampaignLineItem__c> testList3 = New List<CampaignLineItem__c> ();
        TestList3 = OrderGeneratorRemoter.getActionPlanItems(pOrdC.id, 'Preliminary', 'Regular',false, farm.id );
        System.assertEquals(testList3.size(),2);
                
        PageReference laun = controller.launcher();
        controller.idHandler();
           
        /* orderItemHandler method test*/  
                
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Final');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','false'); 
        controller.getOrderOptions();
        controller.orderOption=null;
        ApexPages.currentPage().getParameters().put('orderType','Preliminary'); 
        controller.getorderOptions();
        
        /* getOrderOptions method test*/  
        controller.orderOption=null;
        ApexPages.currentPage().getParameters().put('orderType','Final');
        OrderGeneratorRemoter controller2= new OrderGeneratorRemoter();
        controller2.stringListIds=String.valueOf(cli1.id)+','+String.valueOf(cli2.Id);      
        List<OrderGeneratorRemoter.OrderItem2> oi2 = controller2.orderItemHandler(true);        
    }
    public static testmethod void orderPreliminaryCreator(){

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
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id, Description='DKC1');
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        Hybrid__c hyb= new Hybrid__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=regionalManager.id);
        insert hyb;
        Stock__c sto = new Stock__c(Allocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id, hybridRef__c=hyb.id);
        insert sto;
        
        Test.startTest();
                
        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id);  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordD.ID);     
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /*New Regular Preliminary Order*/
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Preliminary');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','false'); 
        
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        controller.stringListIds=String.valueOf(cli1.id);
        controller.consigned=false; 
        PageReference newOrder = controller.createPreliminaryOrder();
        controller.stringListIds = controller.stringListIds+','+String.valueOf(cli2.id);
        pOrdC.Status_RSA__c='Draft';
        update pOrdC;
        controller.preliminaryOrderID=String.valueOf(pOrdC);
        PageReference updateOrder = controller.updatePreliminaryOrder();
        controller.orderOption=pOrdC.id;
        PageReference deleteorder = controller.deletePreliminaryOrder();
        Test.stopTest();
    }
    public static testmethod void orderFinalCreator(){

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
            regionalManager =  new User(Alias = 'RMd332', Email='rmhgfh@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test321', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='rmfgd4@test.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SR1113', Email='srghfg@test.com', ManagerID= regionalManager.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test123', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='srfdgdf3@test.com');
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
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=salesRep.id, BankAccountHolder_RSA__c='Holder');
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=salesRep.id);
        insert new List<Account> {farm, provider};
        Contact con= new Contact(LastName='Van ',CountryRef__c=c.id, idDevice__c='900',AccountId=farm.id);        
        insert con;
        farm.Buyer_RSA__c=con.id;
        update farm;
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id, Description='DKC1');
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        Hybrid__c hyb= new Hybrid__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=regionalManager.id);
        insert hyb;
        Stock__c sto = new Stock__c(Allocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id, hybridRef__c=hyb.id);
        insert sto;
        
		Test.startTest();

        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id);  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordD.ID);     
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /*New Regular Preliminary Order*/
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Final');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','false'); 
        
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        controller.consigned=false; 
        controller.currentAccount= String.valueOf(farm.id);
        controller.stringListIds = String.valueOf(cli1.id)+','+String.valueOf(cli2.id);
        controller.preliminaryOrderID=String.valueOf(pOrdC);
        controller.orderOption=pOrdC.id;
        PageReference newOrder = controller.createFinalOrder();
        Test.stopTest();
    }
    public static testmethod void orderPreliminaryConsigned(){

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
            regionalManager =  new User(Alias = 'RMfdfd', Email='rmfdgf@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test321', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='rmdfs48@test.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SRfdf3', Email='sr777f@test.com', ManagerID= regionalManager.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test123', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='srfd4@te3st.com');
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
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id, Description='DKC1');
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Consigned__c=true, 
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=true);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=true); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        Hybrid__c hyb= new Hybrid__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=regionalManager.id);
        insert hyb;
        Stock__c sto = new Stock__c(Allocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id, hybridRef__c=hyb.id);
        insert sto;
        ConsignmentWarehouse__c cW= new ConsignmentWarehouse__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=salesRep.id);
        insert cW;
        Consignment__c consignment= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, UserRef__c=salesRep.id, Requested__c=100);
        insert consignment;
        
        Test.startTest();
        
        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id,consigned__c=true, ConsignedWarehouseRef__c=cW.id );  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordD.ID,consigned__c=true, 
                                     ConsignedWarehouseRef__c=cW.id);     
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /*New Regular Preliminary Order*/
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Preliminary');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','true'); 
        
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        controller.stringListIds=String.valueOf(cli1.id);
        controller.consigned=true; 
        PageReference newOrder = controller.createPreliminaryOrder();
        controller.stringListIds = controller.stringListIds+','+String.valueOf(cli2.id);
        pOrdC.Status_RSA__c='Draft';
        update pOrdC;
        controller.preliminaryOrderID=String.valueOf(pOrdC);
        PageReference updateOrder = controller.updatePreliminaryOrder();
        controller.orderOption=pOrdC.id;
        PageReference deleteorder = controller.deletePreliminaryOrder();
        Test.stopTest();
    }
    public static testmethod void orderFinalConsigned(){

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
            regionalManager =  new User(Alias = 'RM1123', Email='rm543543@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test321', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='rm5435@test.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SR321', Email='sr115435@test.com', ManagerID= regionalManager.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test123', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='sr43543@test.com');
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
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=salesRep.id, BankAccountHolder_RSA__c='Holder');
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=salesRep.id);
        insert new List<Account> {farm, provider};
        Contact con= new Contact(LastName='Van ',CountryRef__c=c.id, idDevice__c='900',AccountId=farm.id);        
        insert con;
        farm.Buyer_RSA__c=con.id;
        update farm;
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id, Description='DKC1');
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        Hybrid__c hyb= new Hybrid__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=regionalManager.id);
        insert hyb;
        Stock__c sto = new Stock__c(Allocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id, hybridRef__c=hyb.id);
        insert sto;
        ConsignmentWarehouse__c cW= new ConsignmentWarehouse__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=salesRep.id);
        insert cW;
        Consignment__c consignment= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, UserRef__c=salesRep.id, Requested__c=100);
        insert consignment;
        
        Test.startTest();
        
        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id,consigned__c=true, ConsignedWarehouseRef__c=cW.id );  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordD.ID,consigned__c=true, 
                                     ConsignedWarehouseRef__c=cW.id);    
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /*New Regular Preliminary Order*/
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Final');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','true'); 
        
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        controller.consigned=true; 
        controller.currentAccount= String.valueOf(farm.id);
        controller.stringListIds = String.valueOf(cli1.id)+','+String.valueOf(cli2.id);
        controller.preliminaryOrderID=String.valueOf(pOrdC);
        controller.orderOption=pOrdC.id;
        PageReference newOrder = controller.createFinalOrder();
        Test.stopTest();
    }   
    public static testmethod void orderMore(){

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
            regionalManager =  new User(Alias = 'RM1123', Email='rm543543@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test321', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='rm5435@test.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SR321', Email='sr115435@test.com', ManagerID= regionalManager.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test123', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='sr43543@test.com');
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
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=salesRep.id, BankAccountHolder_RSA__c='Holder');
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=salesRep.id);
        insert new List<Account> {farm, provider};
        Contact con= new Contact(LastName='Van ',CountryRef__c=c.id, idDevice__c='900',AccountId=farm.id);        
        insert con;
        farm.Buyer_RSA__c=con.id;
        update farm;
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        Product2 prS = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213', DivisionRef__c=divi.id, Description='DKC1');
        insert prS;  
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);  
        insert pceS;        

        Order__c pOrdC = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false);             
        Order__c pOrdD = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Draft', Type_RSA__c='Regular', OwnerId=salesRep.id,
                                       RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Consigned__c=false); 
                                           
        insert new list<Order__c>{pOrdC, pOrdD};
        
        Hybrid__c hyb= new Hybrid__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=regionalManager.id);
        insert hyb;
        Stock__c sto = new Stock__c(Allocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id, hybridRef__c=hyb.id);
        insert sto;
        ConsignmentWarehouse__c cW= new ConsignmentWarehouse__c(Name='DKC 1', ProductCatalogRef__c=salesCat.id, UserRef__c=salesRep.id);
        insert cW;
        Consignment__c consignment= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, UserRef__c=salesRep.id, Requested__c=100);
        insert consignment;
        
        Test.startTest();
        
        CampaignLineItem__c cli1=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id,consigned__c=true, ConsignedWarehouseRef__c=cW.id );  
                                     
        CampaignLineItem__c cli2=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=provider.id, Forecast__c=5, Agreed__c=6, CampaignRef__c= caYear.id,
                                     PoG__c=7, ProductCatalogEntryRef__c= pceS.id, Ownerid=salesRep.ID, GlobalStock_RSA__c=sto.id, 
                                     Type__c= 'Charged', PlantingDensity__c= '30000', CatalogType_RSA__c='Regular',
                                     FarmRef__c= farm.id, ProductRef__c= prS.id, PreliminaryOrderRef_RSA__c=pordD.ID,consigned__c=true, 
                                     ConsignedWarehouseRef__c=cW.id);    
        insert new List<CampaignLineItem__c>{cli1,cli2};
        
        /*New Regular Preliminary Order*/
        ApexPages.currentPage().getParameters().put('accountId',farm.ID);
        ApexPages.currentPage().getParameters().put('orderType','Final');
        ApexPages.currentPage().getParameters().put('catalogType','Regular'); 
        ApexPages.currentPage().getParameters().put('consigned','true'); 
        
        OrderGeneratorRemoter controller= new OrderGeneratorRemoter();
        String orderType = controller.getorderType();
        controller.setorderType(orderType);
        controller.setconsigned(controller.getconsigned());
        controller.setcatalogType(controller.getcatalogType());
        controller.setcurrentAccount(String.valueOf(farm.id));
        controller.orderOption ='New Order';
        controller.getorderOptions();
        controller.setorderOption(controller.getorderOption());
            
        
        Test.stopTest();
    }   
}