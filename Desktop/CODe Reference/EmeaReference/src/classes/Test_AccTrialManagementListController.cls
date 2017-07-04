@isTest
private class Test_AccTrialManagementListController 
{
    private static testMethod void testAccTrialManagementListController() 
    {
        TestInit.createAccountListController();
        
        Product2 product = TestInit.products[0];
        Account aDist = TestInit.createNewDistributor();
        insert aDist;
        product.ProductVendor__c = aDist.Id;
        product.DivisionRef__c = TestInit.accountWrapper.campaignRecord.DivisionRef__c;
        insert product;
        
        CampaignLineItemGroup__c aCampaignLineItemGroup = new CampaignLineItemGroup__c(
            RecordTypeId = Util.recordType.get('CampaignLineItemGroup__c:Trial'),
            AccountRef__c = TestInit.accountWrapper.accountRecord.id,
            CampaignRef__c = TestInit.accountWrapper.campaignRecord.id,
            Comments__c = 'test');
        insert aCampaignLineItemGroup;
        
        retoure__c toRetoure= new retoure__c(Account__C=TestInit.accountWrapper.accountRecord.id,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure;
        
        CampaignLineItem__c aCampaignLineItem = new CampaignLineItem__c(
            ProductRef__c = product.id,
            RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial'),
            CampaignRef__c = TestInit.accountWrapper.campaignRecord.id,
            FarmRef__c = TestInit.accountWrapper.accountRecord.id,
            CampaignLineItemGroupRef__c = aCampaignLineItemGroup.id,
            Quantity__c = 10000);
        insert aCampaignLineItem;
        
        Test.setCurrentPage(Page.AccountViewDefault);
        Apexpages.currentPage().getParameters().put('id', TestInit.accountWrapper.accountRecord.id);
        Apexpages.currentPage().getParameters().put('division', TestInit.accountWrapper.campaignRecord.DivisionRef__c);
        
        test.startTest();
        AccountTrialManagementListController controller = new AccountTrialManagementListController();
        System.assertEquals(1, controller.getTrialManagements().size());
        
        Test.setCurrentPage(TestInit.customRedirectModifier(controller.newRecord()));
        util.urlParameters = null;
        AccountTrialManagementListController newController = new AccountTrialManagementListController();
        for (CampaignLineItemGroup CLIG : (List<CampaignLineItemGroup>)newController.wrapperObjects)
        {
            if (CLIG.isNewRecord)
            {
                CLIG.lineItems[0].lookupValue = new LookupValue(product.id, 'product');
                CLIG.record.Type__c = 'Test Type';
                CLIG.record.Status__c = 'Forecast';
                CLIG.record.Comments__c = 'comments'; 
                CLIG.lineItems[0].record.Quantity__c = 1000;
            }
        }
        
        util.urlParameters = null;
        
        test.setCurrentPage(TestInit.customRedirectModifier(newController.save()));
        AccountTrialManagementListController controllerAfterSave = new AccountTrialManagementListController();
        controllerAfterSave.getIsEditButton();
        System.assertequals(true, controllerAfterSave.getIsHasElements());
        List<CampaignLineItemGroup> existingCLIGs = controllerAfterSave.getTrialManagements();
        System.assertEquals(2, existingCLIGs.size());
        System.assertEquals('Test Type', existingCLIGs[1].record.Type__c);
        controllerAfterSave.getTrialManagements()[0].checked = true;
        
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterSave.deletex()));
        AccountTrialManagementListController controllerAfterDelete = new AccountTrialManagementListController();
        List<CampaignLineItemGroup> existingCLIGsAfterDelete = controllerAfterDelete.getTrialManagements();
        System.assertEquals(1, controllerAfterDelete.wrapperObjects.size());
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterDelete.edit()));
        AccountTrialManagementListController controllerAfterEdit = new AccountTrialManagementListController();
        controllerAfterEdit.getTrialManagements()[0].record.Type__c = 'New Type';
        
        util.urlParameters = null;
        Test.setCurrentPage(TestInit.customRedirectModifier(controllerAfterEdit.save()));
        AccountTrialManagementListController controllerFinal = new AccountTrialManagementListController();
        system.assertEquals('New Type', controllerFinal.getTrialManagements()[0].record.Type__c);
        
        controllerFinal.cancel();
        controllerFinal.getIsList();
        test.stopTest();
    }
}