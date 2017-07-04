/*
    @description Test create, edit and delete CampaignLineItem records
*/
@isTest
private class Test_AccountGiveAwaysController
{
    private static final Integer CLI_QUANTITY = 19;
    private static final Integer PCE_PRICE = 7;
    
    private static Map<String, Object> baseCampaignLineItemParam;
    private static Product2 product = TestInit.products[0];
    
    /*
        @description Initialize URL parameters and required records for test.
    */
    private static void init()
    {
        TestInit.createAccountListController();
        product.DivisionRef__c = TestInit.accountWrapper.campaignRecord.DivisionRef__c;
        insert product;
        
        Map<String, Object> aProductCatalogEntryParam = new Map<String, Object>
        {
            'IsActive__c' => true,
            'Price__c' => PCE_PRICE,
            'ProductRef__c' => product.Id
        };
        ProductCatalogEntry__c aProductCatalogEntry = (ProductCatalogEntry__c)SmartFactory.createSObject('ProductCatalogEntry__c', aProductCatalogEntryParam);
        insert aProductCatalogEntry;
        
        baseCampaignLineItemParam = new Map<String, Object>
        {
            'CampaignRef__c' => TestInit.accountWrapper.campaignRecord.Id,
            'FarmRef__c' => TestInit.accountWrapper.accountRecord.Id,
            'ProductRef__c' => product.Id,
            'Quantity__c' => CLI_QUANTITY,
            'ProductCatalogEntryRef__c' => aProductCatalogEntry.Id,
            'ContactRef__c' => TestInit.contacts[0].Id
        };
        
        PageReference aPage = Page.AccountViewDefault;
        aPage.getParameters().put('Id', TestInit.accountWrapper.accountRecord.Id);
        aPage.getParameters().put('division', TestInit.accountWrapper.campaignRecord.DivisionRef__c);
        Test.setCurrentPageReference(aPage);
    }
    
    /*
        @description Test create, edit and delete CampaignLineItem records
    */
    private static testMethod void testAccountGiveAwaysController()
    {
        init();
        
        Test.startTest();
        
        retoure__c toRetoure= new retoure__c(Account__C= TestInit.accountWrapper.accountRecord.Id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure;
        CampaignLineItem__c aCampaignLineItem = createCampaignLineItem(Util.recordType.get('CampaignLineItem__c:GiveAway'));
        
        AccountGiveAwaysController aController = new AccountGiveAwaysController();
        System.AssertEquals(aCampaignLineItem.Id, aController.getMerchandiseManagements()[0].record.Id, 'Incorrect selected record.');
        System.assert(aController.getIsHasElements(), 'Controller hasn\'t any elements.');
        System.assert(aController.getIsEditButton(), 'There isn\'t current Campaign or Account Owner.');
        
        //Create new record
        Test.setCurrentPage(TestInit.customRedirectModifier(aController.newRecord()));
        Util.urlParameters = null;
        aController = new AccountGiveAwaysController();
        Integer aListSize = aController.getMerchandiseManagements().size();
        CampaignLineItem__c aCreatedRecord = aController.getMerchandiseManagements()[aListSize - 1].record;
        aCreatedRecord.ProductRef__c = product.Id;
        aCreatedRecord.Quantity__c = CLI_QUANTITY;
        aCreatedRecord.ContactRef__c = TestInit.contacts[0].Id;
        
        //Save new record with filled fields
        Test.setCurrentPage(TestInit.customRedirectModifier(aController.save()));
        Util.urlParameters = null;
        aController = new AccountGiveAwaysController();
        System.assertEquals(2, aController.getMerchandiseManagements().size(), 'Size of list incorrect.');
        
        //Select last record for delete
        aListSize = aController.getMerchandiseManagements().size();
        aController.getMerchandiseManagements()[aListSize - 1].checked = true;
        
        //Delete selected record
        Test.setCurrentPage(TestInit.customRedirectModifier(aController.deletex()));
        Util.urlParameters = null;
        aController = new AccountGiveAwaysController();
        System.assertEquals(1, aController.getMerchandiseManagements().size(), 'Size of list incorrect.');
        System.assertEquals(aCampaignLineItem.Id, aController.getMerchandiseManagements()[0].record.Id, 'Incorrect selected record.');
        
        aController.doLoadProductPicker();
        aController.edit();
        aController.cancel();
        Test.stopTest();
    }
    
    /*
        @description Create CampaignLineItem by RecordTypeId
    */
    private static CampaignLineItem__c createCampaignLineItem(Id theRecordTypeId)
    {
        baseCampaignLineItemParam.put('RecordTypeId', theRecordTypeId);
        CampaignLineItem__c aCampaignLineItem = (CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', baseCampaignLineItemParam);
        insert aCampaignLineItem;
        return aCampaignLineItem;
    }
}