/*
    @description Check Current_Year__c field on correct filling on after update.
*/
@isTest
private class Test_TriggerYear
{
    private static Account testAccount = TestInit.createNewFarmer();
    
    /*
        @description Check Current_Year__c field on correct filling.
    */
    private static testMethod void testCheckCorrectCurrentYear()
    {
        Test.startTest();
        List<Year__c> anYearList = createYearList(); 
        Map<Id, Year__c> anInsertYearMap = selectYearById(Util.getIdSet(anYearList));
        
        anYearList[0].Current_Year__c = true;
        anYearList[0].YearPreviousYear__c=anYearList[1].id;
        update anYearList[0];
        Map<Id, Year__c> anUpdateYearMap = selectYearById(Util.getIdSet(anYearList));
        checkCurrentYearFlag(anUpdateYearMap.values(), anYearList[0].Id);
        Test.stopTest();
    }
    
    /*
        @description Check Account fields after change current Year
    */
    private static testMethod void testCheckAccountAfterChangeYear()
    {
        testAccount.GC_is_Visited__c = true;
        testAccount.Visited_PY__c = false;
        insert testAccount;
        
        Test.startTest();
        List<Year__c> anYearList = createYearList();
        Map<Id, Year__c> anInsertYearMap = selectYearById(Util.getIdSet(anYearList));
        
        anYearList[0].Current_Year__c = true;
        Util.currentYear = anYearList[0];
        Util.lastYear = anYearList[1];
        update anYearList[0];
        Test.stopTest();
        
        Account anUpdatedAccount = [SELECT GC_is_Visited__c, Visited_PY__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(true, anUpdatedAccount.GC_is_Visited__c, 'GC_is_Visited__c should be false.');
        System.assertEquals(false, anUpdatedAccount.Visited_PY__c, 'Visited_PY__c should be equals GC_is_Visited__c.');
    }
    
    /*
        @description Get map of Year records by Ids.
    */
    private static Map<Id, Year__c> selectYearById(Set<Id> theIds)
    {
        return new Map<Id, Year__c>([SELECT Current_Year__c FROM Year__c WHERE Id IN :theIds]);
    }
    
    /*
        @description Create list of Year records with field Current_Year equals false.
    */
    private static List<Year__c> createYearList()
    {
        Map<String, Object> anYearParams = new Map<String, Object>
        {
            'Current_Year__c' => false
        };
        List<Year__c> anYearList = new List<Year__c>();
        for (Integer i = 0; i < 2; i++)
        {
            anYearList.add((Year__c)SmartFactory.createSObject('Year__c', anYearParams));
        }
        anYearList[1].Current_Year__c = true;
        insert anYearList;
        return anYearList;
    }
    
    /*
        @description Check Current_Year__c field on correct filling.
    */
    private static void checkCurrentYearFlag(List<Year__c> theYearList, Id theCurrentYearId)
    {
        for (Year__c aYear : theYearList)
        {
            if (aYear.Id == theCurrentYearId)
            {
                System.assert(aYear.Current_Year__c, 'Current_Year__c on this record ' + aYear.Id + ' should be TRUE.');
            } else 
            {
                System.assert(!aYear.Current_Year__c, 'Current_Year__c on this record ' + aYear.Id + ' should be FALSE.');
            }
        }
    }
}