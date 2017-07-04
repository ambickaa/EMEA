/*
This is  test class of DeliveryLineItems_Inline_Extension class.
Created By: Accenture IDC
Created Date:9/30/2016
*/
@isTest
public class Test_DeliveryLineItems_Inline {
public static testmethod void test1(){
    //Account Test Data
    Account acc = new Account(name='Test');
    insert acc;
    //Delivery Test Data
    Delivery__c dlv = new Delivery__c(GC_Account_Integration_Key__c=acc.id,
                                      name='Test',GC_Integration_Key__c='12345',
                                      GC_Order_Number__c='123');
    insert dlv;
    //Delivery Line Item Test Data
    Delivery_Line_Item__c d1 = new Delivery_Line_Item__c(Name = '900001',
                                    GC_Dlvry_Integration_Key__c= dlv.id,
                                    GC_Integration_Key__c ='900001',
                                    GC_Item_Code__c ='123');
    insert d1;
    ApexPages.StandardController sc = new ApexPages.StandardController(dlv);
    ApexPages.currentPage().getParameters().put('id',dlv.id);
    Test.startTest();
    DeliveryLineItems_Inline_Extension dl = new DeliveryLineItems_Inline_Extension(sc);
    Test.stopTest();
    System.assertEquals(dlv.name,'Test');
    }
}