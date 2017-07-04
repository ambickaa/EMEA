@isTest
private class Test_TriggerActionPlanLineUpdateUnitRels 
{
    public static RecordType accountRecordType, productRecordType, actionRecordType, forecastRecordType, budgetRecordType;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        actionRecordType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType = 'Action_Plan_Line__c' AND Name = 'Action Plan Line'];
        forecastRecordType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType = 'Action_Plan_Line__c' AND Name = 'CP Forecast'];
        budgetRecordType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType = 'Action_Plan_Line__c' AND Name = 'CP Budget'];
        
              
    }
    static testMethod void test1() 
    {
        init();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
               
                apl.RecordTypeId = actionRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast__c = 50;
                insert apl;
            }
        
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_Rel__c, NUM_Forecast__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_Rel__c, apl2.NUM_Forecast__c);
        
    }
    
    static testMethod void test2() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = forecastRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_SKU__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_SKU_Rel__c, NUM_Forecast_SKU__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_SKU__c, apl2.NUM_Forecast_SKU_Rel__c);
        
    }
    
    static testMethod void test3() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = budgetRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Budget__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Budget__c, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Budget__c, apl2.NUM_Budget_Rel__c);
        
    }
    
        static testMethod void test4() 
    {
        init();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                              
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
               
                apl.RecordTypeId = actionRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast__c = 50;
                insert apl;
            }
        
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_Rel__c, NUM_Forecast__c, LKP_SKU__r.DE_RelFactor__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_Rel__c, apl2.LKP_SKU__r.DE_RelFactor__c*apl2.NUM_Forecast__c);
        
    }
    
    static testMethod void test5() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = forecastRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_SKU__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_SKU_Rel__c, NUM_Forecast_SKU__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals((apl2.NUM_Forecast_SKU__c*2), apl2.NUM_Forecast_SKU_Rel__c);
        
    }
    
    static testMethod void test6() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Basic Units');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = budgetRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Budget__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Budget__c, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(2*apl2.NUM_Budget__c, apl2.NUM_Budget_Rel__c);
        
    }
    
    static testMethod void test7() 
    {
        init();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
               
                apl.RecordTypeId = actionRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_Rel__c = 50;
                insert apl;
            }
        
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_Rel__c, NUM_Forecast__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_Rel__c, apl2.NUM_Forecast__c);
        
    }
    
    static testMethod void test8() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = forecastRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_SKU_Rel__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_SKU_Rel__c, NUM_Forecast_SKU__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_SKU__c, apl2.NUM_Forecast_SKU_Rel__c);
        
    }
    
    static testMethod void test9() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 0, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = budgetRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Budget_Rel__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Budget__c, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Budget__c, apl2.NUM_Budget_Rel__c);
        
    }
    
        static testMethod void test10() 
    {
        init();
        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
               
                apl.RecordTypeId = actionRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_Rel__c = 50;
                insert apl;
            }
        
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_Rel__c, NUM_Forecast__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(apl2.NUM_Forecast_Rel__c, 2*apl2.NUM_Forecast__c);
        
    }
    
    static testMethod void test11() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = forecastRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Forecast_SKU_Rel__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Forecast_SKU_Rel__c, NUM_Forecast_SKU__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals((apl2.NUM_Forecast_SKU__c*2), apl2.NUM_Forecast_SKU_Rel__c);
        
    }
    
    static testMethod void test12() 
    {
        init();
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ES - Regional Manager - CP'];
              
        User u = new User(Alias = 'regmanES', 
        Email='regionalmanager@testorg.com', 
        EmailEncodingKey='ISO-8859-1', 
        LastName='Testing', LanguageLocaleKey='en_US', 
        Country = 'Spain', LocaleSidKey='en_US', 
        ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='regionalmanager@testorg.com');
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        
        system.runAs(u)
            {
                Country__c country = new Country__c(Name = 'Spain', Units_of_Measurement__c = 'Rels');
                insert country;

                Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert acc;
        
                Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
                insert vend;
                
                Division__c d = new Division__c(Name = 'Roundup');
                insert d;
                
                Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, DE_RelFactor__c = 2, recordTypeId = productRecordType.Id);
                insert prod;
                
                Id pricebookId = Test.getStandardPricebookId();
                PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
                insert standardPrice;
                
                apl.RecordTypeId = budgetRecordType.Id;
                apl.LKP_Account__c = acc.Id;
                apl.LKP_SKU__c = prod.Id;
                apl.PICK_Period__c = String.valueOf(System.Date.today().year()) + '-' + '09';
                apl.NUM_Initial_stock__c = 100;
                apl.NUM_Final_stock__c = 50;
                apl.NUM_Budget_Rel__c = 1000;
                insert apl;
            }
        Test.stopTest();
        
        Action_Plan_Line__c apl2 = [SELECT Id, NUM_Budget__c, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE Id =: apl.Id];
        
        System.assertEquals(2*apl2.NUM_Budget__c, apl2.NUM_Budget_Rel__c);
        
    }
}