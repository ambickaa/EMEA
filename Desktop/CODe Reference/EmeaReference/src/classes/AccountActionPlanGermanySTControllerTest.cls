@isTest
public class AccountActionPlanGermanySTControllerTest {
    static
    {
        MixedDMLOps.add( Testinit.farmers );
        
        MixedDMLOps.ins();
        Testinit.getDivision('Corn');
        TestInit.setYear( 1 );
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }

    static testMethod void basicTest()
    {
        
        background();
        AccountTacticalPlanElementController controller = new AccountTacticalPlanElementController();
        controller.germanySTController = new AccountActionPlanGermanySTController ();
        Boolean display = controller.germanySTController.getIsDisplay();
        Boolean displayButtons = controller.germanySTController.getIsDisplayButtons();
        Boolean displayExcel = controller.germanySTController.getIsDisplayExcel();
        
        Map<String, Double> mapF = controller.germanySTController.sumOfNumberFields;
        controller.germanySTController.save();
        controller.germanySTController.excelToMail();
        Util.currentDivision = new Division__c(Name='OSR',Standard__c=true);
        controller.germanySTController.excelToMail();
        Util.currentDivision = new Division__c(Name='Latitude',Standard__c=true);
        controller.germanySTController.excelToMail();
        Util.currentDivision = new Division__c(Name='Monitor',Standard__c=true);
        controller.germanySTController.excelToMail();
        
        Util.currentDivision = new Division__c(Name='Roundup',Standard__c=true);
        controller.germanySTController.excelToMail();
        
    }
    private static void background(){
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        SystemSettings__c s8 = new SystemSettings__c( Name='DE_ExcelMail_Header',Value__C='Please find attached the Excel file.');
        SystemSettings__c s9 = new SystemSettings__c( Name='DE_ExcelMail_Body',Value__C='A new contract has been created');
        SystemSettings__c s10 = new SystemSettings__c( Name='DE_ORG_MAILER_ID',Value__C='07MM0000002DdCA'); 
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9,s10};
        insert ssList;
        Country__c c = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
        util.countryView.country = c;
        Year__c Year= new Year__c (Name='2013-2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
            YearStartDate__c=date.newinstance(2013, 1, 1), CurrentYear_RSA__c=true); 
            insert Year;
                Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
            insert Divi;
       Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                           Category__c='Farm');  
       insert farm;
       
       Util.CurrentAccount=farm;
       Util.currentDivision = Divi;
       Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                           Category__c='Distributor', GC_VATIN_Number__c='5' );
       insert provider;
        RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        RecordType taC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'TrialsProductCatalog'];
        
        ProductCatalog__c prcat = new ProductCatalog__c(name = 'Product Catalog',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c pastcat = new ProductCatalog__c(name = 'Product Catalog Past',countryRef__c=c.id,RecordTypeId=SaC.id);
        ProductCatalog__c trcat = new ProductCatalog__c(name = 'Product Trial Catalog',countryRef__c=c.id,RecordTypeId=taC.id);
        ProductCatalog__c procat = new ProductCatalog__c(name = 'Catalog ii',countryRef__c=c.id);
           
        insert new List<ProductCatalog__c> { prcat, pastcat, trcat, procat} ;
            
        Campaign ca = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=c.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2014,11,11), statuscode__c=300, SalesPCMRef__c=prcat.id,
                          StartDate=Date.newinstance(2013,02,02), DivisionRef__c = Divi.id, CompetitorPCMRef__c=procat.id,
                          TrialPCMRef__c=trcat.id);
         insert ca;
         Util.currentCampaign = ca;
         Product2 pr1 = new Product2(Name='Monsanto Product',ProductSAPCode__c = '12123213',DivisionRef__c=Divi.id);
        Product2 pr2 = new Product2(name='Competitor Product',ProductSAPCode__c = '12444444',DivisionRef__c=Divi.id);
         
        List<Product2> prod2insert= new List<Product2> { pr1,pr2}; 
        insert prod2insert; 
        ProductCatalogEntry__c pce = new ProductCatalogEntry__c (ProductCatalogRef__c=prcat.id, NewProduct__c=true, Price__c=500, productRef__c=pr1.id, 
                                          Ownerid=Util.CurrentUser.id);
                                          insert pce;
       Order__c ordPre = new Order__c( AccountRef_RSA__c=farm.id, Status_RSA__c='Closed',
                                     RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), shouldCopy_RSA__c=false);
       insert ordPre;                                                                      
       Order__c ordFi = new Order__c( AccountRef_RSA__c=farm.id, RecordTypeID=Util.recordtype.get('Order__c:FinalOrder'), 
                                    PreliminaryOrderRef_RSA__c=ordPre.id, Status_RSA__c='Closed', shouldCopy_RSA__c=false);
      insert ordFi;                           
                
       
    }
}