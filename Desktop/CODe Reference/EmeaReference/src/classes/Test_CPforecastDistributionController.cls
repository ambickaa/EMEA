@isTest
public with sharing class Test_CPforecastDistributionController 
{
    public static List<Action_Plan_Line__c> actionPlanList;
    public static RecordType accountRecordType, productRecordType;
    public static String actualPeriod, priorperiod, actualQuarter, priorQuarter, fiscalYearPrior, fiscalYearActual;
    
    static void init()
    {
        actionPlanList = new List<Action_Plan_Line__c>();
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
        //DISTRIBUTOR
        if(System.Date.today().month() == 1)
        {
            priorPeriod = String.valueOf(System.Date.today().year() - 1) + '-' + 12;
            actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
        }
        else
        {
            if(System.Date.today().month() - 1 < 10)
            {
                priorPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() - 1);
                actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
            }
            else if(System.Date.today().month() - 1 >= 10)
            {
                actualPeriod = String.valueOf(System.Date.today().year() + '-' + String.valueOf(System.Date.today().month()));
                priorPeriod = String.valueOf(System.Date.today().year() + '-' + String.valueOf(System.Date.today().month() - 1));
            }       
        }
        
        //PoS
        if(Integer.valueof(System.Date.today().month()) <= 3)
        {
            actualQuarter = 'Q1';
            priorQuarter = 'Q4';
            fiscalYearPrior = 'FY' + String.valueOf(System.Date.today().year() - 1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
        }
        else if(Integer.valueof(System.Date.today().month()) > 3 && Integer.valueof(System.Date.today().month()) < 7)
        {
            actualQuarter = 'Q2';
            priorQuarter = 'Q1';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 7 && Integer.valueof(System.Date.today().month()) < 10)
        {
            actualQuarter = 'Q3';
            priorQuarter = 'Q2';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 10 && Integer.valueof(System.Date.today().month()) < 13)
        {
            actualQuarter = 'Q4';
            priorQuarter = 'Q3';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }       
    }
    

    static testMethod void testCreatorForecastBasicUnits() 
    {
        init();
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, GC_Cust_Account_Grp_Descr__c ='Sold-to party', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        
        Account acc2 = new Account(Name = 'Account2PoS', CountryRef__c = country.Id, GC_Cust_Account_Grp_Descr__c ='Ship-to party', Category__c = 'PoS', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc2;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
          
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;        
        
        Product2 prod = new Product2(Name = 'product1', Family='Roundup', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, TXT_commercial_name__c='Roundup');
        insert prod;
        
        Pricebook2 pb = new Pricebook2(Name= 'test pb', PICK_Product_family__c='Roundup',Integration_Key__c = 'TESTPB');
        insert pb;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert customPrice;
                      
                
        Test.startTest();
        PageReference pageRef = Page.AccountViewES;
        Test.setCurrentPage(pageRef);
        CP_forecastDistributionController controller = new CP_forecastDistributionController();
        controller.distributeForecast=1235;        
        controller.selectedproducts=controller.allProducts;
        controller.selectedDistributors=controller.allDistributors;
        
        
        controller.getForecast();
        system.debug(controller.fiscalYears);
        
        //controller.initializeAplForecast();
        controller.saveForecast();
        controller.generateForecastPreview();
    }
    static testMethod void testCreatorForecastRels() 
    {
        init();
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Rels');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, GC_Cust_Account_Grp_Descr__c ='Sold-to party', Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        
        Account acc2 = new Account(Name = 'Account2PoS', CountryRef__c = country.Id, GC_Cust_Account_Grp_Descr__c ='Ship-to party', Category__c = 'PoS', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc2;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
          
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;        
        
        Product2 prod = new Product2(Name = 'product1', Family='Roundup', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, TXT_commercial_name__c='Roundup');
        insert prod;
        
        Pricebook2 pb = new Pricebook2(Name= 'test pb', PICK_Product_family__c='Roundup',Integration_Key__c = 'TESTPB', isActive = true);
        insert pb;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert customPrice;
                      
                
        Test.startTest();
        PageReference pageRef = Page.AccountViewES;
        Test.setCurrentPage(pageRef);
        CP_forecastDistributionController controller = new CP_forecastDistributionController();
        controller.distributeForecast=1235;        
        controller.selectedproducts=controller.allProducts;
        controller.selectedDistributors=controller.allDistributors;
        
        
        controller.getForecast();
        system.debug(controller.fiscalYears);
        
        //controller.initializeAplForecast();
        controller.saveForecast();
        controller.generateForecastPreview();
        
        country.Units_of_Measurement__c = 'Rels';
        update country;
        controller.generateForecastPreview();
    }
}