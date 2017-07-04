@isTest
public with sharing class Test_CPforecastSKUDistributionController 
{
    public static List<Action_Plan_Line__c> actionPlanList;
    public static Id accountRecordType, productRecordType;
    public static String actualPeriod, priorperiod, actualQuarter, priorQuarter, fiscalYearPrior, fiscalYearActual;
    
    static void init()
    {
        actionPlanList = new List<Action_Plan_Line__c>();
        
        accountRecordType = Util.recordtype.get('Account:DistRetPoS');
        productRecordType = Util.recordtype.get('Product2:CPSalesProduct');
        
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
    
    static testMethod void testCreatorForecastSKU() 
    {
        init();
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType);
        insert acc;        
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType);
        insert vend;
          
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;        
        
        Product2 prod = new Product2(Name = 'product1', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType);
        Product2 prod2 = new Product2(Name = 'product2', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode2', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType);
        insert new List<Product2> {prod, prod2};     
        
        Pricebook2 pb = new Pricebook2(Name = 'test pb', PICK_Product_family__c = 'Roundup', isActive = true, Integration_Key__c = 'TESTPB', CP_Account_Type__c = 'Distributor', CountryRef__c = country.Id);
        insert pb;        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert new List<PricebookEntry> {standardPrice, standardPrice2};
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert new List<PricebookEntry> {customPrice, customPrice2};
        
        
        //DISTRIBUTOR
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = priorPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        
        Action_Plan_Line__c apl2 = new Action_Plan_Line__c();
        apl2.LKP_Account__c = acc.Id;
        apl2.LKP_SKU__c = prod2.Id;
        apl2.PICK_Period__c = priorPeriod;
        apl2.NUM_Initial_stock__c = 150;
        apl2.NUM_Final_stock__c = 75;
        apl2.NUM_Forecast__c = 50;
        insert new List<Action_Plan_Line__c> {apl, apl2};               
                
        Test.startTest();
        PageReference pageRef = Page.AccountViewES;
        Test.setCurrentPage(pageRef);
        CP_forecastSKUDistributionController controller = new CP_forecastSKUDistributionController();
        controller.saveForecastSKU();
        controller.getIsDevice();
        
        country.Units_of_Measurement__c = 'Rels';
        update country;
        controller.saveForecastSKU();
        Test.stopTest();
        
    }
}