@Istest
public with sharing class Test_LogicalEntityOrderController2 {
    private static testmethod void testGetOrderOneIteration(){
        DateTime now = System.now().addDays(-1);
        Integer regPerEntity =100;
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                               
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        Profile pSR = [SELECT Id FROM Profile WHERE Name='RSA_Sales Representative'];
        
        Profile pRM = [SELECT Id FROM Profile WHERE Name='RSA_Regional Manager'];
        
        
       
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        List<Account> accounts = new List<Account>{farm, provider};
        
        List<Account> aList = new List<Account>();  
            for(Integer i=0;i<52;i++){
                String AccountName='Account Test '+String.valueof(i);
                Account Acc = new Account(CountryRef__c=c.Id, Name=AccountName, GC_VATIN_Number__c='5', Category__c='Farm', IdDevice__c=(800+i), 
                                          RecordTypeId=Util.recordType.get('Account:GroupFarmSite')); 
                aList.add(Acc);}
                
        accounts.addAll(aList);        
            insert accounts;
            
        List<Contact> ConList = new List<Contact>();
            for(integer i=0;i<50;i++){
                Contact con= new Contact(LastName='Van '+String.ValueOf(i),CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=aList.get(i).id);
                conList.add(con);}
            insert conList;
            
            
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        RecordType taC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'TrialsProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=Util.CurrentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=salesCat.id);
        
                     
       
        insert new List<Campaign>{caYear};
        
        Product2 pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id);
        Product2 pr2 = new Product2(name='Competitor Product',ProductSAPCode__c = '12444444',DivisionRef__c=Divi.id);
        
        List<Product2> pList= new List<Product2>();
            for(Integer i=0;i<regPerEntity;i++){
               Product2 prod=new Product2(Name='ProductNumber '+String.ValueOf(i),ProductSAPCode__c=String.ValueOf(83741+i),
                    DivisionRef__c=Divi.id);
                pList.add(prod);}
       plist.add(pr1);
       plist.add(pr2); 
        insert pList;
          
                                                          
        ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
        
        List<ProductCatalogEntry__c> pce2insert= new List<ProductCatalogEntry__c> { pce}; 
                
        List<ProductCatalogEntry__c> pceList = new List<ProductCatalogEntry__c>();
            for(Product2 prodx : pList){
                ProductCatalogEntry__c procaten = new ProductCatalogEntry__c(ProductCatalogRef__c=salesCat.id, NewProduct__c=true,
                                                                             Price__c=500, productRef__c=prodx.id);
                pceList.add(procaten);}
        pce2insert.addAll(pceList);
        insert pce2insert;
    
        
        
        
        
       
        List<Order__c> poList = new List<Order__c>();
            for (integer i=0;i<regPerEntity;i++){
                 Order__c  ord = new Order__c( AccountRef_RSA__c=Farm.id, Status_RSA__c='Closed',
                                     RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), shouldCopy_RSA__c=false,OwnerId=Util.currentUser.ID);     
                 poList.add(ord);}
        insert poList; 
        
        List<Order__c> orders = new List<Order__c>();
        for (integer i=0;i<regPerEntity;i++){
                Order__c ord = new Order__c( AccountRef_RSA__c=Farm.id, RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), 
                                    PreliminaryOrderRef_RSA__c=poList.get(i).id, Status_RSA__c='Closed', shouldCopy_RSA__c=false,OwnerId=Util.currentUser.ID); 
                orders.add(ord);
                } 
            insert orders;
       
         List<CampaignLineItem__c> tList= new List<CampaignLineItem__c>();
            for(Integer i=0; i<regPerEntity; i++){
                CampaignLineItem__c cli=new CampaignLineItem__c(CampaignRef__c=caYear.id, 
                                             OwnerId=Util.currentUser.ID,DistributorRef__c=Provider.id, 
                                             FarmRef__c=farm.id, ProductRef__c=pList.get(i).id, 
                                             Yield__c=400+i, ProductCatalogEntryRef__c=pceList.get(i).id, 
                                             RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial')); 
                tList.add(cli);}
            insert tList;

        
        
        REST_Request req = new REST_Request();
        req.pagetimestamp= now;
        req.lastId = '0';
        req.mode = 1;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/Order_5/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;

        Test.startTest();
        REST_LogicalEntityOrderController2.REST_LogicalEntity_Order res = new REST_LogicalEntityOrderController2.REST_LogicalEntity_Order();
        res = REST_LogicalEntityOrderController2.getOrders(req);
        System.assertEquals(res.orders.size(),orders.size()+poList.size());
        System.assertEquals(res.actionPlans.size(),tList.size());
        System.assertEquals(res.campaigns.get(0).id,caYear.Id);
        Test.stopTest();
    }
}