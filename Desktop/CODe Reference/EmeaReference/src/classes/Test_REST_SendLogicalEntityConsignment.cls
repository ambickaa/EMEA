@Istest 
public with sharing class Test_REST_SendLogicalEntityConsignment {
  /*public static testMethod void TestSendOrders() {
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
            User admin = [select Id from User where Id = :UserInfo.getUserId()];
            User salesRep;
            User regionalManager;
            User countryLead;
                
            System.runAs(admin){
              
                     UserRole clRole= [SELECT PortalType, PortalAccountId From UserRole where DeveloperName =:'Country_Lead_RSA' limit 1];
                     UserRole rmRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA' limit 1];
                     UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
                     Profile clprofile = [select Id,name from Profile where Name =:'RSA_Country Lead' limit 1];
                     Profile rmprofile = [select Id,name from Profile where Name =:'RSA_Regional Manager' limit 1];
                     Profile srprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
                     String email = String.valueOf(System.now()).replace(' ', '').replace(':','_').replace('-','_');
                     countryLead = new User(Alias = 'COLEAA', Email=email+'1@cl.com', 
                                 EmailEncodingKey='UTF-8', LastName='colead', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = clprofile.Id, UserRoleID = clRole.Id,
                                 TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAC', UserName=email+'1@cl.com');
                     insert countryLead;               
                     
                     regionalManager =  new User(Alias = 'REMANA', Email=email+'2@rm.com',ManagerID= countryLead.Id, 
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
                             OwnerId=salesRep.Id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                           StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
            insert caYear;
    
            
            Product2 prS = new Product2(Name='DCK1234 50M',Description='DCK1234', ProductSAPCode__c = '12123213', DivisionRef__c=divi.id);
        insert prS;  
        ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                          Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                          Ownerid=salesRep.Id);  
        
        ProductCatalogEntry__c pce1 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                          Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                          Ownerid=salesRep.Id);  
        
        ProductCatalogEntry__c pce2 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                          Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                          Ownerid=salesRep.Id);  
        insert new List<ProductCatalogEntry__c>{pce,pce1,pce2};
        
        Hybrid__c hyb = new Hybrid__c(Name='DCK 1522',ProductCatalogRef__c = salesCat.Id,UserRef__c =  regionalManager.Id);
            insert hyb;
                
            Stock__c sto = new Stock__c(ProductCatalogEntryRef_RSA__c = pce.Id, HybridRef__c = hyb.id, User_RSA__c = regionalManager.Id, 
                            Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000,Quantity_RSA__c=10000);  
            Stock__c sto1 = new Stock__c(ProductCatalogEntryRef_RSA__c = pce1.Id, HybridRef__c = hyb.id, User_RSA__c = regionalManager.Id, 
                            Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000,Quantity_RSA__c=10000);  
            
            Stock__c sto2 = new Stock__c(ProductCatalogEntryRef_RSA__c = pce2.Id, HybridRef__c = hyb.id, User_RSA__c = regionalManager.Id, 
                            Allocation_RSA__c=25000, TaxAllocation_RSA__c=250000,Quantity_RSA__c=10000);  
            insert new List<Stock__c>{sto,sto1,sto2};
    
    
        test.StartTest();
      REST_SendLogicalEntityConsignment req = new REST_SendLogicalEntityConsignment();
      REST_SendLogicalEntityConsignment res = new REST_SendLogicalEntityConsignment();
         String jsonCorrect ='{ "statusDescription" : null, "statusCode" : 0, "consignments" : [ { "statusDescription" : null, "statusCode" : 0, "LastModifiedDate" : null, "consignment" : { "attributes" : { "type" : "Consignment__c" }, "Name" : "RSA469", "ProductCatalogEntryRef__c" : "'+pce.Id+'", "idDevice__c" : 12.0, "Status__c" : "Pending", "Requested__c" : 1000.0 }, "action" : "Insert" }, { "statusDescription" : null, "statusCode" : 0, "LastModifiedDate" : null, "consignment" : { "attributes" : { "type" : "Consignment__c" }, "Name" : "RSA719", "ProductCatalogEntryRef__c" : "'+pce1.Id+'", "idDevice__c" : 13.0, "Status__c" : "Pending", "Requested__c" : 1000.0 }, "action" : "Insert" }, { "statusDescription" : null, "statusCode" : 0, "LastModifiedDate" : null, "consignment" : { "attributes" : { "type" : "Consignment__c" }, "Name" : "RSA481", "ProductCatalogEntryRef__c" : "'+pce2.Id+'", "idDevice__c" : 14.0, "Status__c" : "Pending", "Requested__c" : 1000.0 }, "action" : "Insert" } ] }';
          req =(REST_SendLogicalEntityConsignment) JSON.deserialize(jsonCorrect, REST_SendLogicalEntityConsignment.class);
          RestRequest request = new RestRequest();
       RestResponse respons = new RestResponse();
       request.requestURI = '/sendLogicalEntity/Consignment_5/*';  //Request URL
       request.httpMethod = 'POST';//HTTP Request Type
       request.requestBody = Blob.valueof(jsonCorrect);
       RestContext.request = request;
       RestContext.response= respons;
       
         
         /*String jsonRejected ='';
         REST_SendLogicalEntityConsignment logicConsRejected =(REST_SendLogicalEntityConsignment) System.Json.deserialize(jsonRejected, REST_SendLogicalEntityConsignment.class);          
          String jsonError ='';
         REST_SendLogicalEntityConsignment logicConsError = (REST_SendLogicalEntityConsignment)System.Json.deserialize(jsonError, REST_SendLogicalEntityConsignment.class);
         
         
          res = REST_SendLogicalEntityConsignmentContr.sendConsignments(req);
          
         
          for(REST_ConsignmentObject rco : res.consignments) {
            System.assertEquals(rco.statusDescription, res.statusDescription);
            System.assertEquals(res.statusCode, rco.statusCode);
            System.assertEquals('Accepted', rco.consignment.Status__c);
          }
         test.stopTest();
                    
      }*/
  public static testMethod void testSendConsignment() {
       
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='all');
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
        Product2 prS2 = new Product2(Name='DKC 12 Regular',ProductSAPCode__c = '12123212',DivisionRef__c=divi.id, Description='DKC 12');
        Product2 prS3 = new Product2(Name='DKC 123 Regular',ProductSAPCode__c = '12123218',DivisionRef__c=divi.id, Description='DKC 123');
        insert new List<Product2> {prS, prS2, prS3};    
        
        Hybrid__c hyb1=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 1');
        Hybrid__c hyb2=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 12');
        Hybrid__c hyb3=new Hybrid__c(UserRef__c=regionalManager.id,ProductCatalogRef__c=salescat.id, Name='DKC 123');
     
        insert new List<Hybrid__c>{hyb1,hyb3};
            
        
                                                  
        ProductCatalogEntry__c pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);
        ProductCatalogEntry__c pceS2 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS2.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);        
        ProductCatalogEntry__c pceS3 = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id, Price__c=500, productRef__c=prS3.id, 
                                                                  PriceOld__c=520, Ownerid=Util.CurrentUser.id);  
        insert new List<ProductCatalogEntry__c> {pceS, pceS2,pceS3}; 
        
        //Stock Insert
        
        Stock__c sto1= new Stock__c( Allocation_RSA__c=25, TaxAllocation_RSA__c=25, HybridRef__c=hyb1.id,
                                     ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=regionalManager.id); 
        Stock__c sto3= new Stock__c( Allocation_RSA__c=25, TaxAllocation_RSA__c=25, HybridRef__c=hyb3.id,
                                     ProductCatalogEntryRef_RSA__c = pceS3.id, User_RSA__c=regionalManager.id);
        insert sto1;
    Test.StartTest();
        Consignment__c conA= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, Requested__c=15, UserRef__c=salesRep.id );
        Consignment__c conB= new Consignment__c(ProductCatalogEntryRef__c=pceS.id, Requested__c=50, UserRef__c=salesRep.id );
        Consignment__c conC= new Consignment__c(ProductCatalogEntryRef__c=pceS2.id, Requested__c=50, UserRef__c=salesRep.id );
        Consignment__c conD= new Consignment__c(ProductCatalogEntryRef__c=pceS3.id, Requested__c=10, UserRef__c=salesRep.id );
    List<Consignment__c> consignments= new List<Consignment__c>{conA, conB,conC, conD};
    delete pceS3;
    delete hyb3;
    salesRep=[SELECT Id, Name, Alias, Email, ManagerID,LastName, ProfileId, UserRoleID ,UserName, Manager.Name, UserRole.Name, Manager.Email FROM User WHERE Alias='SAREPA'];                    
    Util.currentUser=salesRep;  
    for(Consignment__c con: consignments){
      REST_ConsignmentObject rco=new REST_ConsignmentObject();
      rco.consignment=con;
      REST_SendLogicalEntityConsignment paramInfo=new REST_SendLogicalEntityConsignment();
      paramInfo.consignments=new list<REST_ConsignmentObject>{rco};
      REST_SendLogicalEntityConsignmentContr.sendConsignments(paramInfo);
    }
    Test.StopTest();
                    
      }  
}