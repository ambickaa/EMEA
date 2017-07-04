@isTest
private class Test_Batch_CP_FR_Groups {

    public static RecordType accountRecordType, productRecordType;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE developerName = 'CPSalesProduct' AND SobjectType = 'Product2' LIMIT 1];
    }
    
    static testMethod void testAPLines() 
    {
        Test.startTest();
        init();
        
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = 'France', Units_of_Measurement__c = 'Basic Units');
        insert country;
      
        Account vend = new Account(Name = 'Purchasing group', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert new List<Account>{vend, acc};
        
        acc.Influencer__c = vend.Id;
        update acc;
        
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;       
        
        Product2 prod = new Product2(isActive=true, Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, DE_BasicUnits__c = 20);
        insert prod;
                        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), gc_integration_key__c='ACS/SAP00001', Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
        insert standardPrice;      
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c(LKP_Account__c= acc.Id, LKP_SKU__c = prod.Id, LKP_Country__c = country.Id, RecordTypeId=Util.RecordType.get('Action_Plan_Line__c:Action_Plan_Line'), PICK_Period__c = '2017-01', NUM_Forecast__c = 10, NUM_Final_stock__c=100, NUM_Ordered__c=10, num_delivered__c=10);
        insert apl;
        
        
        //Launch batch with scheduler       
        // CRON expression: midnight on March 15.
        // Because this is a test, job executes
        // immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Scheduled_Batch_CP_FR_Groups());
        Test.stopTest();
        
        list<Action_Plan_Line__c> listAPL = [SELECT Id, NUM_Ordered__c, NUM_Forecast__c, Num_Final_stock__C, Num_delivered__c, LKP_Account__c, LKP_SKU__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c != null];
        
        for(Action_Plan_Line__c item: listAPL)
        {
            System.AssertEquals(item.LKP_Account__c, acc.Id);
            System.AssertEquals(item.LKP_SKU__c, prod.Id);
            System.AssertEquals(item.NUM_Forecast__c, apl.NUM_Forecast__c);
            System.AssertEquals(item.NUM_Final_stock__c, apl.NUM_Final_stock__c);
            System.AssertEquals(item.NUM_Ordered__c, apl.NUM_Ordered__c);
            System.AssertEquals(item.NUM_Delivered__c, apl.Num_delivered__c);
        }
    }
}