/*
    @description 
    @copyright PARX
*/
@isTest
private class Test_CaseNewController
{
    private static Product2 testProduct = TestInit.products[0];
    private static Account anAccount = TestInit.createNewFarmer();
    
    /*
        @description Initialize required records and URL parameters.
    */
    private static void init()
    {
        insert anAccount;
        insert testProduct;
        
        PageReference aPage = Page.CaseNew;
        aPage.getParameters().put('AccountId', anAccount.Id);
        Test.setCurrentPage(aPage);
    }
    
    /*
        @description Check create case.
    */
    private static testMethod void testCreateCase()
    {
        init();
        Case aCase = new Case();
        
        Test.startTest();
        ApexPages.Standardcontroller aStdController = new ApexPages.Standardcontroller(aCase);
        CaseNewController aController = new CaseNewController(aStdController);
        System.assertEquals(anAccount.Id, aController.currentCase.record.AccountId, 'AccountId should be filled!');
        System.assertEquals(UserInfo.getUserId(), aController.currentCase.record.OwnerId, 'OwnerId should be current user!');
        
        //Set incorrect Product Id
        aController.currentCase.lookupValue.Id = '123';
        aController.currentCase.lookupValue.text = 'Incorrect ProductId';
        aController.save();
        System.assertEquals(null, aController.currentCase.record.Id, 'Case shouldn\'t created!');
        System.assert(ApexPages.hasMessages(), 'We set isn\'t correct ProductId.');
        
        //Set correct Product Id
        aController.currentCase.lookupValue.Id = testProduct.Id;
        aController.currentCase.lookupValue.text = testProduct.Name;
        aController.save();
        Case anUpdatedCase = [SELECT GC_Product_SFID__c FROM Case WHERE Id = :aCase.Id];
        System.assertEquals(testProduct.Id, anUpdatedCase.GC_Product_SFID__c, 'Field PRoduct__c was filled incorrect!');
        
        aController.cancel();
        Test.stopTest();
    }
}