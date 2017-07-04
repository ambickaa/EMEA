//----------------------------------------------------------------------------------------------
// This is the Test class related to the class TriggerAccountIbanCalculator
//----------------------------------------------------------------------------------------------
@isTest
private class Test_TriggerAccountIbanCalculator
{
    private static testmethod void TestTriggerAccountIbanCalculator()
    {
        Country__c C_Slovakia = new Country__c (Name='Slovakia');
        insert C_Slovakia;
        Country__c C_Czech_Republic = new Country__c (Name='Czech Republic');
        insert C_Czech_Republic;
        Account Account1 = TestInit.createNewFarmer();
        Account1.CountryRef__c = C_Slovakia.Id;
        insert Account1;
        
        Test.startTest();
        
        Account1.GC_Bank_Account_Number__c = '5218172/0200';
        update Account1;
        
        Account NewAccount1 = TestInit.createNewFarmer();
        NewAccount1.CountryRef__c = C_Czech_Republic.Id;
        NewAccount1.GC_Bank_Account_Number__c = '123-6546/8899';
        insert NewAccount1;
        
        Account1.GC_Bank_Account_Number__c = '';
        update Account1;
        
        Test.stopTest();
    }
}