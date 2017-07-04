@isTest
private class TriggerContactTest
{

    static
    {
        try{ MixedDMLOps.ins( TestInit.contacts ); }catch( Exception e ){ }
    }

    static testMethod void copyAccountFieldsTest()
    {
        // verify that the contact fields have the same value as the related account
        list<Contact> contacts = TestInit.contacts;
        list<Account> accounts = TestInit.farmers;
        Account a = accounts.get( 0 );

        for( Contact c : contacts )
        {

            System.assertEquals( c.ZIPPostalCode__c, a.ZIPPostalCode__c );
            System.assertEquals( c.Street__c, a.Street__c );
            System.assertEquals( c.Micro_Region__c, a.Micro_Region__c );
            System.assertEquals( c.County__c, a.County__c );
            //System.assertEquals( c.CountryRef__c, a.CountryRef__c );
            System.assertEquals( c.City__c, a.City__c );
        }
    }
}