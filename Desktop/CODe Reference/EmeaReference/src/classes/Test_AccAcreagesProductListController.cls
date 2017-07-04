@isTest
private class Test_AccAcreagesProductListController {

    static testMethod void TestAccountProductAcreages() 
    {
        TestInit.createAccountListController();
        
        Account provider = TestInit.createNewCompetitor();
        provider.Name = 'Test Account' +al.RandomStringUtils.randomUUID();
        insert provider;
        
        Product_Grouping__c productGroup = new Product_Grouping__c(
            Name = 'test product group');
        insert productGroup;
        
        Product_Grouping__c productType = new Product_Grouping__c(
            Name = 'test product type',
            ProductGroupRef__c = productGroup.Id);
        insert productType;
         
        Acreage__c wrongAcreage = new Acreage__c(
            RecordTypeId = Util.recordType.get('Acreage__c:AcreagesPerProduct'),
            AcrFarmRef__c = TestInit.accountWrapper.accountRecord.id,
            AcrYearRef__c = Util.currentYear.Id,
            AcrTotalAcreages__c = 1000);
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
        AccountAcreagesProductListController controller = new AccountAcreagesProductListController();
        controller.getAcreageFieldSetManager();
        controller.getAcreageList();
        System.assertEquals(1, controller.getMerchandiseManagements().size());
        
        Test.setCurrentPage(TestInit.customRedirectModifier(controller.newRecord()));
        util.urlParameters = null;
        AccountAcreagesProductListController newController = new AccountAcreagesProductListController();
        for (Acreage acr : (List<Acreage>)newController.wrapperObjects)
        {
            if (acr.isNewAcreage)
            {
                acr.acreage.AcrProviderRef__c = provider.Id;
                acr.acreage.AcrTotalAcreages__c = 100;
                acr.acreage.AcrProductGroupRef__c = productGroup.Id;
            }
        }

        util.urlParameters = null;
        test.setCurrentPage(TestInit.customRedirectModifier(newController.save()));
        AccountAcreagesProductListController controllerAfterSave = new AccountAcreagesProductListController();
        controllerAfterSave.getIsEditButton();
        System.assertequals(true, controllerAfterSave.getIsHasElements());
        List<Acreage> existingAcreages = controllerAfterSave.getMerchandiseManagements();
      //  System.assertEquals(2, existingAcreages.size());
      //  System.assertEquals(100, existingAcreages[1].acreage.AcrTotalAcreages__c);
        controllerAfterSave.getMerchandiseManagements()[0].checked = true;

        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterSave.deletex()));
        AccountAcreagesProductListController controllerAfterDelete = new AccountAcreagesProductListController();
        List<Acreage> existingAcreagesAfterDelete = controllerAfterDelete.getMerchandiseManagements();
        System.assertEquals(1, controllerAfterDelete.wrapperObjects.size());
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterDelete.edit()));
        AccountAcreagesProductListController controllerAfterEdit = new AccountAcreagesProductListController();
        controllerAfterEdit.getMerchandiseManagements()[0].acreage.AcrTotalAcreages__c = 1000;
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterEdit.save()));
        AccountAcreagesProductListController controllerFinal = new AccountAcreagesProductListController();
        system.assertEquals(1000, controllerFinal.getMerchandiseManagements()[0].acreage.AcrTotalAcreages__c);
        
        controllerFinal.cancel();
        controllerFinal.getIsList();
        test.stopTest();
    }
}