/*
This is  test class of Hlpr_CaseUpdateAccount class.
Created By: Accenture IDC
Created Date:8/31/2016
*/
@isTest
public class Test_Hlpr_CaseUpdateAccount {
    public static testmethod void test1(){
    Id RId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
    List<Case> lstCases = new List<Case>();
    //Test Data
    Account acc = new Account(name='Test',fax='+123',GC_SAP_ID__c='12');
    insert acc;
    Case c1 = new Case(AccountId=acc.Id,origin='Fax',priority='Medium',Status='New',subject='Efax"+123"Test',suppliedemail='test@acs.com',recordtypeid=RId);
    Case c2 = new Case(AccountId=acc.Id,origin='Fax',priority='Medium',Status='New',subject='Efax"+123"Test',suppliedemail='test@acs.com',recordtypeid=RId);
    lstCases.add(c1);
    lstCases.add(c2);
    insert lstCases;
    Test.startTest();
    Hlpr_CaseUpdateAccount.updateAccount(lstCases);   
    System.assertEquals(lstCases.size(),2);
    Test.stopTest();
    }
}