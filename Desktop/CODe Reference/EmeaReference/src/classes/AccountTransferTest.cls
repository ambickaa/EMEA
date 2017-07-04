@IsTest
public with sharing class AccountTransferTest {
    
    private static List<searchCriteria> criteriaLine = New List<searchCriteria>();
    private static List<SelectOption> cacheFieldSelectValues = new List<SelectOption>();
    public static List<Voucher__c> List_Vouchers;
    private static User user1;
    private static User user2;
    static Account acc1;
    static Account acc2;
    static Country__c country1;
    
    public static void init(){
        // COUNTRY //
        country1 = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');
        insert new List<Country__c>{country1};
        
        User currentUser = [SELECT Id, Name, Country FROM User WHERE Id =: UserInfo.getUserId()];
        currentUser.Country = 'Ukraine';
        update currentUser;

        // USERS //
        Profile p = [SELECT Id FROM Profile WHERE Name='UA_Sales Representative'];
        user1= new User (Username=' user1@test.fullbox.com', FirstName = 'user1', LastName='user1',Email='user1@monsanto.com.fullbox', Alias='US1',Country='Ukraine',CountryISOCode__c='UA', CommunityNickname='test1',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US', ProfileId = p.Id, EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US');
        user2= new User (Username=' user2@test.fullbox.com', FirstName = 'user1', LastName='user2', Email='user2@monsanto.com.fullbox', Alias='US2',Country='Ukraine',CountryISOCode__c='UA', CommunityNickname='test2',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US', ProfileId = p.Id, EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US'); 
        insert new List<User>{user1,user2};
            
        //ACCOUNTS //
        acc1 = new Account(RecordTypeId=Util.recordType.get('Account:DistRetPoS'), Name='Account1',CountryID__c = country1.id, OwnerId= user1.Id,CountryRef__c = country1.id, Description = 'Test', Data_privacy_agreement__c = true, City__c = 'Kiev', Category__c = 'Farm' );
        acc2 = new Account(RecordTypeId=Util.recordType.get('Account:DistRetPoS'), Name='Account2',CountryID__c = country1.id, OwnerId= user1.Id, CountryRef__c = country1.id, Description = 'Test',Data_privacy_agreement__c = true, City__c = 'Kiev', Category__c = 'Farm' );
        insert new List<Account> {acc1,acc2};    
    }
    // general situation without vouchers with dotransfer()
    public static testmethod void method1(){
        init();

        // PRODUCT GROUPING //
        Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn', RecordTypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
        insert new List<Product_Grouping__c> {CornGroup};
    
        // YEARS//
        Year__c year2 = new Year__c(Name='2015',Current_Year__c=false,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearPreviousYear__c = year2.id, YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1));
        insert year1;
        
        // ACREAGES //
        Acreage__c acr1 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'),OwnerId= user1.Id, AcrFarmRef__c=acc1.Id, AcrYearRef__c=year1.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=CornGroup.Id, AcrProductTypeRef__c=CornGroup.Id);
        Acreage__c acr2 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'),OwnerId= user1.Id, AcrFarmRef__c=acc2.Id, AcrYearRef__c=year1.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=CornGroup.Id, AcrProductTypeRef__c=CornGroup.Id);
        insert new List<Acreage__c> {acr1,acr2};

        // DIVISION //
        Division__c division1 = new Division__c(Name='Corn');
        Division__c division2 = new Division__c(Name='OSR');
        Division__c division3 = new Division__c(Name='CP');
        insert new List<Division__c>{division1,division2,division3};
          
        // PRODUCT CATALOG //
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        ProductCatalog__c TrialsProductCatalog = new ProductCatalog__c(Name='Trials Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        insert new List<ProductCatalog__c> {SalesProductCatalog,TrialsProductCatalog};
     
        // CAMPAIGNS //
        Campaign campaignyear2 = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division1.Id);              
        Campaign campaignyear1 = new Campaign(YearV2__c=year1.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year1.YearStartDate__c,EndDate=year1.YearEndDate__c,ArchiveDate__c = date.newinstance(2016,2,4),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id,DivisionRef__c=division1.Id);              
        Campaign OSRCampaign = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division2.Id);              
        Campaign CPCampaign = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division3.Id);              
        Campaign NPSCampaign = new Campaign(YearV2__c = year1.Id, CountryRef__c=country1.Id, Name = 'testCampaign');
        insert new List<Campaign>{campaignyear2,campaignyear1,OSRCampaign,NPSCampaign,CPCampaign};      
        
        // CONTACTS // 
        Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', OwnerId =user1.Id, AccountId=acc1.Id, Phone=null, MobilePhone='987002765');
        Contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', OwnerId =user1.Id, AccountId=acc2.Id, Phone=null, MobilePhone='987002765');
        insert new List<Contact>{contact1,contact2}; 
        
        // PRODUCTS //
        Product2 pr1 = new Product2(Name='DKC Test',ProductSAPCode__c='12123213',DivisionRef__c=division1.id, productVendor__c=acc1.Id);
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=acc2.Id);
        insert new List<Product2> {pr1,pr2};
        
        // PRODUCT CATALOG ENTRY //
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user1.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c(ProductCatalogRef__c=TrialsProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user1.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert new List<ProductCatalogEntry__c>{pce1,pce2};
            
        // CAMPAIGN LINE ITEM GROUP //
        CampaignLineItemGroup__c group1 = new CampaignLineItemGroup__c(AccountRef__c = acc1.id, CampaignRef__c = campaignyear2.id, OwnerId = user1.id);
        CampaignLineItemGroup__c group2 = new CampaignLineItemGroup__c(AccountRef__c = acc2.id, CampaignRef__c = campaignyear1.id, OwnerId = user1.id); 
        insert new List<CampaignLineItemGroup__c>{group1,group2};
            
        // CAMPAIGN LINE ITEMS //
        CampaignLineItem__c cli1 = new CampaignLineItem__c( CampaignLineItemGroupRef__c = group1.id, RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),PoG__c=100,Agreed__c=650,ProductCatalogEntryRef__c=pce2.Id,OwnerId=user1.Id,FarmRef__c=acc1.Id,CampaignRef__c=CPCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr1.Id);
        CampaignLineItem__c cli2 = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=300,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user1.Id,FarmRef__c=acc1.Id,CampaignRef__c=campaignyear2.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli3 = new CampaignLineItem__c( CampaignLineItemGroupRef__c = group2.id, RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),PoG__c=100,Agreed__c=650,ProductCatalogEntryRef__c=pce2.Id,OwnerId=user1.Id,FarmRef__c=acc2.Id,CampaignRef__c=campaignyear1.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        CampaignLineItem__c cli4 = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=650,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user1.Id,FarmRef__c=acc1.Id,CampaignRef__c=OSRCampaign.Id,Type__c='Free of charge',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        insert new List<CampaignLineItem__c>{cli2,cli3,cli4,cli1};
            
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        acc1 = cont.gettoUserLookup();
        acc1.OwnerId = user2.Id;
        acc2 = cont.getfromUserLookup();
        acc2.OwnerId = user1.Id;
            
        // To user //
        cont.toUserID = user2.id;
        // From user //
        cont.fromUserID = user1.id;
        
        ////////////////////////
        // methods to increase coverage //            
        criteriaLine = cont.getsearchCriteria();
        cacheFieldSelectValues = cont.getsearchFields();
        cont.getInputDateFormat();
        cont.getSetDebugModeTRUE();
        cont.getSetDebugModeFALSE();
        cont.gettoUserLookup();
        cont.getfromUserLookup();
        cont.setSetDebugModeTRUE(true);
        cont.setSetDebugModeFALSE(true);
        ////////////////////////
        
        cont.doSearch();
        List<AccountTransfer.transferAccountSearchResults> tasr = new List<AccountTransfer.transferAccountSearchResults>();
        tasr = cont.getSearchResults();
        System.debug('************tasr value: ' + tasr);
        // we have two elements: acc1 and acc2, now are not selected //
        // we need to select one of them //
        AccountTransfer.transferAccountSearchResults acc3 = new AccountTransfer.transferAccountSearchResults();
        // this would be acc1 //
        acc3 = tasr.get(0);
        acc3.setselected(true);
        
        cont.optSendeMailToOwner= true;
        // we would allow to transfer vouchers and trials //
        cont.transferVouchers = true;
        cont.transferTrials = true;
        
        cont.doTransfer();
        cont.doTransferAll();
       
        cont.getShowBlockIfResults();
        cont.next();
        cont.previous(); 
        Test.stopTest();
    }
    
    // no TOUser assigned //
    public static testmethod void method2(){
        init();
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        // we assign a valid fromUser //
        cont.fromUserID = user1.id;
        // we wouldn't have a valid toUser //
        cont.toUserID = '';
        cont.doSearch();
        cont.doTransfer();
        cont.doTransferAll();
        Test.stopTest();
    }
     // no FROMUser assigned //
    public static testmethod void method3(){
        init();
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        // we asssign a toUser //
        cont.toUserID = user1.id;
        // we wouldn't have a valid FromUser //
        // this should return null //
        cont.doSearch();
        Test.stopTest();
    }
    
    // NPS Cases method //
    public static testmethod void method4(){
        init();
        // YEARS//
        Year__c year2 = new Year__c(Name='2015',Current_Year__c=false,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearPreviousYear__c = year2.id, YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1));
        insert year1;    
        
        // CONTACTS // 
        Contact contact1 = new Contact(FirstName='TEST', LastName='TEST1', OwnerId =user1.Id, AccountId=acc1.Id, Phone=null, MobilePhone='987002765');
        Contact contact2 = new Contact(FirstName='TEST', LastName='TEST2', OwnerId =user1.Id, AccountId=acc2.Id, Phone=null, MobilePhone='987002765');
        insert new List<Contact>{contact1,contact2}; 
        
        // NPS CAMPAIGN //
        Campaign NPSCampaign = new Campaign(YearV2__c = year1.Id, CountryRef__c=country1.Id, Name = 'testCampaign');
        insert NPSCampaign;  
            
        //NPS CASES //
        String recordtype = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Survey Result').getRecordTypeId();
        Case cs1 = new Case(Subject='Test Case',OwnerId = user1.id, RecordTypeId=recordtype,ContactId=contact2.Id,AccountId=acc2.Id,NPS_RESULT_Q4__c='Yes', NPS_CAMPAIGN__c = NPSCampaign.Id);
        Case cs2 = new Case(Subject='Test Case',OwnerId = user1.id, RecordTypeId=recordtype,ContactId=contact1.Id,AccountId=acc1.Id,NPS_RESULT_Q4__c='Yes', NPS_CAMPAIGN__c = NPSCampaign.Id);
        insert new List<Case>{cs1,cs2}; 
        
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        acc1 = cont.gettoUserLookup();
        acc1.OwnerId = user2.Id;
        
        acc2 = cont.getfromUserLookup();
        acc2.OwnerId = user1.Id;
        
               
        // we assign a valid toUser //
        cont.toUserID = user2.id;
        // we assign a valid fromUser //
        cont.fromUserID = user1.id;

        cont.doSearch();
        List<AccountTransfer.transferAccountSearchResults> tasr = new List<AccountTransfer.transferAccountSearchResults>();
        tasr = cont.getSearchResults();
        System.debug('************tasr value: ' + tasr);
        // we have two elements: acc1 and acc2, now are not selected //
        // we need to select one element of the list //
        AccountTransfer.transferAccountSearchResults acc3 = new AccountTransfer.transferAccountSearchResults();
        // this would be acc1 //
        acc3 = tasr.get(0);
        acc3.setselected(true);
        // we change the boolean value //
        cont.transferCases = true;
        cont.doTransfer();
        cont.doTransferAll();
        Test.stopTest();
    }

    public static testmethod void method5(){
        init();

        // YEARS//
        Year__c year2 = new Year__c(Name='2015',Current_Year__c=false,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearPreviousYear__c = year2.id, YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1));
        insert year1;
        
        // DIVISION //
        Division__c division1 = new Division__c(Name='Corn');
        insert division1;
        
        // PRODUCT CATALOG //
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        ProductCatalog__c TrialsProductCatalog = new ProductCatalog__c(Name='Trials Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        insert new List<ProductCatalog__c> {SalesProductCatalog,TrialsProductCatalog};    
        
        // PRODUCTS //
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=acc2.Id);
        insert pr2;
        
        // CAMPAIGNS //
        Campaign campaignyear2 = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user2.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division1.Id);              
        insert campaignyear2;    

        // PRODUCT CATALOG ENTRY //
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user1.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert pce1;
 
        // CAMPAIGN LINE ITEMS //
        CampaignLineItem__c cli2 = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=300,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user2.Id,FarmRef__c=acc1.Id,CampaignRef__c=campaignyear2.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        insert cli2;  
 
        // VOUCHER CAMPAIGN //
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(Name='Test', Discount_Type__c = 'In Bags',YearRef__c=year1.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country1.Id,EndDate__c=year1.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year1.YearStartDate__c);
        insert voucherCampaign;
        
        // VOUCHERS // 
        Voucher__c voucherA = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc2.Id, CampaignRef__c=campaignyear2.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 10,TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234');
        Voucher__c voucherB = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc1.Id, CampaignRef__c=campaignyear2.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 100, TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null);
        insert new List<Voucher__c>{voucherA,voucherB};  
        
        // VOUCHER LINE ITEMS //    
        /*VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        //insert new List<VoucherLineItem__c>{vli1,vli2}; */
        
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        acc1 = cont.gettoUserLookup();
        acc1.OwnerId = user2.Id;
        
        acc2 = cont.getfromUserLookup();
        acc2.OwnerId = user1.Id;
        
               
        // we assign a valid toUser //
        cont.toUserID = user2.id;
        // we assign a valid fromUser //
        cont.fromUserID = user1.id;
            
        cont.doSearch();
        List<AccountTransfer.transferAccountSearchResults> tasr = new List<AccountTransfer.transferAccountSearchResults>();
        tasr = cont.getSearchResults();
        System.debug('************tasr value: ' + tasr);
        // we have two elements: acc1 and acc2, which are not selected //
        // we need to select at least one of them //
        AccountTransfer.transferAccountSearchResults acc3 = new AccountTransfer.transferAccountSearchResults();
        // this would be acc1 //
        acc3 = tasr.get(0);
        // set boolean to true // 
        acc3.setselected(true);
        cont.optSendeMailToOwner= true;
        cont.transferVouchers = true;
        cont.doTransferAll();
        Test.stopTest();
    }
    public static testmethod void method6(){
        init();

        // YEARS//
        Year__c year2 = new Year__c(Name='2015',Current_Year__c=false,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearPreviousYear__c = year2.id, YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1));
        insert year1;
        
        // DIVISION //
        Division__c division1 = new Division__c(Name='Corn');
        Division__c division2 = new Division__c(Name='OSR');
        insert new List<Division__c>{division1,division2};  
        
        // PRODUCT CATALOG //
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        ProductCatalog__c TrialsProductCatalog = new ProductCatalog__c(Name='Trials Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        insert new List<ProductCatalog__c> {SalesProductCatalog,TrialsProductCatalog};    
        
        // PRODUCTS //
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=acc2.Id);
        insert pr2;
        
        // CAMPAIGNS //
        Campaign campaignyear2 = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division1.Id);                            
        Campaign OSRCampaign = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division2.Id);
        insert new List<Campaign>{campaignyear2,OSRCampaign};    

        // PRODUCT CATALOG ENTRY //
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user1.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert pce1;
 
        // CAMPAIGN LINE ITEMS //
        CampaignLineItem__c cli2 = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),PoG__c=100,Agreed__c=300,ProductCatalogEntryRef__c=pce1.Id,OwnerId=user1.Id,FarmRef__c=acc1.Id,CampaignRef__c=campaignyear2.Id,Type__c='Charged',PlantingDensity__c='30000',ProductRef__c=pr2.Id);
        insert cli2;  
 
        // VOUCHER CAMPAIGN //
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(Name='Test', Discount_Type__c = 'In Bags',YearRef__c=year1.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country1.Id,EndDate__c=year1.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year1.YearStartDate__c);
        insert voucherCampaign;
        
        // VOUCHERS //
        Voucher__c voucherA = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc2.Id, CampaignRef__c=campaignyear2.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 10,TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234');
        Voucher__c voucherB = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc1.Id, CampaignRef__c= OSRCampaign.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 100, TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null);
        insert new List<Voucher__c>{voucherA,voucherB};  
        
        // VOUCHER LINE ITEMS //    
        /*VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        //insert new List<VoucherLineItem__c>{vli1,vli2}; */
        
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        acc1 = cont.gettoUserLookup();
        acc1.OwnerId = user2.Id;
        
        acc2 = cont.getfromUserLookup();
        acc2.OwnerId = user1.Id;
        
               
        // we assign a valid toUser //
        cont.toUserID = user2.id;
        // we assign a valid fromUser //
        cont.fromUserID = user1.id;
 
        cont.doSearch();
        List<AccountTransfer.transferAccountSearchResults> tasr = new List<AccountTransfer.transferAccountSearchResults>();
        tasr = cont.getSearchResults();
        System.debug('************tasr value: ' + tasr);
        // we have two elements: acc1 and acc2, which are not selected //
        // we need to select one //
        AccountTransfer.transferAccountSearchResults acc3 = new AccountTransfer.transferAccountSearchResults();
        // this would be acc1 //
        acc3 = tasr.get(0);
        acc3.setselected(true);
        
        cont.optSendeMailToOwner= true;
        cont.transferVouchers = true;
        cont.transferTrials = true;
        cont.transferCases = true;
        cont.doTransfer();
        cont.doTransferAll();
        
        // methods to increase coverage //
        boolean a = cont.hasPrevious;
        a = cont.hasNext;
        Integer pageNumber = cont.pageNumber;
        // object creation of the inner class inside AccountTransfer //
        AccountTransfer.transferAccountSearchResults accountTrans = new AccountTransfer.transferAccountSearchResults();
        accountTrans.setaccount(acc1);
        //String dateAccount = accountTrans.getCreatedDate();
        //String dateModifyAccount = accountTrans.getLastModifiedDate();
        boolean selected = accountTrans.getselected();
        Account b = accountTrans.getaccount();
        //////////////
        Test.stopTest();
    }
    
    public static testmethod void method7(){
        init();

        // YEARS//
        Year__c year2 = new Year__c(Name='2015',Current_Year__c=false,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
        insert year2;
        Year__c year1 = new Year__c(Name='2016',Current_Year__c=true,YearPreviousYear__c = year2.id, YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2016,1,1));
        insert year1;
        
        // DIVISION //
        Division__c division1 = new Division__c(Name='Corn');
        Division__c division2 = new Division__c(Name='OSR');
        insert new List<Division__c>{division1,division2};  
        
        // PRODUCT CATALOG //
        ProductCatalog__c SalesProductCatalog = new ProductCatalog__c(Name='Product Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        ProductCatalog__c TrialsProductCatalog = new ProductCatalog__c(Name='Trials Catalog',CountryRef__c=country1.Id,RecordTypeId='012D000000035BEIAY');
        insert new List<ProductCatalog__c> {SalesProductCatalog,TrialsProductCatalog};    
        
        // PRODUCTS //
        Product2 pr2 = new Product2(Name='DKC Test',ProductSAPCode__c='12444444',DivisionRef__c=division1.id, productVendor__c=acc2.Id);
        insert pr2;
        
        // CAMPAIGNS //
        Campaign campaignyear2 = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division1.Id);                            
        Campaign OSRCampaign = new Campaign(YearV2__c=year2.Id,CountryRef__c=country1.Id, OwnerId=user1.Id,StartDate=year2.YearStartDate__c,EndDate=year2.YearEndDate__c,ArchiveDate__c = date.newinstance(2015,3,2),Statuscode__c=200,SalesPCMRef__c=SalesProductCatalog.Id,TrialPCMREf__c=TrialsProductCatalog.Id, DivisionRef__c=division2.Id);
        insert new List<Campaign>{campaignyear2,OSRCampaign};    

        // PRODUCT CATALOG ENTRY //
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c(ProductCatalogRef__c=SalesProductCatalog.Id,NewProduct__c=true,Price__c=500,ProductRef__c=pr2.Id,OwnerId=user1.Id,isFOCallowed__c=true,VoucherProduct__c=true);
        insert pce1;
  
        // VOUCHER CAMPAIGN //
        VoucherCampaign__c voucherCampaign = new VoucherCampaign__c(Name='Test', Discount_Type__c = 'In Bags',YearRef__c=year1.Id,DivisionRef__c=division1.Id,BagSize__c=50,CountryRef__c=country1.Id,EndDate__c=year1.YearEndDate__c,MinProducts__c=0,MinTotalBags__c=0,StartDate__c=year1.YearStartDate__c);
        insert voucherCampaign;
        
        // VOUCHERS //
        Voucher__c voucherA = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc2.Id, CampaignRef__c=campaignyear2.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 10,TotalBags__c=50, Status__c='Cancelled', PhoneCopy__c='987110234');
        Voucher__c voucherB = new Voucher__c(OwnerId=user1.Id,AccountRef__c=acc1.Id, CampaignRef__c= OSRCampaign.Id, VoucherCampaignRef__c=voucherCampaign.Id, FarmNameCopy__c='TEST1', AddressCopy__c='TEST', EmailCopy__c='test@test.farm', DistributorNameCopy__c='TEST', TotalBagsFOC__c = 100, TotalBags__c=10, Status__c='Closed', PhoneCopy__c=null);
        insert new List<Voucher__c>{voucherA,voucherB};  
        
        // VOUCHER LINE ITEMS //    
        /*VoucherLineItem__c vli1 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherA.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 1',ProductName__c='DKC TEST 1',PICK_TYPE__c='Charged');
        VoucherLineItem__c vli2 = new VoucherLineItem__c(CampaignLineItemRef__c=cli2.Id,VoucherRef__c=voucherB.Id,Agreed__c=50,Bags__c=50,HybridName__c='DKC TEST 2',ProductName__c='DKC TEST 2',PICK_TYPE__c='Charged');
        //insert new List<VoucherLineItem__c>{vli1,vli2}; */
        
        Test.startTest();
        AccountTransfer cont = new AccountTransfer();
        acc1 = cont.gettoUserLookup();
        acc1.OwnerId = user2.Id;
        
        acc2 = cont.getfromUserLookup();
        acc2.OwnerId = user1.Id;
        
               
        // we assign a valid toUser //
        cont.toUserID = user2.id;
        // we assign a valid fromUser //
        cont.fromUserID = user1.id;
 
        cont.doSearch();
        List<AccountTransfer.transferAccountSearchResults> tasr = new List<AccountTransfer.transferAccountSearchResults>();
        tasr = cont.getSearchResults();
        System.debug('************tasr value: ' + tasr);
        // we have two elements: acc1 and acc2, which are not selected //
        // we need to select one //
        AccountTransfer.transferAccountSearchResults acc3 = new AccountTransfer.transferAccountSearchResults();
        // this would be acc1 //
        acc3 = tasr.get(0);
        acc3.setselected(true);
        
        cont.optSendeMailToOwner= true;
        cont.transferVouchers = true;
        cont.transferTrials = true;
        cont.transferCases = true;
        cont.doTransferAll();
        
        // methods to increase coverage //
        boolean a = cont.hasPrevious;
        a = cont.hasNext;
        Integer pageNumber = cont.pageNumber;
        // object creation of the inner class inside AccountTransfer //
        AccountTransfer.transferAccountSearchResults accountTrans = new AccountTransfer.transferAccountSearchResults();
        accountTrans.setaccount(acc1);
        //String dateAccount = accountTrans.getCreatedDate();
        //String dateModifyAccount = accountTrans.getLastModifiedDate();
        boolean selected = accountTrans.getselected();
        Account b = accountTrans.getaccount();
        //////////////
        Test.stopTest();
    } 
}