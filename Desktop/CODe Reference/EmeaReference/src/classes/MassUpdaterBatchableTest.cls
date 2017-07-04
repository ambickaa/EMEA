@isTest
public class MassUpdaterBatchableTest{
    
    public static testmethod void testBudgetMode(){  

        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
                
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1), CurrentYear_RSA__c=false); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id,
                                   CurrentYear_RSA__c=true); 
        insert year;
        
        User admin = [select Id from User where Id = :UserInfo.getUserId()];
        User salesRep;
        User regionalManager;
        User countryLead;
        
        System.runAs(admin){
            UserRole clRole=[SELECT PortalType, PortalAccountId From UserRole where DeveloperName =:'Country_Lead_RSA' limit 1];
            UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA' limit 1];
            UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
            Profile clprofile = [select Id,name from Profile where Name =:'RSA_Country Lead' limit 1];
            Profile rmprofile = [select Id,name from Profile where Name =:'RSA_Regional Manager' limit 1];
            Profile srprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
            String timestamp=String.valueOf(System.now()).replace(' ', '').replace(':','_').replace('-','_');
            
            countryLead = new User(Alias = 'COLEAA', Email=timestamp+'@cl.com', 
                                 EmailEncodingKey='UTF-8', LastName='colead', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = clprofile.Id, UserRoleID = clRole.Id,
                                 TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAC', UserName=timestamp+'@cl.com');
            insert countryLead;         
            regionalManager =  new User(Alias = 'REMANA', Email=timestamp +'@rm.com',ManagerID= countryLead.Id, 
                                        EmailEncodingKey='UTF-8', LastName='remana', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                        TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName=timestamp +'@rm.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SAREPA', Email=timestamp+'@sr.com', ManagerID= regionalManager.Id,
                                 EmailEncodingKey='UTF-8', LastName='sarepre', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                 TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAB', UserName=timestamp+'@sr.com');
            insert salesRep;
        }

        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=salesRep.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=salesRep.id );
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat};


        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2015,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);      
        insert caYearSR;         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Regular',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        Product2 prT = new Product2(name='DKC 3 Tax',ProductSAPCode__c = '12444444',DivisionRef__c=divi.id,Description='DKC 3');
        insert new List<Product2> {prS, prT};    
        
        Hybrid__c hyb1=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 1');
        Hybrid__c hyb3=new Hybrid__c(UserRef__c=countryLead.id,ProductCatalogRef__c=taxcat.id, Name='DKC 3');
     
        insert new List<Hybrid__c>{hyb1,hyb3};
            
        
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
 
        ProductCatalogEntry__c pceT = new ProductCatalogEntry__c (ProductCatalogRef__c=taxCat.id, NewProduct__c=true, 
                                                                  Price__c=500, productRef__c=prT.id, Ownerid=Util.CurrentUser.id);   

        insert new List<ProductCatalogEntry__c> {pceS, pceT}; 
        
        //Stock Insert
        
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id);         
        Stock__c sto2= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceT.id, User_RSA__c=countryLead.id);
        insert new List<Stock__c>{sto1, sto2};
        
        //insert of different types of preliminary Orders
        Order__c pOrderSales = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Regular',
                                             RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true);     
        Order__c pOrderTax = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Tax',
                                           RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true); 
         
        // insert of different types of final Orders
        Order__c fOrderSales = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderSales.id,
                                             RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Regular',
                                             Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                             BankAccountHolder_copy_RSA__c='TestHolder'); 
        Order__c fOrderTax = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderTax.id,
                                           RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Tax',
                                           Status_RSA__c='Approved', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                           BankAccountHolder_copy_RSA__c='TestHolder');
        insert new List<Order__c>{pOrderSales, pOrderTax,fOrderSales, fOrderTax}; 
        
        Test.startTest();        
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id);
        // Tax CLI 
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prT.id);
        insert new list<CampaignLineItem__c>{cliSales, cliTax};   
        
        Budget__c bud = new Budget__c( ProductRef__c=prS.id, YearRef__c=year.id, SalesRep__c=salesRep.id, BudgetApril__c=100, 
                         BudgetJune__c=100, BudgetAugust__c=100, BudgetDecember__c=100, BudgetFebruary__c=100, 
                         BudgetJanuary__c=100, BudgetJuly__c=100,BudgetMarch__c=100, BudgetMay__c=100, BudgetNovember__c=100, 
                         BudgetOctober__c=100, BudgetSeptember__c=100);  
        insert bud;
        
        MassUpdaterBatchable b1= new MassUpdaterBatchable();   
        b1.BudgetMode=true;
        Database.executeBatch(b1,10);
        Test.stopTest();  
    } 
    public static testmethod void testStockUpdater(){  

        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
                
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1), CurrentYear_RSA__c=false); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id,
                                   CurrentYear_RSA__c=true); 
        insert year;
        
        User admin = [select Id from User where Id = :UserInfo.getUserId()];
        User salesRep;
        User regionalManager;
        User countryLead;
        
        System.runAs(admin){
            UserRole clRole=[SELECT PortalType, PortalAccountId From UserRole where DeveloperName =:'Country_Lead_RSA' limit 1];
            UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA' limit 1];
            UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
            Profile clprofile = [select Id,name from Profile where Name =:'RSA_Country Lead' limit 1];
            Profile rmprofile = [select Id,name from Profile where Name =:'RSA_Regional Manager' limit 1];
            Profile srprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
            String timestamp=String.valueOf(System.now()).replace(' ', '').replace(':','_').replace('-','_');
            
            countryLead = new User(Alias = 'COLEAA', Email=timestamp+'@cl.com', 
                                 EmailEncodingKey='UTF-8', LastName='colead', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = clprofile.Id, UserRoleID = clRole.Id,
                                 TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAC', UserName=timestamp+'@cl.com');
            insert countryLead;         
            regionalManager =  new User(Alias = 'REMANA', Email=timestamp +'@rm.com',ManagerID= countryLead.Id, 
                                        EmailEncodingKey='UTF-8', LastName='remana', LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                                        TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName=timestamp +'@rm.com');
            insert regionalManager;
            salesRep =  new User(Alias = 'SAREPA', Email=timestamp+'@sr.com', ManagerID= regionalManager.Id,
                                 EmailEncodingKey='UTF-8', LastName='sarepre', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                                 TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAB', UserName=timestamp+'@sr.com');
            insert salesRep;
        }

        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=salesRep.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=salesRep.id );
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat};


        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2015,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);      
        insert caYearSR;         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Regular',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        Product2 prT = new Product2(name='DKC 3 Tax',ProductSAPCode__c = '12444444',DivisionRef__c=divi.id,Description='DKC 3');
        insert new List<Product2> {prS, prT};    
        
        Hybrid__c hyb1=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 1');
        Hybrid__c hyb3=new Hybrid__c(UserRef__c=countryLead.id,ProductCatalogRef__c=taxcat.id, Name='DKC 3');
     
        insert new List<Hybrid__c>{hyb1,hyb3};
            
        
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
 
        ProductCatalogEntry__c pceT = new ProductCatalogEntry__c (ProductCatalogRef__c=taxCat.id, NewProduct__c=true, 
                                                                  Price__c=500, productRef__c=prT.id, Ownerid=Util.CurrentUser.id);   

        insert new List<ProductCatalogEntry__c> {pceS, pceT}; 
        
        //Stock Insert
        
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id);         
        Stock__c sto2= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceT.id, User_RSA__c=countryLead.id);
        insert new List<Stock__c>{sto1, sto2};
        
        //insert of different types of preliminary Orders
        Order__c pOrderSales = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Regular',
                                             RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));     
        Order__c pOrderTax = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Tax',
                                           RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder')); 
         
        // insert of different types of final Orders
        Order__c fOrderSales = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderSales.id,
                                             RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Regular',
                                             Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                             BankAccountHolder_copy_RSA__c='TestHolder'); 
        Order__c fOrderTax = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderTax.id,
                                           RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Tax',
                                           Status_RSA__c='Approved', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                           BankAccountHolder_copy_RSA__c='TestHolder');
        insert new List<Order__c>{pOrderSales, pOrderTax,fOrderSales, fOrderTax}; 
        
        Test.startTest();        
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id);
        // Tax CLI 
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prT.id);
        insert new list<CampaignLineItem__c>{cliSales, cliTax};   
        
        Budget__c bud = new Budget__c( ProductRef__c=prS.id, YearRef__c=year.id, SalesRep__c=salesRep.id, BudgetApril__c=100, 
                         BudgetJune__c=100, BudgetAugust__c=100, BudgetDecember__c=100, BudgetFebruary__c=100, 
                         BudgetJanuary__c=100, BudgetJuly__c=100,BudgetMarch__c=100, BudgetMay__c=100, BudgetNovember__c=100, 
                         BudgetOctober__c=100, BudgetSeptember__c=100);  
        insert bud;
        
        MassUpdaterBatchable b2= new MassUpdaterBatchable();   
        b2.StockUpdater=true;
        Database.executeBatch(b2,10);
        Test.stopTest();  
    } 
    public static testmethod void testEastCLIPY(){  

        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                
        Country__c c = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1)); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id); 
        insert year;
        
        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id );
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert salesCat;

        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2015,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,02,02));      
        insert caYearSR;         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Regular',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        insert prS;   
                                    
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
        insert pceS;
 
        Test.startTest();        
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, Forecast__c=15,
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=Util.currentUser.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, 
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id, POGPY__c=12);
        insert cliSales;   
        
        Product_Grouping__c pgt = new Product_Grouping__c(name = 'CornSilage', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
        Product_Grouping__c pgg = new Product_Grouping__c(name = 'Corn', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c>{pgg,pgt};
        RecordType App = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProduct'];
        RecordType Appg = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProductGroup'];
        
        List<Acreage__c> acreages = new List<Acreage__c>();  
        for(Integer i=0; i<5; i++){
            Acreage__c acr=new Acreage__c( AcrFarmRef__c=farm.id, AcrProviderRef__c=Provider.id, AcrTotalAcreages__c=100,
                            Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, AcrSecondHarvest__c=false,
                            RecordTypeId=App.Id, idDevice__c=100+i,
                            AcrYearRef__c=Year.ID, AcrProductGroupRef__c=pgg.id, AcrProductTypeRef__c=pgt.id);
           acreages.add(acr);
        }
        insert acreages;
        MassUpdaterBatchable b3= new MassUpdaterBatchable();   
        b3.EastCLIPY=true;
        Database.executeBatch(b3,10);
        Test.stopTest();  
    }
    public static testmethod void testTotAcrSales(){  

        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                
        Country__c c = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1)); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id); 
        insert year;
        
        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id );
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert salesCat;

        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2015,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,02,02));      
        insert caYearSR;         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Regular',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        insert prS;   
                                    
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
        insert pceS;
 
        Test.startTest();        
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, Forecast__c=15,
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=Util.currentUser.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, 
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id, POGPY__c=12);
        insert cliSales;   
        
        Product_Grouping__c pgt = new Product_Grouping__c(name = 'CornSilage', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
        Product_Grouping__c pgg = new Product_Grouping__c(name = 'Corn', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c>{pgg,pgt};
        RecordType App = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProduct'];
        RecordType Appg = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProductGroup'];
        
        List<Acreage__c> acreages = new List<Acreage__c>();  
        for(Integer i=0; i<5; i++){
            Acreage__c acr=new Acreage__c( AcrFarmRef__c=farm.id, AcrProviderRef__c=Provider.id, AcrTotalAcreages__c=100,
                            Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, AcrSecondHarvest__c=false,
                            RecordTypeId=App.Id, idDevice__c=100+i,
                            AcrYearRef__c=Year.ID, AcrProductGroupRef__c=pgg.id, AcrProductTypeRef__c=pgt.id);
           acreages.add(acr);
        }
        insert acreages;
        MassUpdaterBatchable b4= new MassUpdaterBatchable();   
        b4.TotAcrSales=true;
        b4.Country='Ukraine';
        Database.executeBatch(b4,10);
        Test.stopTest();  
    }
}