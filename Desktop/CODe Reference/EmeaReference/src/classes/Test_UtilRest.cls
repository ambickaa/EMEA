@isTest 
public class Test_UtilRest{
    @isTest (seeAllData=True)
    public static void Sharing(){
    
            Set<CampaignLineItem__Share> CliShared = new Set<CampaignLineItem__Share>();
            for(CampaignLineItem__Share clis:[SELECT AccessLevel,Id,IsDeleted,LastModifiedById,
                    LastModifiedDate,ParentId,RowCause,UserOrGroupId 
                    FROM CampaignLineItem__Share 
                    WHERE UserOrGroupId=:Util.currentUser.Id]){
                        CliShared.add(clis);}
            System.AssertEquals(CliShared ,Utilrest.currentUserCliShared);
            
          SET<CampaignLineItemGroup__Share> CliGroupShared = new SET<CampaignLineItemGroup__Share>();
          for(CampaignLineItemGroup__Share clis: [SELECT AccessLevel,Id,IsDeleted,LastModifiedById,
                     LastModifiedDate,ParentId,RowCause,UserOrGroupId
                     FROM CampaignLineItemGroup__Share 
                     WHERE UserOrGroupId=:Util.currentUser.Id] ){
              CliGroupShared.add(clis);}
          System.AssertEquals(CliGroupShared ,Utilrest.currentUserCliGroupShared);
          
          SET<AccountShare> AccountShared = new SET<AccountShare>();
          for(AccountShare acc: [SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,Id,IsDeleted,LastModifiedById,
                    LastModifiedDate,OpportunityAccessLevel,RowCause,UserOrGroupId 
                    FROM AccountShare 
                    WHERE UserOrGroupId=:Util.currentUser.Id ] ){
              AccountShared.add(acc);}
          System.AssertEquals(AccountShared , Utilrest.currentUserAccountShared);
          
          SET<id> currentUserAccountSharedIds= UtilREST.currentUserAccountSharedIds;
    }
    @isTest
    public static void utilRESTCalls() {
    	
    	Test.startTest();
    	Id MonfastCurrentCampaign = UtilREST.MonfastCurrentCampaign;
    	Id MonitorCurrentCampaign = UtilREST.MonitorCurrentCampaign;
    	Id LatitudeCurrentCampaign = UtilREST.LatitudeCurrentCampaign;
    	Id RoundupCurrentCampaign = UtilREST.RoundupCurrentCampaign;
    	
    	Test.stopTest();
    }
    @isTest 
    public static void CurrentCampaigns(){
    
        Test_REST_DatafactoryEast.TestData();
    
        System.AssertEquals(Utilrest.CornCurrentCampaign,Test_REST_DatafactoryEast.ca.Id);
        System.AssertEquals(Utilrest.CurrentCampaignRSA.id,Test_REST_DatafactoryEast.ca.Id);

		Test.startTest();       
        Campaign OSRCC = Test_REST_DatafactoryEast.caOSR;
        ID UtilID=Utilrest.OSRCurrentCampaign;
        System.AssertEquals(OSRCC.id,UtilID);
        
          
        System.AssertEquals(Test_REST_DatafactoryEast.Year.Id,UtilRest.currentYearRSA);   
          
        SET<ID> AC = new SET<ID>();
        AC.add(OSRCC.id);
        AC.add(Test_REST_DatafactoryEast.ca.id);
        System.AssertEquals(AC, UtilRest.activeCampaigns);
    
        SET <ID> ACSales= new SET<ID>();
        ACSales.add(Test_REST_DatafactoryEast.procat.id);        
        ACSales.add(Test_REST_DatafactoryEast.prcat.id);        
        System.AssertEquals(ACSales,UtilRest.activeSalesCatalogs);
        
        SET <ID> ACSales_CLI= new SET<ID>();
        ACSales_CLI.add(Test_REST_DatafactoryEast.procat.id);        
        ACSales_CLI.add(Test_REST_DatafactoryEast.prcat.id);        
        System.AssertEquals(ACSales_CLI,UtilRest.activeSalesCatalogs_CLI); 
        
        SET<ID> ACTrial= new SET<ID>();
        ACTrial.add(Test_REST_DatafactoryEast.procat.id);        
        ACTrial.add(Test_REST_DatafactoryEast.trcat.id); 
        System.AssertEquals(ACTrial,UtilRest.activeTrialCatalogs);
        
        SET<ID> PYC= new SET<ID>();
        PYC.add(Test_REST_DatafactoryEast.pastcat.id);
        System.AssertEquals(PYC,UtilRest.PreviousYearCatalogs);
 
        SET<ID> CLYC= new SET<ID>();
        CLYC.add(Test_REST_DatafactoryEast.ca.id);
        CLYC.add(Test_REST_DatafactoryEast.cain.id);
        CLYC.add(OSRCC.id);
        System.AssertEquals(CLYC,UtilRest.currentAndLastYearCampaignRSA);    

        SET<ID> VP= new SET<ID>();
        VP.add(Test_REST_DatafactoryEast.pce.ProductRef__c);
        for( Product2 prox : Test_REST_DatafactoryEast.plist){
            VP.add(prox.id);}
        System.AssertEquals(VP,UtilRest.ValidPro);   
        SET<id> activeCatalogsAll= UtilREST.activeCatalogsAll;
        Util.currentAccount=Test_REST_DataFactoryEast.Farm;
      Boolean voucherEnabled= UtilREST.VoucherEnabled;
      Year__c currentVoucherYear=UtilREST.currentVoucherYear;
      
      Test.stopTest();
      
    }
   
    public static testMethod void ResetTime(){
    
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_RESET',Value__C='true');
        String Str=String.Valueof(Datetime.newinstance(2013,01,01,21,01,01));
        SystemSettings__c s2 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C=str);
            insert s1;
            insert s2;
        Datetime testtime =Datetime.newinstance(2012,01,01,23,01,01);
        Datetime Resettime=UtilRest.resetTimestamp(testtime);
        System.Assert(Resettime==Datetime.newinstance(0));
     }
     public static testMethod void UpdatingBudget(){
       
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
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', 
                                                                ProductRef__c= prS.id);
        // Tax CLI 
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '30000', ProductRef__c= prT.id);
        insert new list<CampaignLineItem__c>{cliSales, cliTax};   
        
        Budget__c bud = new Budget__c( ProductRef__c=prS.id, YearRef__c=year.id, SalesRep__c=salesRep.id, BudgetApril__c=100, 
                         BudgetJune__c=100, BudgetAugust__c=100, BudgetDecember__c=100, BudgetFebruary__c=100, 
                         BudgetJanuary__c=100, BudgetJuly__c=100,BudgetMarch__c=100, BudgetMay__c=100, BudgetNovember__c=100, 
                         BudgetOctober__c=100, BudgetSeptember__c=100);  
      insert bud;
        List<ID> UseridList = new List<ID>{salesRep.id};
        List<Id> prod= new List<ID>{prS.id};
        UtilRest.BudgetUpdater(prod, UseridList);
    }
  public static testMethod void sendConsignmentMails(){
       
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_ORDER_ORG_MAILER_ID',Value__C='0D2D00000004DfZ');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s1,s2,s3,s6,s7};
                
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
      UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA_Region_2' limit 1];
      UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA_Region_6' limit 1];
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
        
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25, TaxAllocation_RSA__c=25, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id);         
        Stock__c sto2= new Stock__c( Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceT.id, User_RSA__c=countryLead.id);
        insert new List<Stock__c>{sto1, sto2};
        
        ConsignmentWarehouse__c cwA= new ConsignmentWarehouse__c(ProductCatalogRef__c=salesCat.id, UserRef__c=salesRep.id, NAme='DKC 1');
        insert cwA;
        
        Consignment__c conA= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, Requested__c=15, UserRef__c=salesRep.id, WarehouseRef__c=cwA.id );
        Consignment__c conB= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, Requested__c=50, UserRef__c=salesRep.id, WarehouseRef__c=cwA.id );
    List<Consignment__c> consignments= new List<Consignment__c>{conA, conB};
    insert consignments;
    Test.StartTest();
    Map<Id, Consignment__c> consToSend = new Map<id, Consignment__c>([SELECT ProductCatalogEntryRef__c, Requested__c, UserRef__c, GlobalStockRef__c, 
                        GlobalStockRef__r.HybridRef__r.Name,GlobalStockRef__r.HybridRef__r.Stockleft__c, Consignment__c.Status__c, 
                        GlobalStockRef__r.HybridRef__c, ProductCatalogEntryRef__r.ProductRef__r.Name 
                        FROM Consignment__c]);
      
    salesRep=[SELECT Id, Name, Alias, Email, ManagerID,LastName, ProfileId, UserRoleID ,UserName, Manager.Name, UserRole.Name, Manager.Email FROM User WHERE Alias='SAREPA'];                    
    Util.currentUser=salesRep;                    
    UtilREST.sendConsignmentMail(consToSend); 
    UtilREST.sendConsApprovetMail(consToSend.values(),True);   
    Test.StopTest();
     }     
     
        public static testMethod void RSAActiveCatalogs(){
    
        Country__c c = new Country__c(Name ='South Africa', TacticalPlanSetting__c = 'Standard');      
            insert c;
            
        Year__c Last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
            YearStartDate__c=date.newinstance(2012, 1, 1)); 
            insert Last;    
        Year__c Year= new Year__c (Name='2013-2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
            YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
            insert Year;
            
        Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
            insert Divi;

        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];

        ProductCatalog__c prcat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c pastcat = new ProductCatalog__c(name = 'Product Catalog Sales',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c procat = new ProductCatalog__c(name = 'Catalog Comp.',countryRef__c=c.id);
        List<ProductCatalog__c> PCList = new List<ProductCatalog__c>{prcat, pastcat, procat};
        insert PCList;
        
        Campaign ca = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2014,11,11), statuscode__c=200,
                          StartDate=Date.newinstance(2013,02,02), DivisionRef__c = Divi.id, 
                          CompetitorPCMRef__c=pastcat.id, SalesPCMRef__c=prcat.id, TaxSalesPCMRef_RSA__c=procat.id);
        insert ca;  
    
        SET <ID> ACSalesRSA= new SET<ID>();
        ACSalesRSA.add(procat.id);        
        ACSalesRSA.add(prcat.id);           
  //    System.AssertEquals(ACSalesRSA,UtilRest.activeSalesCatalogsRSA);

        SET<ID> ACRegularRSA= new SET<ID>();
        ACRegularRSA.add(prcat.id);
        System.AssertEquals(ACRegularRSA,UtilRest.activeRegularCatalogRSA);
        
        SET<ID> ACTaxRSA= new SET<ID>();
        ACTaxRSA.add(procat.id);        
        System.AssertEquals(ACTaxRSA,UtilRest.activeTaxCatalogRSA);
     }
  public static testMethod void sendStockMails(){
       
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_ORDER_ORG_MAILER_ID',Value__C='0D2D00000004DfZ');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s1,s2,s3,s6,s7};
                
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
      UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA_Region_2' limit 1];
      UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA_Region_6' limit 1];
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
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', 
                                                                ProductRef__c= prS.id);
        List<CampaignLineItem__c> regularCLI=new List<CampaignLineItem__c>{cliSales};
        // Tax CLI 
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '30000', ProductRef__c= prT.id);
        List<CampaignLineItem__c> taxCLI=new List<CampaignLineItem__c>{cliTax};
        
        insert new list<CampaignLineItem__c>{cliSales, cliTax};   
        
        Budget__c bud = new Budget__c( ProductRef__c=prS.id, YearRef__c=year.id, SalesRep__c=salesRep.id, BudgetApril__c=100, 
                         BudgetJune__c=100, BudgetAugust__c=100, BudgetDecember__c=100, BudgetFebruary__c=100, 
                         BudgetJanuary__c=100, BudgetJuly__c=100,BudgetMarch__c=100, BudgetMay__c=100, BudgetNovember__c=100, 
                         BudgetOctober__c=100, BudgetSeptember__c=100);  
      insert bud;
      List<Stock__c> stk1=new List<Stock__c>{sto1};
      List<Stock__c> stk2=new List<Stock__c>{sto2};
    salesRep=[SELECT Id, Name, Alias, Email, ManagerID,LastName, ProfileId, UserRoleID ,UserName, Manager.Name, UserRole.Name, Manager.Email FROM User WHERE Alias='SAREPA'];                    
    Util.currentUser=salesRep;        
    UtilREST.sendStockMail(fOrderSales, regularCLI, true, true, stk1);      
    UtilREST.sendStockMail(fOrderTax, taxCLI, false, true, stk2); 
    UtilREST.sendStockMail(fOrderSales, regularCLI, true, false, stk1);      
    UtilREST.sendStockMail(fOrderTax, taxCLI, false, false, stk2);          
     }
  public static testMethod void stockErrorMessages(){
       
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s4 = new SystemSettings__c( Name='RSA_STOCK_MAILS',Value__C='true');
        SystemSettings__c s1 = new SystemSettings__c( Name='RSA_ORDER_ORG_MAILER_ID',Value__C='0D2D00000004DfZ');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        insert new List<SystemSettings__c>{s1,s2,s3,s4,s6,s7};
                
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
      UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA_Region_2' limit 1];
      UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA_Region_6' limit 1];
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
        Product2 prS2 = new Product2(Name='DKC 12 Regular',ProductSAPCode__c = '1212321333',DivisionRef__c=divi.id, Description='DKC 12');
        Product2 prT = new Product2(name='DKC 3 Tax',ProductSAPCode__c = '12444444',DivisionRef__c=divi.id,Description='DKC 3');
        insert new List<Product2> {prS, prT, prS2};    
        
        Hybrid__c hyb1=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 1');
        Hybrid__c hyb2=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 12');
        Hybrid__c hyb3=new Hybrid__c(UserRef__c=countryLead.id,ProductCatalogRef__c=taxcat.id, Name='DKC 3');
     
        insert new List<Hybrid__c>{hyb1,hyb3,hyb2};
                                        
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id, Consigned__c=true);
        ProductCatalogEntry__c pceS2 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS2.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id, Consigned__c=true);                                                                  
        ProductCatalogEntry__c pceT = new ProductCatalogEntry__c (ProductCatalogRef__c=taxCat.id, NewProduct__c=true, 
                                                                  Price__c=500, productRef__c=prT.id, Ownerid=Util.CurrentUser.id);   
        insert new List<ProductCatalogEntry__c> {pceS, pceT,pceS2}; 
        
        //Stock Insert
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25, TaxAllocation_RSA__c=25, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id);         
        Stock__c sto2= new Stock__c( Allocation_RSA__c=25, TaxAllocation_RSA__c=25, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceT.id, User_RSA__c=countryLead.id); 
        insert new List<Stock__c>{sto1, sto2};
        
        ConsignmentWarehouse__c cwA= new ConsignmentWarehouse__c(ProductCatalogRef__c=salesCat.id, UserRef__c=salesRep.id, NAme='DKC 1');
        insert cwA;        
        Consignment__c conA= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, Requested__c=15, UserRef__c=salesRep.id,WarehouseRef__c=cwA.id );
        insert conA;
        Test.startTest();
        Order__c pOrderSales = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Regular',
                                             RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true,
                                             Consigned__c=false, idDevice__c=11);     
        Order__c pOrderTax = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Tax',
                                           RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true, idDevice__c=12); 
        Order__c pOrderCon = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',OwnerId=salesRep.id, Type_RSA__c='Regular',
                                           RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), Signed_RSA__c=true,
                                           Consigned__c=true, idDevice__c=13);          
        Order__c fOrderSales = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderSales.id,
                                             RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Regular',
                                             Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, Consigned__c=false,
                                             BankAccountHolder_copy_RSA__c='TestHolder', idDevice__c=1, Name='Sales',Name_Copy__c='Sales'); 
        Order__c fOrderTax = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderTax.id,
                                           RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Tax',
                                           Status_RSA__c='Approved', Signed_RSA__c=true,OwnerId=salesRep.id, 
                                           BankAccountHolder_copy_RSA__c='TestHolder', idDevice__c=2, Name='Tax',Name_Copy__c='Tax');
        Order__c fOrderCon = new Order__c( AccountRef_RSA__c=farm.id, //PreliminaryOrderRef_RSA__c=pOrderSales.id,
                                             RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), Type_RSA__c='Regular',
                                             Status_RSA__c='Closed', Signed_RSA__c=true,OwnerId=salesRep.id, Consigned__c=true,
                                             BankAccountHolder_copy_RSA__c='TestHolder', idDevice__c=3, Name='Consigned',Name_Copy__c='Consigned');                                            
        List<Order__c> orderList = new List<Order__c>{pOrderSales, pOrderCon, pOrderTax, fOrderSales,fOrderCon, fOrderTax}; 

        CampaignLineItem__c cliSales = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=30, ProductCatalogEntryRef__c= pceS.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', Consigned__c=false,
                                                                ProductRef__c= prS.id);
                                                                
        CampaignLineItem__c cliSales2 = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=30, ProductCatalogEntryRef__c= pceS2.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderSales.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', Consigned__c=false,
                                                                ProductRef__c= prS2.id);
                                                                
        CampaignLineItem__c cliCon = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=30, ProductCatalogEntryRef__c= pceS.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderCon.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', Consigned__c=true,
                                                                ProductRef__c= prS.id);
                                                                
        CampaignLineItem__c cliCon2 = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                PoG__c=30, ProductCatalogEntryRef__c= pceS2.id, OwnerID=salesRep.id, 
                                                                FarmRef__c= farm.id, CampaignRef__c= caYearSR.id, GlobalStock_RSA__c=sto1.id,
                                                                PreliminaryOrderRef_RSA__c=pOrderSales.id, FinalOrderRef_RSA__c=fOrderCon.id,
                                                                Type__c= 'Charged', PlantingDensity__c= '30000', Consigned__c=true,
                                                                ProductRef__c= prS2.id);
                                                                
        CampaignLineItem__c cliTax = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                                              DistributorRef__c=provider.id, Agreed__c=35, CatalogType_RSA__c = 'Tax',
                                                              PoG__c=30, ProductCatalogEntryRef__c= pceT.id, GlobalStock_RSA__c=sto2.id,
                                                              OwnerID=salesRep.id, FarmRef__c= farm.id, CampaignRef__c= caYearSR.id,
                                                              PreliminaryOrderRef_RSA__c=pOrderTax.id, FinalOrderRef_RSA__c=fOrderTax.id,
                                                              Type__c= 'Charged', PlantingDensity__c= '30000', ProductRef__c= prT.id);
        
        list<CampaignLineItem__c> cliSalesList=  new list<CampaignLineItem__c>{cliSales, cliSales,cliSales2}; 
        list<CampaignLineItem__c> cliTaxList=  new list<CampaignLineItem__c>{cliTax, cliTax}; 
        list<CampaignLineItem__c> cliConList=  new list<CampaignLineItem__c>{cliCon, cliCon, cliCon2}; 
        
        List<REST_OrderObject> orders = new List<REST_OrderObject>();
        for(Order__c o: orderList){
          REST_OrderObject roo = new REST_OrderObject();
          roo.order=o;
          orders.add(roo);
        }
        List<REST_CampaignLineItemObject> campaignLineItems = new List<REST_CampaignLineItemObject>();
        for(CampaignLineItem__c cli: cliSalesList){
          REST_CampaignLineItemObject rclio = new REST_CampaignLineItemObject();
          rclio.campaignLineItem=cli;
          rclio.finalOrderIdDevice=1;
          campaignLineItems.add(rclio);
        } 
        for(CampaignLineItem__c cli: cliTaxList){
          REST_CampaignLineItemObject rclio = new REST_CampaignLineItemObject();
          rclio.campaignLineItem=cli;
          rclio.finalOrderIdDevice=2;
          campaignLineItems.add(rclio);
        }         
        for(CampaignLineItem__c cli: cliConList){
          REST_CampaignLineItemObject rclio = new REST_CampaignLineItemObject();
          rclio.campaignLineItem=cli;
          rclio.finalOrderIdDevice=3;
          campaignLineItems.add(rclio);
        }         
        REST_SendLogicalEntityOrder paramInfo= new REST_SendLogicalEntityOrder();
        paramInfo.campaignLineItems= campaignLineItems;
        paramInfo.orders=orders;  
    salesRep=[SELECT Id,Manager.ManagerId, Name, Alias, Email, ManagerID,LastName, ProfileId, UserRoleID ,UserName, Manager.Name, UserRole.Name, Manager.Email FROM User WHERE Alias='SAREPA'];                    
    Util.currentUser=salesRep;          
        UtilREST.stockErrorMessages(paramInfo); 
        Test.stopTest();         
  }             
}