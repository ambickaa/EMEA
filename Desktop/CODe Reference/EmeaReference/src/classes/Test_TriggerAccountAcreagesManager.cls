/*
    @description Test changes with related to Account Acreage records on after insert and after update.
    @copyright PARX
*/
@isTest
private class Test_TriggerAccountAcreagesManager
{
    private static String ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY = 'TotalCornAcreagesManualCY__c';
    private static String ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY = 'TotalOSRAcreagesManualCY__c';
    private static String ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY = 'TotalOtherAcreagesManualCY__c';
    
    private static Map<String, Integer> testMapFieldsValues = new Map<string, Integer>
    {
        ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY => 0, ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY => 5, ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY => 7
    };
    
    /*
        @description Test changes with related Acreages.
    */
    private static testMethod void testChangeRelatedAcreages()
    {
        Country__c aCountry = new Country__c(Name = 'Hungary');
        insert aCountry;
        
        Test.startTest();
        Account testAccount = TestInit.createNewFarmer();
        testAccount.CountryRef__c = aCountry.Id;
        testAccount = getChangeAccountFields(testAccount);
        insert testAccount;
      //  System.assert(new CountryAdapter(testAccount).isAutoCreateAcreages(), 
        //          'Account should be changes for Hungary related Country ONLY.');
        checkAcreageChanges(testAccount.Id);
        
        testAccount = getChangeAccountFields(testAccount);
        update testAccount;
        checkAcreageChanges(testAccount.Id);
        Test.stopTest();
    }
    
    /*
        @description Select and check related Acreage records.
    */
    private static void checkAcreageChanges(Id theAccountId)
    {
        List<Acreage__c> anAcreageList = [SELECT AcrTotalAcreages__c, AcrProductGroupRef__c FROM Acreage__c WHERE AcrFarmRef__c = :theAccountId];
        
      //  System.assertEquals(3, anAcreageList.size(), 'Should be created three related Acreage__c records.');
        for (Acreage__c anAcreage : anAcreageList)
        {
            if (anAcreage.AcrProductGroupRef__c == Util.getProductGroup(Util.PRODUCT_GROUP_CORN))
            {
               // System.assertEquals(anAcreage.AcrTotalAcreages__c, testMapFieldsValues.get(ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY), 
                     //     'Field AcrTotalAcreages__c was filled incorrect.');
            }
            else if (anAcreage.AcrProductGroupRef__c == Util.getProductGroup(Util.PRODUCT_GROUP_OSR))
            {
              //  System.assertEquals(anAcreage.AcrTotalAcreages__c, testMapFieldsValues.get(ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY), 
                      //    'Field AcrTotalAcreages__c was filled incorrect.');
            }
            else if (anAcreage.AcrProductGroupRef__c == Util.getProductGroup(Util.PRODUCT_GROUP_OTHER))
            {
                //System.assertEquals(anAcreage.AcrTotalAcreages__c, testMapFieldsValues.get(ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY), 
                //        'Field AcrTotalAcreages__c was filled incorrect.');
            }
            else
            {
               // System.assert(false, 'Has been incorrect Acreage record.');
            }
        }
    }
    
    /*
        @description Get Account record with changed fields from testMapFieldsValues Map.
    */
    private static Account getChangeAccountFields(Account theAccount)
    {
        testMapFieldsValues.put(ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY, testMapFieldsValues.get(ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY) * 7);
        testMapFieldsValues.put(ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY, testMapFieldsValues.get(ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY) * 7);
        testMapFieldsValues.put(ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY, testMapFieldsValues.get(ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY) * 7);
        theAccount.TotalCornAcreagesManualCY__c = testMapFieldsValues.get(ACCOUNT_TOTAL_CORN_ACREAGE_MANUAL_CY);
        theAccount.TotalOSRAcreagesManualCY__c = testMapFieldsValues.get(ACCOUNT_TOTAL_OSR_ACREAGE_MANUAL_CY);
        theAccount.TotalOtherAcreagesManualCY__c = testMapFieldsValues.get(ACCOUNT_TOTAL_OTHER_ACREAGE_MANUAL_CY);
        
        return theAccount;
    }
}