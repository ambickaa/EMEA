@isTest
private class AccountAcreageControllerTest
{
    static
    {
        MixedDMLOps.add( Testinit.farmers );
        MixedDMLOps.ins();
        for(Acreage__c a : Testinit.acreages)
        {
          a.AcrFarmRef__c = Testinit.farmers.get(0).id;
        }
        
        MixedDMLOps.ins();
        Testinit.getDivision('Corn');
        TestInit.setYear( 1 );
		
		Product_Grouping__c OSRGroup = new Product_Grouping__c(Name='OSR', RecordTypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
		Product_Grouping__c CornGroup = new Product_Grouping__c(Name='Corn', RecordTypeId=Util.recordType.get('Product_Grouping__c:ProductGroup'));
		insert new List<Product_Grouping__c> {OSRGroup, CornGroup};
		
		Product_Grouping__c GrainType = new Product_Grouping__c(Name='Grain', ProductGroupRef__c=CornGroup.Id, RecordTypeId=Util.recordType.get('Product_Grouping__c:ProductType'));
		insert GrainType;
		
		Acreage__c acr1 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Testinit.farmers.get(0).Id, AcrYearRef__c=Util.currentYear.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=CornGroup.Id, AcrProductTypeRef__c=GrainType.Id);
		Acreage__c acr2 = new Acreage__c(RecordTypeId=Util.recordType.get('Acreage__c:AcreagesPerProductGroup'), AcrFarmRef__c=Testinit.farmers.get(0).Id, AcrYearRef__c=Util.currentYear.Id, AcrTotalAcreages__c=100, AcrProductGroupRef__c=OSRGroup.Id);
		insert new List<Acreage__c> {acr1, acr2};
		
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }

    static testMethod void basicTest()
    {
      insert  Testinit.acreages;
      AccountAcreageController controller = new AccountAcreageController();
      controller.getConstructor();
      AccountAcreageController.getFields();
      System.debug(controller.productTypeWithGroup);
      controller.getTranslationsMap();
      
      controller.doSave();
      controller.doNew();
      controller.doCancel();
      
      controller.acreagesToDelete = '0';
      controller.doDelete();
      System.debug(controller.showNew);
      System.debug(controller.showEdit);
      System.debug(controller.showDelete);
      //TestAccountInterface.basicTest( new AccountAcreageController() );
      //controller.getAcreageList();
    }
}