@isTest
public class ConsignmentDetailControllerTest {
    public static  Consignment__c consig;
    public static  Consignment__c consig1;
    public static ProductCatalogEntry__c pceS;
    public static Product2 prS;
    public static Stock__c Sto;
    public static Account farm;
    
    public static testMethod void testCreateandDeleteConsignment()
    {
        background();
        Test.startTest();
            Util.urlParameters.put('id',farm.Id);
            ConsignmentDetailController controller = new ConsignmentDetailController();
        
            controller.doAdd();
            
            controller.consignmentLines.get(0).lookupValue=new LookupValue(prS.Id,pceS.Id);
            controller.consignmentLines.get(0).record=consig;
            controller.consignmentLines.get(0).key=sto.Id;
            controller.doSave();
            
            List<Consignment__c> listTest = [select Id from Consignment__c];
            
            System.assertEquals(1,listTest.size());
            
            controller.doEdit();
            controller.doDelete();
            controller.doEdit();
            controller.consignmentLines.get(0).checked =true;
            controller.doDelete();
            listTest = [select Id from Consignment__c];
            
            System.assertEquals(0,listTest.size());
            Test.stopTest();
        
        
        
    }
    public static testMethod void testEditandCancellConsignment()
    {
        background();
        Test.startTest();
        Util.urlParameters.put('id',farm.Id);
        ConsignmentDetailController controller = new ConsignmentDetailController();
    
        controller.doEdit();
        System.assertEquals(controller.editMode,true);
        controller.doCancel();
        System.assertEquals(controller.editMode,false);
        
        Test.stopTest();
    }
    public static testMethod void testviewsConsignment()
    {
        background();
        Test.startTest();
            Util.urlParameters.put('id',farm.Id);
            ConsignmentDetailController controller = new ConsignmentDetailController();
        
            controller.doAdd();
            
            controller.consignmentLines.get(0).lookupValue=new LookupValue(prS.Id,pceS.Id);
            controller.consignmentLines.get(0).record=consig;
            controller.consignmentLines.get(0).key=sto.Id;
            controller.doSave();
            controller.doAdd();
            
            controller.consignmentLines.get(1).lookupValue=new LookupValue(prS.Id,pceS.Id);
            controller.consignmentLines.get(1).record=consig1;
            controller.consignmentLines.get(1).key=sto.Id;
            controller.doSave();
            
            List<Consignment__c> listTest = [select Id from Consignment__c];
            
            System.assertEquals(2,listTest.size());
            
            
            controller.onlyAccepted();      
            System.assertEquals(1,controller.consignmentLines.size());
            controller.onlyRejected();      
            System.assertEquals(1,controller.consignmentLines.size());
            controller.viewAll();
            System.assertEquals(2,controller.consignmentLines.size());
            Test.stopTest();
        
        
    }
    public static testMethod void testErrorsConsignment()
    {
        
        Test.startTest();
            ConsignmentDetailController controller = new ConsignmentDetailController();
        
            
            
            background();
            controller.onlyAccepted();
            controller.onlyRejected();
            System.assertEquals(false,controller.hasCampaign);//No farm ID
            Test.stopTest();
        
    }
    public static void background(){
        
        
         SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5}; 
        insert ssList;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User johann;
        User cronje;    
        System.runAs ( thisUser ) {
             UserRole johannRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Regional_Manager_RSA' limit 1];
             UserRole cronjeRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
             Profile johannprofile = [select Id,name from Profile where Name =:'RSA_Regional Manager' limit 1];
             Profile cronjeprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
             johann =  new User(Alias = 'Johann', Email='Johanntest@test.com', 
                                    EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = johannprofile.Id, UserRoleID = johannRole.ID,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='Johanntest@test.com');
             insert johann;
              cronje =  new User(Alias = 'Cronje', Email='Cronjetest@test.com', ManagerID= johann.Id,
                                    EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', ProfileId = cronjeprofile.Id, UserRoleID = cronjeRole.Id,
                                    TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='Cronjetest@test.com');
            insert cronje;
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
        
         
        //User cronje = [SELECT ManagerId, Manager.ManagerId, Name, id, UserRole.Name, Profile.Name, alias FROM User WHERE ALIAS='BCRONJ'];
        //User johann = [SELECT ManagerId, Name, id, UserRole.Name, Profile.Name, alias FROM User WHERE ALIAS='JJOLIV6'];
             
                    
        
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=cronje.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=cronje.id);
        insert new List<Account> {farm, provider};
        
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        ProductCatalog__c salesCat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c taxCat = new ProductCatalog__c(name = 'Product Catalog Tax',countryRef__c=c.id,RecordTypeId=SaC.id);
        insert new List<ProductCatalog__c> {salesCat, taxCat };
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, 
                                       OwnerId=cronje.Id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2915,11,11), SalesPCMRef__c=salesCat.id,
                                       StartDate=Date.newinstance(1915,02,02), TaxSalesPCMRef_RSA__c=taxCat.id);
        insert caYear;

        
        prS = new Product2(Name='DCK1234 50M',Description='DCK1234', ProductSAPCode__c = '12123213', DivisionRef__c=divi.id);
        insert prS;  
         pceS = new ProductCatalogEntry__c (ProductCatalogRef__c=salesCat.id,  
                                                                  Price__c=500, productRef__c=prS.id, PriceOld__c=520,
                                                                  Ownerid=cronje.Id);  
        insert pceS;

        
        
        Hybrid__c hyb = new Hybrid__c(Name='DKC 656567', ProductCatalogRef__c=salesCat.Id, UserRef__c=johann.Id);
        insert hyb;
        Sto= new Stock__c(HybridRef__c= hyb.Id,Allocation_RSA__c=25000, TaxAllocation_RSA__c=25000, ProductCatalogEntryRef_RSA__c = pceS.id, User_RSA__c=johann.Id );
            insert Sto;
            CampaignLineItem__c cLI = new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'),POG__c=10000,  
                                                                DistributorRef__c=provider.id, Agreed__c=25, CatalogType_RSA__c = 'Regular',
                                                                ProductCatalogEntryRef__c= pceS.id, PreliminaryOrderRef_RSA__c=null, 
                                                                 FarmRef__c= farm.id, CampaignRef__c= caYear.id,Forecast__c=1000,
                                                                Type__c= 'Charged', PlantingDensity__c= '300', ProductRef__c= prS.id, GlobalStock_RSA__c=sto.Id); 
        insert cLI;
        
            consig=new Consignment__c(ProductCatalogEntryRef__c=pceS.Id,GlobalStockRef__c=sto.Id, UserRef__c=cronje.Id, Requested__c=1);
            consig1=new Consignment__c(ProductCatalogEntryRef__c=pceS.Id,GlobalStockRef__c=sto.Id, UserRef__c=cronje.Id, Requested__c=26000);
        
        
    }
    
}