@IsTest
public with sharing class REST_LogicalEntityEastTest_I{
    public static List<Account> accounts;
    public static List<Product2> pList;
    public static List<ProductCatalogEntry__c> pce2insert;
    public static  List<TerritoryManagement__c> ter;
    public static List<Acreage__c> acreages;

    public static testMethod void testAccount(){
        REST_Request req = new REST_Request();
        DateTime now = background(4);
        req.pagetimestamp= now;
        req.lastId = ''; 
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/AccountEast_2/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityAccountEast.REST_LogicalEntity_Account res = REST_LogicalEntityAccountEast.getAccounts(req);
        
            System.assertEquals(res.Accounts.size(), accounts.size());
         Test.stopTest();        
    }
    public static testMethod void testAccountDynamic(){
        REST_Request req = new REST_Request();
        DateTime now = background(4);
        req.pagetimestamp= now;
        req.lastId = ''; 
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/AccountDynamic/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityAccountDynamic.REST_LogicalEntity_Account res = REST_LogicalEntityAccountDynamic.getAccounts(req);
        
         Test.stopTest();
        
    }
    public static testMethod void testTerritory(){
        REST_Request req = new REST_Request();
        DateTime now = background(4);
        req.pagetimestamp= now;
        req.lastId = '';
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/TerritoryManagement_2/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityTerritoryManagement.REST_LogicalEntity_Territory res = REST_LogicalEntityTerritoryManagement.getTerritories(req);
        
            System.assertEquals(res.territories.size(), 0);
         Test.stopTest();
        
    }
    public static testMethod void testAcreage(){
        REST_Request req = new REST_Request();
        DateTime now = background(4);
        req.pagetimestamp= now;
        req.lastId = '0';
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/Acreages_2/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityAcreagesEast.REST_LogicalEntity_Acreage res = REST_LogicalEntityAcreagesEast.getAcreages(req);
        
            System.assertEquals(res.Acreages.size(), acreages.size());
         Test.stopTest();
        
    }
    
    
    private static DateTime backGround(Integer max){
        DateTime now = System.now().addDays(-1);
        Integer regPerEntity =max;
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
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1)); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1),
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
       
       
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
        
        ter = new List<TerritoryManagement__c>();
         for(Integer i=0;i<regPerEntity;i++){
                TerritoryManagement__c t = new TerritoryManagement__c(DE_CountryRef__c= c.Id, DE_StateProvince__c='Test'+String.valueOf(i), DE_LandKreis__c='Test'+String.valueOf(i), 
                DE_Landkreis2__c='Test'+String.valueOf(i), DE_CP__c='Test'+String.valueOf(i), DE_Ort__c='Test'+String.valueOf(i), Name=+String.valueOf(i));
                 
         ter.add(t);}
                
        insert ter;        
        
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        accounts = new List<Account>{farm, provider};
        
        List<Account> aList = new List<Account>();  
            for(Integer i=0;i<regPerEntity;i++){
                String AccountName='Account Test '+String.valueof(i);
                Account Acc = new Account(CountryRef__c=c.Id, Name=AccountName, GC_VATIN_Number__c='5', Category__c='Farm', IdDevice__c=(800+i), 
                                          RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),DE_Territory_Key__c=ter.get(i).Id); 
                aList.add(Acc);}
                
        accounts.addAll(aList);        
            insert accounts;
            
        List<Contact> ConList = new List<Contact>();
            for(integer i=0;i<regPerEntity;i++){
                Contact con= new Contact(LastName='Van '+String.ValueOf(i),CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=aList.get(i).id);
                conList.add(con);}
            insert conList;
        
          List<Touchpoint_Program__c> TPPList	= new List<Touchpoint_Program__c>();
        	for(integer i=0;i<regPerEntity;i++){
            Touchpoint_Program__c tpp = new Touchpoint_Program__c(LKP_ACCOUNT__c= aList.get(i).id, LKP_YEAR__c=year.Id,LKP_CROP__c=divi.id,CHK_AGREED__c=true,CHK_PLAN__c=true,DAT_PLAN__c=system.today());
                TPPList.add(tpp);
        }
            insert TPPList;
            
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.CurrentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TrialPCMRef__c=salesCat.Id
                                       );
        
                     
       
        insert new List<Campaign>{caYear};
        
                   
                Product_Grouping__c pgt = new Product_Grouping__c(name = 'CornSilage', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
        Product_Grouping__c pgg = new Product_Grouping__c(name = 'Corn', RecordtypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
            insert new List<Product_Grouping__c>{pgg,pgt};
            
         RecordType App = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProduct'];
        RecordType Appg = [SELECT Id FROM RecordType WHERE SobjectType = 'Acreage__c' and DeveloperName = 'AcreagesPerProductGroup'];
        
          acreages = new List<Acreage__c>();  
            for(Integer i=0; i<regPerEntity; i++){
                Acreage__c acr=new Acreage__c( AcrFarmRef__c=farm.id, AcrProviderRef__c=Provider.id, AcrTotalAcreages__c=100,
                                    Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, AcrSecondHarvest__c=false,
                                    RecordTypeId=App.Id, idDevice__c=100+i,
                                    AcrYearRef__c=Year.ID, AcrProductGroupRef__c=pgg.id, AcrProductTypeRef__c=pgt.id);
           acreages.add(acr);
            }
            insert acreages;
            return now;
            
            
            
    }
}