@isTest
private class Test_OrderToCaseController {

private static testmethod void testcase1()
 {
    Account a=new Account(Name='Test'); 
    insert a;
    Order o=new Order(Name='Testt',AccountId= a.id,GC_Integration_Key__c='8001234953' ,EffectiveDate=date.newInstance(2014, 9, 15) ,Status='Draft');
   
    insert o;
    
    Delivery__c d=new Delivery__c();
    d.GC_Account_Integration_Key__c=a.Id;
    d.GC_Integration_Key__c='5004224482';
    d.ShipTo_Acc_Integration_Key__c=a.Id;
    d.GC_Order_Number__c='8001234953';
    d.GC_Delivery_Number_Text__c='5004224482';
    d.name = 'test';  
    insert d;
    
    Invoice__c inv=new Invoice__c();
    inv.GC_Account_Integration_Key__c=a.Id;
    inv.GC_Integration_Key__c='0100118782';
    inv.ShipTo_Acc_Integration_Key__c=a.Id;
    inv.GC_Order_Number__c='8001234953';
    inv.Name='test';
    insert inv;
     
        String   ControllerName ;
      String serviceCaseRecTyp = 'Service Case'; 

      
    PageReference mypage1=new PageReference('/apex + OrdertoCase');
    Test.startTest();
    Test.setCurrentPage(mypage1);
    string html = string.valueOf('UNIT.TEST');
    //Apexpages.currentpage().getparameters().put('id', o.id);
    Apexpages.currentpage().getparameters().put('id', o.id);
    OrderToCaseController ord1 = new OrderToCaseController(new ApexPages.StandardController(o));
     //ApexPages.StandardController(o).addfields(new List<String>{'OrderNumber'});
   Map<String,String> ab1 =  ord1.createDefaultValues();
      ord1.url();
      
    PageReference mypage2=new PageReference('/apex + DeliveryToCase');
    mypage2.getParameters().put('id',d.Id);
     html = string.valueOf('UNIT.TEST');
    Test.setCurrentPage(mypage2);
    Apexpages.currentpage().getparameters().put('id', d.id);
    OrderToCaseController ord2 = new OrderToCaseController(new ApexPages.StandardController(d));
    //System.debug('====OrderToCaseController2==='+ord2);
    Map<String,String> ab2 =  ord2.createDefaultValues();
    ord2.url();
    
    PageReference mypage3=new PageReference('/apex + InvoiceToCase');
    mypage3.getParameters().put('id',inv.Id);
    Test.setCurrentPage(mypage3);
     html = string.valueOf('UNIT.TEST');
    Apexpages.currentpage().getparameters().put('id', inv.id);
    OrderToCaseController ord3 = new OrderToCaseController(new ApexPages.StandardController(inv));
    Map<String,String> ab3 =  ord3.createDefaultValues();
    ord3.url();    
    Test.stopTest(); 
    } 
  }