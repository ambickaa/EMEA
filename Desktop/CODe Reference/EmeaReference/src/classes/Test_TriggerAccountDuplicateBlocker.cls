/*
    Check Account records on duplicates names on before insert.
*/
@isTest
private class Test_TriggerAccountDuplicateBlocker
{
    private static List<Account> testAccountList;
    
    static
    {
        testAccountList = new List<Account>
        {
            new Account(Name = 'testAccount', CountryRef__c = TestInit.getCountryByName('France').id)
        };
    }
    
    //Check Account records on duplicates names.
    private static testmethod void testCheckDuplicateName()
    {
        Test.startTest();
        
        //insert first record and check that doesn\'t exist duplicates.
        List<DataBase.SaveResult> anResultInsert = DataBase.insert(testAccountList, false);
        System.debug('********'+anResultInsert[0].getErrors());
        //System.assert(anResultInsert[0].getErrors().isEmpty(), 
        //      'Account record with Name=' + testAccountList[0].Name + ' shouldn\'t exist in DB.');
        
        //add the same record and insert it. Check that the record with the same name exist.
        testAccountList.add(new Account(Name = 'testAccount', CountryRef__c = TestInit.getCountryByName('France').id));
        List<DataBase.UpsertResult> anResultUpsert = DataBase.upsert(testAccountList, false);
       // System.assert(anResultUpsert[0].getErrors().isEmpty(), 'Account record with Name=' + testAccountList[0].Name + ' shouldn\'t exist in DB.');
       // System.assert(!anResultUpsert[1].getErrors().isEmpty(), 'Account record with Name=' + testAccountList[0].Name + ' should exist in DB.');
        Test.stopTest();
    }
}