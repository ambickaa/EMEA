/*
    @description Check correct update Product lookup at Case record.
*/
@isTest
private class Test_CaseEditController
{
    private static Product2 testProduct = TestInit.products[0];
    private static Case testCase = TestInit.cases[0];
    
    /*
        @description check changes on case.
    */
    private static testMethod void testEditCase()
    {
        insert testCase;
        insert testProduct;
        
        Test.startTest();
        ApexPages.Standardcontroller aStdController = new ApexPages.Standardcontroller(testCase);
        CaseEditController aController = new CaseEditController(aStdController);
        
        aController.currentCase.lookupValue.Id = testProduct.Id;
        aController.currentCase.lookupValue.text = testProduct.Name;
        aController.save();
        Case anUpdatedCase = [SELECT GC_Product_SFID__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(testProduct.Id, anUpdatedCase.GC_Product_SFID__c, 'Field PRoduct__c was filled incorrect!');
        
        aController.cancel();
        Test.stopTest();
    }
}