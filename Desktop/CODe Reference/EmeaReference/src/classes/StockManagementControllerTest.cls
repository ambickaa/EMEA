@isTest
private class StockManagementControllerTest {

    static testMethod void Deletions() {
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        StockManagementController Controller= new StockManagementController();
        String modet= Controller.mode;
        Controller.SelectedStockId=Test_REST_DataFactoryEast.Sto.id;
        Controller.doDelete();
        Test.stopTest();
    }
    static testMethod void Searchmethod() {
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        StockManagementController Controller= new StockManagementController();
        Controller.productFilter = Test_REST_DataFactoryEast.pce;
        Controller.stock=Test_REST_DataFactoryEast.Sto;
        List<Schema.FieldSetMember> NewList= Controller.stockfields;
        List<Stock__c> Slt= Controller.stockList;
        Controller.previous();
        Boolean HP = Controller.hasPrevious;
        Controller.next();
        Boolean HN = Controller.hasNext;
        System.Assert(HN==False); 
        System.Assert(HP==False);
        Integer PNT= Controller.pageNumber;
        Test.stopTest();
    }
    
    static testMethod void DBS() {
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        StockManagementController Controller= new StockManagementController();
        Controller.productFilter = Test_REST_DataFactoryEast.pce;
        Controller.stock=Test_REST_DataFactoryEast.Sto;
        List<Schema.FieldSetMember> NewList= Controller.stockfields;
        Controller.doSave();
        Test.stopTest();
    }
    
    static testMethod void SPCET() {
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        StockManagementController Controller= new StockManagementController();
        List<Schema.FieldSetMember> SFNT = Controller.stockFieldsNew;
        Controller.searchPCE();
        List<Schema.FieldSetMember> PCFT= Controller.prodCatFields;
        boolean sdlt= Controller.showDelLast;
        Controller.dosavenew();
        Controller.donew();
        Controller.docancelnew();
        Controller.SelectedPCE= String.ValueOf(Test_REST_DataFactoryEast.pce.id);
        Controller.selectPCE();
        Controller.addNewStockLine();
        Controller.delLastNew();
        PageReference STR= Controller.switchToRegular();
        PageReference STT= Controller.switchToTax();
        Boolean irt= controller.isregular;
        Test.stopTest();
        
    }    
}