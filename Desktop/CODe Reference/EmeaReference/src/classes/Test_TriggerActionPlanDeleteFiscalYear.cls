@isTest
private class Test_TriggerActionPlanDeleteFiscalYear {
    
    public static List<Action_Plan_Line__c> actionPlanList;
    public static RecordType accountRecordType, productRecordType;
    public static Integer CONST_INITIAL_STOCK = 100;
    public static Integer CONST_FINAL_STOCK = 100;
    public static Integer CONST_FORECAST = 100;
    
    static void init()
    {
        actionPlanList = new List<Action_Plan_Line__c>();
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];        
    }
    
    static testMethod void myUnitTest()
    {
        init();
        Test.startTest();
        string objectName = 'Action_Plan_Line__c';
        Map<String, Schema.SObjectType> gdesc = Schema.getGlobalDescribe();
        Sobject objectt = gdesc.get(objectName).newSObject();
        Map<String, SObjectField> M = objectt.getSObjectType().getDescribe().fields.getMap();

        Integer month = 9;
        
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
        
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;
        
        Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;            
            if(month <= 9) apl.PICK_Period__c =  String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(month);
            else apl.PICK_Period__c =  System.Date.today().year() + '-' + String.valueOf(month);
        apl.NUM_Initial_stock__c = CONST_INITIAL_STOCK;
        apl.NUM_Final_stock__c = CONST_FINAL_STOCK;
        apl.NUM_Forecast__c = CONST_FORECAST;
        insert apl;
        
        List <Action_Plan_Line__c> retrievedAPLs = [SELECT txt_external_id__c, PICK_Period__c, LKP_Account__c, LKP_SKU__c,NUM_Initial_stock__c,NUM_Final_stock__c,NUM_Forecast__c FROM Action_Plan_Line__c WHERE LKP_Account__c =: acc.Id AND LKP_SKU__c =: prod.Id  ORDER BY PICK_Period__c ASC NULLS FIRST ];
        
        Integer linesToCreate = Math.mod((8-month + 12),12) + 1;    
        
        System.debug('SIZE linesToCreate: ' + linesToCreate);
        System.debug('SIZE retrievedAPLs: ' + retrievedAPLs.size());
        
        System.assertEquals(linesToCreate, retrievedAPLs.size());
        
        for(Action_Plan_Line__c retApl : retrievedAPLs)
        {
            //system.debug('EVE_JDD: apl.Id =[' +retApl.Id + '], apl.txt_external_id__c=['+retApl.txt_external_id__c+ ']');
            String pickValue = '';
            if(month <= 12)
            {
                if(month <= 9) pickValue =  String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(month);
                else pickValue =  System.Date.today().year() + '-' + String.valueOf(month);
            }
            else if(month > 12) pickValue =  String.valueOf(System.Date.today().year() + 1) + '-' + '0' + String.valueOf(Math.mod(month, 12));
            //System.assertEquals(pickValue, retApl.PICK_Period__c);
            System.assertEquals(acc.Id, retApl.LKP_Account__c);
            System.assertEquals(prod.Id, retApl.LKP_SKU__c);
            System.assertEquals(CONST_FORECAST, retApl.NUM_Forecast__c);
            
            String expectedExternalId = String.valueOf(acc.Id).substring(0, 15) + '-' + String.valueOf(prod.Id).substring(0, 15) + '-' + pickValue;
            //System.assertEquals(expectedExternalId, retApl.txt_external_id__c);            
            month = month+1;
        }
        Action_Plan_Line__c aplToDelete = retrievedAPLs.get(3);
        delete aplToDelete;
        
        retrievedAPLs = [SELECT txt_external_id__c, PICK_Period__c, LKP_Account__c, LKP_SKU__c,NUM_Initial_stock__c,NUM_Final_stock__c,NUM_Forecast__c FROM Action_Plan_Line__c WHERE LKP_Account__c =: acc.Id AND LKP_SKU__c =: prod.Id  ORDER BY PICK_Period__c ASC NULLS FIRST ];
        //System.assertEquals(3, retrievedAPLs.size());
    }

    static testMethod void myUnitTest2()
    {
        init();
        Test.startTest();
        string objectName = 'Action_Plan_Line__c';
        Map<String, Schema.SObjectType> gdesc = Schema.getGlobalDescribe();
        Sobject objectt = gdesc.get(objectName).newSObject();
        Map<String, SObjectField> M = objectt.getSObjectType().getDescribe().fields.getMap();

        Integer month = date.today().month();
        Integer monthref = date.today().month();
        
        //PoS Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'PoS',GC_Cust_Account_Grp_Descr__c = 'Ship-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
        
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;
        
        Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;            
        if(month <= 12)
        {
            if(month < 3) apl.PICK_Quarter__c  =  'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q2';
            else if (month < 6) apl.PICK_Quarter__c  =  'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q3';
                else if (month < 9) apl.PICK_Quarter__c  = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q4';
                    else if (month < 12) apl.PICK_Quarter__c  =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q1';
                        else apl.PICK_Quarter__c  =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q2';
        }
        apl.NUM_Initial_stock__c = CONST_INITIAL_STOCK;
        apl.NUM_Final_stock__c = CONST_FINAL_STOCK;
        apl.NUM_Forecast__c = CONST_FORECAST;
        insert apl;
        
        List <Action_Plan_Line__c> retrievedAPLs = [SELECT txt_external_id__c, PICK_Quarter__c, LKP_Account__c, LKP_SKU__c,NUM_Initial_stock__c,NUM_Final_stock__c,NUM_Forecast__c FROM Action_Plan_Line__c WHERE LKP_Account__c =: acc.Id AND LKP_SKU__c =: prod.Id  ORDER BY PICK_Quarter__c ASC NULLS FIRST ];
        
        Integer linesToCreate = 3;
            if (month < 6 && month >=3) linesToCreate = 2;
                else if (month < 9 && month >=6) linesToCreate = 1;
                    else if (month < 12 && month >=9) linesToCreate = 4;
        
        //System.debug('SIZE retrievedAPLs: ' + retrievedAPLs.size());
        
        System.assertEquals(linesToCreate, retrievedAPLs.size());
        
        for(Action_Plan_Line__c retApl : retrievedAPLs)
        {
            //system.debug('EVE_JDD: apl.Id =[' +retApl.Id + '], apl.txt_external_id__c=['+retApl.txt_external_id__c+ ']');
            String pickValue = '';
            if(monthref <= 12 && monthref >=9)
            {
            if(month < 3) pickValue   =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q2';
            else if (month < 6) pickValue   =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q3';
                else if (month < 9) pickValue   = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q4';
                    else if (month < 12) pickValue   =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q1';
                        else pickValue   =  'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4) + ' ' + 'Q2';
            }
            else
            if(monthref < 9)
            {
            if(month < 3) pickValue   =  'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q2';
            else if (month < 6) pickValue   =  'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q3';
                else if (month < 9) pickValue   = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4) + ' ' + 'Q4';
            }
            //System.assertEquals(pickValue, retApl.PICK_Quarter__c);
            System.assertEquals(acc.Id, retApl.LKP_Account__c);
            System.assertEquals(prod.Id, retApl.LKP_SKU__c);
            System.assertEquals(CONST_FORECAST, retApl.NUM_Forecast__c);
            
            String expectedExternalId = String.valueOf(acc.Id).substring(0, 15) + '-' + String.valueOf(prod.Id).substring(0, 15) + '-' + pickValue;
            //System.assertEquals(expectedExternalId, retApl.txt_external_id__c);            
            month = month+3;
            if (month == 12) month = 1; 
        }
        Action_Plan_Line__c aplToDelete = retrievedAPLs.get(0);
        delete aplToDelete;
        
        retrievedAPLs = [SELECT txt_external_id__c, PICK_Quarter__c, LKP_Account__c, LKP_SKU__c,NUM_Initial_stock__c,NUM_Final_stock__c,NUM_Forecast__c FROM Action_Plan_Line__c WHERE LKP_Account__c =: acc.Id AND LKP_SKU__c =: prod.Id  ORDER BY PICK_Period__c ASC NULLS FIRST ];
        //System.assertEquals(3, retrievedAPLs.size());
    }

}