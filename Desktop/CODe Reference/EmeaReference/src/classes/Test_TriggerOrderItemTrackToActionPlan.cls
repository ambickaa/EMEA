@isTest
private class Test_TriggerOrderItemTrackToActionPlan {

    public static RecordType accountRecordType, productRecordType;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
    }
    
    static testMethod void myUnitTest() 
    {
        init();
        TriggerOrderItemTrackToActionPlanLine t=new TriggerOrderItemTrackToActionPlanLine();
        
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
        
        Order o = new Order(AccountId = acc.Id, GC_Integration_Key__c = 'SAP00001', GC_Document_Type_Descr__c ='Ag-Eu Standard Order', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '15', GC_Requested_Delivery_Date__c = System.today());
        insert o;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = o.Id;
        oi.PricebookEntryId = standardPrice.id;
        oi.Quantity = 100;
        oi.GC_Delivered_Quantity__c = 100;
        oi.GC_Quantity__c = 100;
        oi.UnitPrice = 1;
        insert oi;
        
        list<Action_Plan_Line__c> listAPL = [SELECT Id, LKP_Account__c, LKP_SKU__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c != null];
        
        for(Action_Plan_Line__c apl : listAPL)
        {
         //   System.AssertEquals(apl.LKP_Account__c, acc.Id);
          //  System.AssertEquals(apl.LKP_SKU__c, prod.Id);
          //  System.AssertEquals(apl.NUM_Ordered__c, oi.GC_Quantity__c);
        }
        
        oi.Quantity = 200;
        update oi;        
      //  Action_Plan_Line__c apl2= [SELECT Id, LKP_Account__c, LKP_SKU__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c =: 200];
       // System.AssertEquals(apl2.NUM_Ordered__c, oi.Quantity );
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
        aplAux.NUM_Ordered__c = 100;
        insert aplAux;
        
        Order o = new Order(AccountId = acc.Id, GC_Integration_Key__c = 'SAP00001', GC_Document_Type_Descr__c ='Ag-Eu Standard Order', EffectiveDate = System.today()-1, Status = 'Draft', Divison_Code__c = '15', GC_Requested_Delivery_Date__c = System.today());
        insert o;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = o.Id;
        oi.PricebookEntryId = standardPrice.id;
        oi.Quantity = 100;
        oi.GC_Delivered_Quantity__c = 100;
        oi.GC_Quantity__c = 100;
        oi.UnitPrice = 1;
        
        OrderItem oi2 = new OrderItem();
        oi2.OrderId = o.Id;
        oi2.PricebookEntryId = standardPrice.id;
        oi2.Quantity = 100;
        oi2.GC_Delivered_Quantity__c = 100;
        oi2.GC_Quantity__c = 100;
        oi2.UnitPrice = 1;
        
        List<OrderItem> listOrderItem = new List<OrderItem>();
        listOrderItem.add(oi);
        listOrderItem.add(oi2);
        insert listOrderItem;
        
        list<Action_Plan_Line__c> listAPL = [SELECT Id, LKP_Account__c, LKP_SKU__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c != null];
        
        for(Action_Plan_Line__c apl : listAPL)
        {
       //     System.AssertEquals(apl.LKP_Account__c, acc.Id);
         //   System.AssertEquals(apl.LKP_SKU__c, prod.Id);
          //  System.AssertEquals(apl.NUM_Ordered__c, aplAux.NUM_Ordered__c + (oi.GC_Quantity__c + oi2.GC_Quantity__c));
        }
        
        List<OrderItem> listOrderItem2 = new List<OrderItem>();
        oi.Quantity = 200;
        oi2.Quantity = 200;
        listOrderItem2.add(oi);
        listOrderItem2.add(oi2);
        update listOrderItem2;
              
        list<Action_Plan_Line__c> listAPLUpd = [SELECT Id, LKP_Account__c, LKP_SKU__c, NUM_Ordered__c FROM Action_Plan_Line__c WHERE NUM_Ordered__c != null];
       // System.AssertEquals(listAPLUpd.size(), 1); 
    }
}