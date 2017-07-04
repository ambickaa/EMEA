@IsTest

public with sharing class REST_LogicalEntityEastTest_II {
    public static List<Account> accounts;
    public static List<Product2> pList;
    public static List<ProductCatalogEntry__c> pce2insert;
    public static  List<TerritoryManagement__c> ter;
    public static List<Year__c> years;
    public static List<Division__c> divisions;
    public static List<Country__c> countries;
    public static List<Order__c> poList;
     public static List<CampaignLineItem__c> tList;
     public static List<Order__c> orders;
     
    
    public static testMethod void testProducts(){
        REST_Request req = new REST_Request();
        DateTime now = background(10);
        req.pagetimestamp= now;
        req.lastId = '0';
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/ProductEast_2/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityProductEast.REST_LogicalEntity_Product res = REST_LogicalEntityProductEast.getProducts(req);
        
            System.assertEquals(res.products.size(), pList.size());
            System.assertEquals(res.productCatalogLines.size(), pce2insert.size());
            System.assertEquals(res.productCatalogs.size(), 1);
         Test.stopTest();
        
    }
    public static testMethod void testLookUps(){
        REST_Request req = new REST_Request();
        DateTime now = background(10);
        req.pagetimestamp= now;
        req.lastId = '0';
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/LookupEast_2SM/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           REST_LogicalEntityLookupEastSM.REST_LogicalEntity_Lookup res = REST_LogicalEntityLookupEastSM.getLookups(req);
        
            System.assertEquals(res.years.size(), years.size());
            System.assertEquals(res.divisions.size(), divisions.size());
            System.assertEquals(res.countries.size(), countries.size());
         Test.stopTest();
        
    }
    public static testMethod void testOrder(){
        REST_Request req = new REST_Request();
        DateTime now = background(10);
        req.pagetimestamp= now;
        req.lastId = '0';
        req.mode = 0;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/OrderEast_2/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
           Test.startTest();
           
           
           REST_LogicalEntityOrderEast.REST_LogicalEntity_Order res = REST_LogicalEntityOrderEast.getOrders(req);
        
            System.assertEquals(res.orders.size(), 0);
            System.assertEquals(res.actionPlans.size(), tList.size());
            System.assertEquals(res.campaigns.size(), 1);
         Test.stopTest();
        
    }
    
    
    private static DateTime backGround(Integer max){
        DateTime now = System.now().addDays(-1);
        Integer regPerEntity =max;
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s8 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='0');
        SystemSettings__c s9 = new SystemSettings__c( Name='RSA_MIN_VOLUME_DISCOUNT',Value__C='0');
        SystemSettings__c s10 = new SystemSettings__c( Name='RSA_STEPSIZE_VOLUME_DISCOUNT',Value__C='0.5');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9,s10};
        insert ssList;

         User admin = [select Id from User where Id = :UserInfo.getUserId()];
         User salesRep;
         User regionalManager;
                       
         System.runAs(admin){
              
         UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA' limit 1];
         UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
         Profile rmprofile = [select Id,name from Profile where Name =:'RSA_Regional Manager' limit 1];
         Profile srprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
         String email = String.valueOf(System.now()).replace(' ', '').replace(':','_').replace('-','_');
             
         
         regionalManager =  new User(Alias = 'REMANA', Email=email+'2@rm.com', 
                            EmailEncodingKey='UTF-8', LastName='remana', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = rmprofile.Id, UserRoleID = rmRole.ID,
                            TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName=email +'2@rm.com');
         insert regionalManager;
         
         salesRep =  new User(Alias = 'SAREPA', Email=email+'3@sr.com', ManagerID= regionalManager.Id,
                     EmailEncodingKey='UTF-8', LastName='sarepre', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id,
                     TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAB', UserName=email+'3@sr.com');
         insert salesRep;
        }
        
        years = new List<Year__c>();         
        Year__c lastYear = new Year__c (Name='2015', Current_Year__c=false, CurrentYear_RSA__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1)); 
        years.add(lastYear);    
        Year__c year= new Year__c (Name='2016', Current_Year__c=true, CurrentYear_RSA__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1),
                                   YearPreviousYear__c=lastYear.id);
                                   
        years.add(year);                            
        insert years;
       
        countries = new List<Country__c>();
                               
        Country__c c = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard',LKP_CurrentYear__c = year.id);   
        countries.add(c);   
        insert countries;
        util.currentCountry = c;       
        
        divisions = new List<Division__c>();
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        divisions.add(divi);
        insert divisions;
        
        ter = new List<TerritoryManagement__c>();
         for(Integer i=0;i<regPerEntity;i++){
                TerritoryManagement__c t = new TerritoryManagement__c(DE_CountryRef__c= c.Id, DE_StateProvince__c='Test'+String.valueOf(i), DE_LandKreis__c='Test'+String.valueOf(i), 
                DE_Landkreis2__c='Test'+String.valueOf(i), DE_CP__c='Test'+String.valueOf(i), DE_Ort__c='Test'+String.valueOf(i), Name=+String.valueOf(i));
                 
         ter.add(t);}
                
        insert ter;        
        
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
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
            
            
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat};
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.CurrentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TrialPCMRef__c=salesCat.Id,
                                       CompetitorPCMRef__c = salesCat.Id
                                       );        
                     
       
        insert new List<Campaign>{caYear};

        Product2 pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id);
        Product2 pr2 = new Product2(name='Competitor Product',ProductSAPCode__c = '12444444',DivisionRef__c=Divi.id);
        
        pList= new List<Product2>();
            for(Integer i=0;i<regPerEntity;i++){
               Product2 prod=new Product2(Name='ProductNumber '+String.ValueOf(i),ProductSAPCode__c=String.ValueOf(83741+i),
                    DivisionRef__c=Divi.id);
                pList.add(prod);}
       plist.add(pr1);
       plist.add(pr2); 
        insert pList;
          
                                                          
        ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
        
       pce2insert= new List<ProductCatalogEntry__c> { pce}; 
                
        List<ProductCatalogEntry__c> pceList = new List<ProductCatalogEntry__c>();
            for(Product2 prodx : pList){
                ProductCatalogEntry__c procaten = new ProductCatalogEntry__c(ProductCatalogRef__c=salesCat.id, NewProduct__c=true,
                                                                             Price__c=500, productRef__c=prodx.id);
                pceList.add(procaten);}
        pce2insert.addAll(pceList);
        insert pce2insert;
    
                              
        poList = new List<Order__c>();
            for (integer i=0;i<regPerEntity;i++){
                 Order__c  ord = new Order__c( AccountRef_RSA__c=Farm.id, Status_RSA__c='Closed',
                                     RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), shouldCopy_RSA__c=false,OwnerId=Util.currentUser.ID);     
                 poList.add(ord);}
        insert poList; 
        
        orders = new List<Order__c>();
        for (integer i=0;i<regPerEntity;i++){
                Order__c ord = new Order__c( AccountRef_RSA__c=Farm.id, RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), 
                                    PreliminaryOrderRef_RSA__c=poList.get(i).id, Status_RSA__c='Closed', shouldCopy_RSA__c=false,OwnerId=Util.currentUser.ID); 
                orders.add(ord);
                } 
            insert orders;
       
         tList= new List<CampaignLineItem__c>();
            for(Integer i=0; i<regPerEntity; i++){
                CampaignLineItem__c cli=new CampaignLineItem__c(CampaignRef__c=caYear.id, 
                                             OwnerId=Util.currentUser.ID,DistributorRef__c=Provider.id, 
                                             FarmRef__c=farm.id, ProductRef__c=pList.get(i).id, 
                                             Yield__c=400+i, ProductCatalogEntryRef__c=pceList.get(i).id, 
                                             RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales')); 
                tList.add(cli);}
            insert tList;
            
            SM_Campaign__c seedsmanca = new SM_Campaign__c(name = 'seedsman campaign', LKP_Year__c=year.id, LKP_Country__c=c.id, 
                               LKP_Division__c = divi.id, LKP_Catalog__c=salesCat.id); 

            insert new List<SM_Campaign__c>{seedsmanca}; 
             
            return now;
            
            
            
    }
}