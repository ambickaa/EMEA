@isTest
private class Test_TriggerInvoiceLineTrackToAPL
{
    public static RecordType accountRecordType, productRecordType;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
    }

    static testMethod void myUnitTest()
    {
        init();
        TriggerInvoiceLineTrackToActionPlanLine t=new TriggerInvoiceLineTrackToActionPlanLine();
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
      
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
        
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;       
        
        Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, DE_BasicUnits__c = 20);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        Invoice__c inv = new Invoice__c();
        inv.Name = 'INV00001';
        inv.GC_Account_Integration_Key__c = acc.Id;
        inv.GC_Order_Number__c = 'SAP00001';
        inv.GC_Integration_Key__c = 'KEY00001';
        inv.GC_Invoice_Creation_Date__c = System.today();
        inv.Divison_Code__c = '15';
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Name = 'ILI0001';
        ili.GC_Invoice_Integration_Key__c = inv.Id;
        ili.GC_Quantity__c = 100;
        ili.GC_Integration_Key__c = 'KEY00001';
        ili.GC_Item_Code__c = 'SAPCode1';
        insert ili;
        
        list<Action_Plan_Line__c> listAPL = [SELECT Id, LKP_Account__c, LKP_SKU__c, NUM_Delivered__c FROM Action_Plan_Line__c WHERE NUM_Delivered__c != null];
        
        for(Action_Plan_Line__c apl : listAPL)
        {
            System.AssertEquals(apl.LKP_Account__c, inv.GC_Account_Integration_Key__c);
            System.AssertEquals(apl.LKP_SKU__c, prod.Id);
            System.AssertEquals(apl.NUM_Delivered__c, ili.GC_Quantity__c);            
        }
        
        ili.GC_Quantity__c = 200;
        update ili;
        
        list<Action_Plan_Line__c> listAPLUpd = [SELECT Id, NUM_Delivered__c FROM Action_Plan_Line__c WHERE NUM_Delivered__c =: ili.GC_Quantity__c];
      //  System.AssertEquals(listAPLUpd.size(), 1);
        
         
    }
    
    static testMethod void myUnitTest2()
    {
        init();
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
      
        Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
        
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;       
        
        Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id, DE_BasicUnits__c = 20);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
        insert standardPrice;
        
        Action_Plan_Line__c aplAux = new Action_Plan_Line__c();
        aplAux.LKP_Account__c = acc.Id;
        aplAux.LKP_SKU__c = prod.Id;
        aplAux.PICK_Period__c = (System.today().month() <= 9 ? String.valueOf(System.today().year()) + '-' + '0' + String.valueOf(System.today().month()) : String.valueOf(System.today().year()) + '-' + String.valueOf(System.today().month()));
        aplAux.NUM_Delivered__c = 100;
        insert aplAux;
        
        Invoice__c inv = new Invoice__c();
        inv.Name = 'INV00001';
        inv.GC_Account_Integration_Key__c = acc.Id;
        inv.GC_Order_Number__c = 'SAP00001';
        inv.GC_Integration_Key__c = 'KEY00001';
        inv.GC_Invoice_Creation_Date__c = System.today();
        inv.Divison_Code__c = '15';
        insert inv;
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Name = 'ILI0001';
        ili.GC_Invoice_Integration_Key__c = inv.Id;
        ili.GC_Quantity__c = 100;
        ili.GC_Integration_Key__c = 'KEY00001';
        ili.GC_Item_Code__c = 'SAPCode1';
        
        Invoice_Line_Item__c ili2 = new Invoice_Line_Item__c();
        ili2.Name = 'ILI0002';
        ili2.GC_Invoice_Integration_Key__c = inv.Id;
        ili2.GC_Quantity__c = 100;
        ili2.GC_Integration_Key__c = 'KEY00002';
        ili2.GC_Item_Code__c = 'SAPCode1';
        
        List<Invoice_Line_Item__c> listILI = new list<Invoice_Line_Item__c>();
        listILI.add(ili);
        listILI.add(ili2);
        
        insert listILI;
        
        list<Action_Plan_Line__c> listAPL = [SELECT Id, TXT_External_ID__c, LKP_Account__c, LKP_SKU__c, NUM_Delivered__c FROM Action_Plan_Line__c WHERE NUM_Delivered__c != null];
        
        for(Action_Plan_Line__c apl : listAPL)
        {
        //    System.AssertEquals(apl.LKP_Account__c, inv.GC_Account_Integration_Key__c);
         //   System.AssertEquals(apl.LKP_SKU__c, prod.Id);
         //   System.AssertEquals(apl.NUM_Delivered__c, aplAux.NUM_Delivered__c + (ili.GC_Quantity__c + ili2.GC_Quantity__c));            
        }
        
        List<Invoice_Line_Item__c> listILI2 = new list<Invoice_Line_Item__c>();
        ili.GC_Quantity__c = 200;
        ili2.GC_Quantity__c = 200;
        listILI2.add(ili);
        listILI2.add(ili2);
        
        update listILI2;      
        
        list<Action_Plan_Line__c> listAPLUpd = [SELECT Id, NUM_Delivered__c FROM Action_Plan_Line__c WHERE NUM_Delivered__c != null];
      //  System.AssertEquals(listAPLUpd.size(), 1);         
    }
}