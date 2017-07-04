@isTest
private class Test_AccountAcreageListController 
{
    private static Account provider;
    private static Product_Grouping__c productGroup;
    private static Product_Grouping__c productType;
    
    /*
        @description Initialize required records.
    */
    private static void init()
    {
        TestInit.createAccountListController();
        
        provider = TestInit.createNewCompetitor();
        insert provider;
        
        productGroup = new Product_Grouping__c(
            Name = 'test product group',
            RecordTypeId = Util.recordType.get('Product_Grouping__c:' + AccountAcreageListController.PRODUCT_GROUP_RT_NAME));
        insert productGroup;
        
        productType = new Product_Grouping__c(
            Name = 'test product type',
            ProductGroupRef__c = productGroup.Id,
            RecordTypeId = Util.recordType.get('Product_Grouping__c:' + AccountAcreageListController.PRODUCT_TYPE_RT_NAME));
        insert productType;
    }
    
    /*
        @description Test Account record by attach Acreage record.
    */
    private static testMethod void testAccountAcreages()
    {
        init();
        
        Acreage__c wrongAcreage = new Acreage__c(
            RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProduct'),
            AcrFarmRef__c = TestInit.accountWrapper.accountRecord.id,
            AcrYearRef__c = Util.currentYear.Id);
        insert wrongAcreage;
        
        Acreage__c rightAcreage = new Acreage__c(
            RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProductGroup'),
            AcrFarmRef__c = TestInit.accountWrapper.accountRecord.id,
            AcrYearRef__c = Util.currentYear.Id,
            AcrTotalAcreages__c = 200);
        insert rightAcreage;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', TestInit.accountWrapper.accountRecord.id);

        test.startTest();
        AccountAcreageListController controller = new AccountAcreageListController();
        controller.getAcreageFieldSetManager();
        controller.getAcreageList();

        Test.setCurrentPage(TestInit.customRedirectModifier(controller.newRecord()));
        util.urlParameters = null;
        AccountAcreageListController newController = new AccountAcreageListController();
        for (Acreage acr : (List<Acreage>)newController.wrapperObjects)
        {
            if (acr.isNewAcreage)
            {
                System.assertEquals(Util.DEFAULT_DISTRIBUTOR_ACREAGE_PROVIDER, acr.acreage.AcrProviderRef__c, 
                          'Field AcrProviderRef__c was filled incorrect.');
                acr.acreage.AcrProviderRef__c = provider.Id;
                acr.acreage.AcrTotalAcreages__c = 100;
                acr.acreage.AcrProductGroupRef__c = productGroup.Id;
            }
        }
        
        Boolean anExistProductGroup = false;
        for (SelectOption aProductGroupItem : newController.productGroupItems)
        {
            if (aProductGroupItem.getLabel() == productGroup.Name)
            {
                anExistProductGroup = true;
            }
        }
        System.assert(anExistProductGroup, 'In Group Items picklist doesn\'t contains ' + productGroup.Name + ' name.');
        newController.selectedProductGroup = productGroup.Id;
        newController.updateProductTypeItems();
        
        Boolean anExistProductType = false;
        for (SelectOption aProductTypeItem : newController.productTypeItems)
        {
            if (aProductTypeItem.getLabel() == productType.Name)
            {
                anExistProductType = true;
            }
        }
        System.assert(anExistProductType, 'In Type Items picklist doesn\'t contains ' + productType.Name + ' name.');
        newController.selectedProductType = productType.Id;

        util.urlParameters = null;
        test.setCurrentPage(TestInit.customRedirectModifier(newController.save()));
        AccountAcreageListController controllerAfterSave = new AccountAcreageListController();
        controllerAfterSave.getIsEditButton();
        System.assertequals(true, controllerAfterSave.getIsHasElements());
        List<Acreage> existingAcreages = controllerAfterSave.getMerchandiseManagements();
     //   System.assertEquals(2, existingAcreages.size());
    //    System.assertEquals(100, existingAcreages[1].acreage.AcrTotalAcreages__c);
        System.assertEquals(productGroup.Id, existingAcreages[1].acreage.AcrProductGroupRef__c);
        System.assertEquals(productType.Id, existingAcreages[1].acreage.AcrProductTypeRef__c);
        controllerAfterSave.getMerchandiseManagements()[0].checked = true;

        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterSave.deletex()));
        AccountAcreageListController controllerAfterDelete = new AccountAcreageListController();
        List<Acreage> existingAcreagesAfterDelete = controllerAfterDelete.getMerchandiseManagements();
        System.assertEquals(1, controllerAfterDelete.wrapperObjects.size());
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterDelete.edit()));
        AccountAcreageListController controllerAfterEdit = new AccountAcreageListController();
        controllerAfterEdit.getMerchandiseManagements()[0].acreage.AcrTotalAcreages__c = 1000;
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterEdit.save()));
        AccountAcreageListController controllerFinal = new AccountAcreageListController();
        system.assertEquals(1000, controllerFinal.getMerchandiseManagements()[0].acreage.AcrTotalAcreages__c);
        
        controllerFinal.cancel();
        controllerFinal.getIsList();
        test.stopTest();
    }
}