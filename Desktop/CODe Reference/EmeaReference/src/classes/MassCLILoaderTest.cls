@isTest
private class MassCLILoaderTest { 

    static testMethod void cliLoaderTest() {
       
        // General Data Insert
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s2,s3,s6,s7};
                
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
            
        //Past, current and future year. At the moment lastI is the current year.  
            
        Year__c lastII = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                      YearStartDate__c=date.newinstance(2013, 1, 1), CurrentYear_RSA__c=false); 
        insert lastII;  
        Year__c lastI = new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2914, 12, 31), 
                                     YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastII.id,
                                     CurrentYear_RSA__c=true); 
        insert lastI;
        Year__c year= new Year__c (Name='2015', Current_Year__c=false, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(2915, 1, 1), YearPreviousYear__c=lastI.id,
                                   CurrentYear_RSA__c=false); 
        insert year;
        // Insert of managers for the stock allocation. 
        
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
        RecordType coC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'CompetitorProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c salesCatnew = new ProductCatalog__c(name = 'Product Catalog New',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCatnew = new ProductCatalog__c(name = 'Product Catalog Tax New',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c competitorCat = new ProductCatalog__c(name = 'Competitor',countryRef__c=c.id,RecordTypeId=coC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat, salesCatnew, taxCatnew,competitorCat};
        
        // Current and future campaigns insertion for the 3 Users 

        Campaign caYearCL = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=countryLead.id, DivisionRef__c = divi.id,
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCatnew.id,
                                       StartDate=Date.newinstance(2915,02,02), TaxSalesPCMRef_RSA__c=taxCatnew.id);
        Campaign calastICL = new Campaign(name = 'lastI campaign',  YearV2__c=lastI.id, CountryRef__c=c.id, 
                                       OwnerId=countryLead.id, DivisionRef__c = divi.id,
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2914,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(2014,01,02), TaxSalesPCMRef_RSA__c=taxCat.id);  
        Campaign caYearRM = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=regionalManager.id, DivisionRef__c = divi.id, 
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCatnew.id,
                                       StartDate=Date.newinstance(2915,02,02), TaxSalesPCMRef_RSA__c=taxCatnew.id);
        Campaign calastIRM = new Campaign(name = 'lastI campaign',  YearV2__c=lastI.id, CountryRef__c=c.id, 
                                       OwnerId=regionalManager.id, DivisionRef__c = divi.id, 
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2914,11,11), SalesPCMRef__c=Salescat.id,
                                       StartDate=Date.newinstance(2014,01,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCatnew.id,
                                       StartDate=Date.newinstance(2915,02,02), TaxSalesPCMRef_RSA__c=taxCatnew.id);
                          
        Campaign calastISR = new Campaign(name = 'lastI campaign',  YearV2__c=lastI.id, CountryRef__c=c.id, 
                                       OwnerId=salesRep.id, DivisionRef__c = divi.id, 
                                       CompetitorPCMRef__c=competitorCat.id,
                                       EndDate = Date.newinstance(2914,11,11), SalesPCMRef__c=Salescat.id,
                                       StartDate=Date.newinstance(2014,01,02), TaxSalesPCMRef_RSA__c=taxCat.id);          
        insert new List<Campaign>{caYearCL,calastICL, caYearRM,calastIRM,caYearSR,calastISR};
         
        // Product and PCE  Data Insert 
        
        Product2 prS = new Product2(Name='DKC 1 Other',ProductSAPCode__c = '12123213',DivisionRef__c=divi.id, Description='DKC 1');
        Product2 prS2 = new Product2(Name='DKC 2 Other',ProductSAPCode__c = '1212324413',DivisionRef__c=divi.id, Description='DKC 2');
        Product2 prT = new Product2(name='DKC 3 Other',ProductSAPCode__c = '12444444',DivisionRef__c=divi.id,Description='DKC 3');
        insert new List<Product2> {prS, prT, prS2};    
        
        Hybrid__c hyb1=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 1');
        Hybrid__c hyb2=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 2');
        Hybrid__c hyb3=new Hybrid__c(UserRef__c=countryLead.id,ProductCatalogRef__c=taxcat.id, Name='DKC 3');
        Hybrid__c hyb1new=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescatnew.id, Name='DKC 1');
        Hybrid__c hyb2new=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescatnew.id, Name='DKC 2');
        Hybrid__c hyb3new=new Hybrid__c(UserRef__c=countryLead.id,ProductCatalogRef__c=taxcatnew.id, Name='DKC 3');        
        insert new List<Hybrid__c>{hyb1,hyb2,hyb3,hyb1new,hyb2new,hyb3new};
            
        
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, 
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);
        ProductCatalogEntry__c pceS2 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=550, productRef__c=prS2.id, PriceOld__c=530,
                                                                  Ownerid=Util.CurrentUser.id);   
        ProductCatalogEntry__c pceT = new ProductCatalogEntry__c (ProductCatalogRef__c=taxCat.id, NewProduct__c=true, 
                                                                  Price__c=500, productRef__c=prT.id, 
                                                                  Ownerid=Util.CurrentUser.id);   
        ProductCatalogEntry__c pceSnew = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCatnew.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=Util.CurrentUser.id);
        ProductCatalogEntry__c pceS2new = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCatnew.id,  
                                                                  Price__c=550, productRef__c=prS2.id, PriceOld__c=530,
                                                                  Ownerid=Util.CurrentUser.id);   
        ProductCatalogEntry__c pceTnew = new ProductCatalogEntry__c (ProductCatalogRef__c=taxCatnew.id,PriceOld__c=520, 
                                                                  Price__c=500, productRef__c=prT.id, 
                                                                  Ownerid=Util.CurrentUser.id);    
        insert new List<ProductCatalogEntry__c> {pceS, pceS2, pceT,pceSnew, pceS2new, pceTnew}; 
        
        //Stock Insert
        
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id);         
        Stock__c sto2= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceT.id, User_RSA__c=countryLead.id);
        Stock__c sto3= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb2.id,
                                     ProductCatalogEntryRef_RSA__c = pceS2.id, User_RSA__c=regionalManager.id);
        Stock__c sto4= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1new.id,
                                     ProductCatalogEntryRef_RSA__c = pceSnew.id, User_RSA__c=regionalManager.id); 
        Stock__c sto5= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1new.id,
                                     ProductCatalogEntryRef_RSA__c = pceTnew.id, User_RSA__c=countryLead.id);
        Stock__c sto6= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb1new.id,
                                     ProductCatalogEntryRef_RSA__c = pceS2new.id, User_RSA__c=regionalManager.id);
        insert new List<Stock__c>{sto1, sto2,sto3,sto4,sto5,sto6};
        Test.startTest();
        
        //insert of different types of preliminary Orders
        Order__c pOrderSales = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Regular',
                                             RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));     
        Order__c pOrderTax = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Tax',
                                           RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder')); 
        Order__c pOrderFR = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed', OwnerId=salesRep.id, Type_RSA__c='Feb Receipt',
                                          RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));  
        insert new List<Order__c>{pOrderSales, pOrderTax, pOrderFR};   
        
        // insert of different types of final Orders
        Order__c fOrderSales = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderSales.id,
                                             RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Regular',
                                             Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                             BankAccountHolder_copy_RSA__c='TestHolder'); 
        Order__c fOrderTax = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderTax.id,
                                           RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Tax',
                                           Status_RSA__c='Approved', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                           BankAccountHolder_copy_RSA__c='TestHolder');
        Order__c fOrderFR = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderFR.id,
                                          RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Feb Receipt',
                                          Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                          BankAccountHolder_copy_RSA__c='TestHolder'); 
        insert new List<Order__c>{fOrderSales, fOrderTax, fOrderFR};   

        // Regular CLI
        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=20, ProductCatalogEntryRef__c= pceS.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= calastISR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '300', 
                                                                ProductRef__c= prS.id);
        // Regular CLI without preliminary
        CampaignLineItem__c cliSales2 = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                                 DistributorRef__c=provider.id, Agreed__c=55, CatalogType_RSA__c = 'Regular',
                                                                 PoG__c=50, ProductCatalogEntryRef__c= pceS.id, GlobalStock_RSA__c=sto1.id,
                                                                 OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= calastISR.id,
                                                                 PreliminaryOrderRef_RSA__c=null, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                 Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prS.id);
        // Tax CLI 
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= calastISR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prT.id);
        // FR CLI 
        CampaignLineItem__c cliFR = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                             DistributorRef__c=provider.id, Agreed__c=45, CatalogType_RSA__c = 'Feb Receipt',
                                                             PoG__c=40, ProductCatalogEntryRef__c= pceS.id, GlobalStock_RSA__c=sto1.id,
                                                             OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= calastISR.id,
                                                             PreliminaryOrderRef_RSA__c=pOrderFR.id, FinalOrderRef_RSA__c=fOrderFR.id,
                                                             Type__c= 'Charged', PlantingDensity__c= '300', 
                                                             ProductRef__c= prS2.id);
        // FR CLI free of charge
        CampaignLineItem__c cliFR2 = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                             DistributorRef__c=provider.id, Agreed__c=45, CatalogType_RSA__c = 'Feb Receipt',
                                                             PoG__c=40, ProductCatalogEntryRef__c= pceS2.id,GlobalStock_RSA__c=sto3.id,
                                                             OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= calastISR.id, 
                                                             PreliminaryOrderRef_RSA__c=pOrderFR.id, FinalOrderRef_RSA__c=fOrderFR.id,
                                                             Type__c= 'Free of charge', PlantingDensity__c= '300', ProductRef__c= prS2.id);
        insert new List<CampaignLineItem__c>{ cliSales, cliSales2, cliTax, cliFR, cliFR2};
        
        //Change of current year and current campaign
        Year__c lastINew = [SELECT Id, Name, Current_Year__c, YearEndDate__c, YearStartDate__c, YearPreviousYear__c,CurrentYear_RSA__c
                            FROM Year__c
                            WHERE Name ='2014'];
                            
        Year__c yearNew = [SELECT Id, Name, Current_Year__c, YearEndDate__c, YearStartDate__c, YearPreviousYear__c,CurrentYear_RSA__c
                            FROM Year__c
                            WHERE Name ='2015'];  
                                                    
        lastINew.Current_Year__c=false; 
        lastINew.YearEndDate__c=date.newinstance(2014, 1, 20); 
        lastINew.YearStartDate__c=date.newinstance(2014, 1, 1);
        lastINew.CurrentYear_RSA__c=false;    
        update lastINew;
        yearNew.Current_Year__c=true; 
        yearNew.YearEndDate__c=date.newinstance(2915, 12, 31); 
        yearNew.YearStartDate__c=date.newinstance(2014, 1, 21); 
        yearNew.CurrentYear_RSA__c=true;   
        update yearNew;
         
        List<Campaign> campaignsToUpdate = new List<Campaign>(); 
        for (Campaign Campx : [SELECT Id, Name, YearV2__c, EndDate, StartDate FROM Campaign WHERE YearV2__c=:lastINew.id]){                                         
            Campx.EndDate = Date.newinstance(2014,01,20); 
            Campx.StartDate=Date.newinstance(2014,01,02);
            Campx.ArchiveDate__c=Date.newinstance(2916,01,02);
            Campx.StatusCode__c=300;
            campaignsToUpdate.add(Campx);}        
            for (Campaign Campx : [SELECT Id, Name, YearV2__c, EndDate, StartDate FROM Campaign WHERE YearV2__c=:yearNew.id]){                                          
            Campx.EndDate = Date.newinstance(2815,11,11); 
            Campx.StartDate=Date.newinstance(2014,01,21);
            Campx.ArchiveDate__c=Date.newinstance(2916,01,02);
            Campx.StatusCode__c=200;
            campaignsToUpdate.add(Campx);}

        update campaignsToUpdate;                          
        
        //Batch Execution
        set<id> st300=new set<id>();
        for (Campaign camp : [SELECT ID From CAmpaign WHERE statusCode__c=300]){
            st300.add(camp.id);
        }
        system.assert(st300.contains(calastICL.id));
        system.assert(st300.contains(calastIRM.id));
        system.assert(st300.contains(calastISR.id));
        List<CampaignLineItem__c> batchQuery= new List<CampaignLineItem__c>();
        batchQuery=[SELECT DistributorRef__c, PlantingDensity__c, Ultrashort_Irrigation_RSA__c, Pos__c, Provider__c, RecordTypeId,  Agreed__c,  POG__c , ProductCatalogEntryRef__c, CatalogType_RSA__c, Inventory__c, Forecast__c, FarmRef__c, FarmRef__r.OwnerId, Quantity__c,  CampaignRef__c, Type__c, ProductRef__c, Status__c  
                    FROM CampaignLineItem__c WHERE CampaignRef__r.StatusCode__c=300 AND CampaignRef__r.CountryRef__r.Name='South Africa' 
                    AND CampaignRef__R.YearV2__r.Name='2014' AND CampaignRef__r.DivisionRef__r.Name='Corn' AND RecordTypeId=:Util.recordType.get('CampaignLineItem__c:Sales')
                    AND (FinalOrderRef_RSA__r.Status_RSA__c='Closed' OR FinalOrderRef_RSA__r.Status_RSA__c='Approved') AND FinalOrderRef_RSA__r.Signed_RSA__c=true];
        System.assert(batchQuery.size()!= 0);           
        MassCLILoader b1 = new MassCLILoader('2014', '2015','Corn','South Africa',false,'');
        b1.toQuery+='LIMIT 200';
        Database.executeBatch(b1,10);
        Test.stopTest();

        }
}