@IsTest
public with sharing class Test_TriggerHybridPK {
    
    public static Account Farm;
    public static Contact con;
    public static ProductCatalogEntry__c pce;
    public static Product2 pr1;
    public static Account provider;
    public static Campaign caYear;
    public static CampaignLineItem__c cli1;
    public static Hybrid__c hyb;
    private static testmethod void testHybridPK(){
        backGround(100);
        hyb.Name='FHE ERT';
        String lastPK = hyb.PK__c;
        update hyb;
        System.assertEquals(hyb.PK__c, lastPK);
        System.assertEquals(hyb.UserRef__c,hyb.OwnerId);
    }
    private static void backGround(Integer max){
        
        Integer regPerEntity =max;
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        SystemSettings__c s8 = new SystemSettings__c( Name='RSA_STOCK_MAILS',Value__C='false');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7,s8};
        insert ssList;
                               
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1914, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        Profile pSR = [SELECT Id FROM Profile WHERE Name='RSA_Sales Representative'];
        
        Profile pRM = [SELECT Id FROM Profile WHERE Name='RSA_Regional Manager'];
        Profile pCL = [SELECT Id FROM Profile WHERE Name='RSA_Country Lead'];
        
         User uRM = new User(Alias = 'RManager', Email='sugfhser@test.com', 
                                EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = pRM.Id, 
                                TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='usersadasdas@test.com');
        insert uRM;
        
      Util.currentUser.ProfileId = pSR.Id;
        
       Util.currentUser.ManagerId = uRM.Id;
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        
        provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        List<Account> accounts = new List<Account>{farm, provider};
        
                
            insert accounts;
          con= new Contact(LastName='Van Test',CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=farm.id);  
        insert con;
        
            farm.Buyer_RSA__c=con.Id;
            
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id,OwnerId=uRM.Id, DivisionRef__c=divi.Id, YearRef__c=year.Id);
        insert new List<ProductCatalog__c> {salesCat };
        
        caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.CurrentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=salesCat.id);
        
                     
       
        insert new List<Campaign>{caYear};
        
        
            
        
        pr1 = new Product2(Description = 'Hola', Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id);
         
        insert pr1;
              
                                                          
       pce = new ProductCatalogEntry__c ( ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=pr1.id,OwnerId = Util.currentUser.Id);
        
       insert pce;
       hyb = new Hybrid__c(Name='DCK 1522',ProductCatalogRef__c = salesCat.Id,UserRef__c =  Util.currentUser.ManagerId,OwnerId = Util.currentUser.ManagerId);
            insert hyb;
            
          Stock__c stock = new Stock__c(ProductCatalogEntryRef_RSA__c = pce.Id,HybridRef__c = hyb.id, User_RSA__c = Util.currentUser.ManagerId, 
          Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000,Quantity_RSA__c=10000);  
            insert stock;
            
          
            
            
    }

}