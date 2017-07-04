@isTest
private class  OrdersController1Test{
    
    @testSetup static void createDataforClass(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='sysadmin@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='sysadmin12z@testorg.com');
        insert u;
        
        Country__c oCountry = new Country__c(Name='India');
        insert oCountry;
        
        Id idRecType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account Global').getRecordTypeId();
        Account oAccount = new Account(Name='Test Acc',RecordTypeId=idRecType,Category__c='Group',CountryRef__c=oCountry.Id);
        insert oAccount ;
        
        Case oCase = new Case(accountid=oAccount.id,status='Open',priority='Medium',origin='Email');
        insert oCase;
        
        Order oOrder = new Order(ShipTo_Acc_Integration_Key__c=oAccount.Id,AccountId=oAccount.Id
                                 ,GC_Ship_To_Party_Descr__c='test description',Name='testOrder'
                                 ,PoNumber='TestPONumber',GC_Document_Type_Descr__c='testDocumetType'
                                 ,GC_Open_Order_Qty__c  =123.000,GC_Integration_Key__c='123456793'
                                 ,Distribution_Channel_Code__c='DC1',EffectiveDate=Date.today()-2
                                 ,status='Draft');
        insert oOrder;
    }
    
    static testMethod void TestOrdersController(){
        Case oCase = [SELECT Id FROM Case];
        ApexPages.StandardController sc = new ApexPages.StandardController(oCase);
        ApexPages.currentPage().getParameters().put('Id',oCase.Id);
        
        OrdersController1 con = new OrdersController1(sc);
        con.division = 'Div1';
        con.salesOrg = 'Org1';
        con.distributionChannel = 'DC1';
        con.requestedDlvrDateByMnth = '11';
        con.documentTypeDescr = 'PDF';
        List<SelectOption> lstDocTypeDesc = con.lstDocTypeDesc;
        List<SelectOption> lstDistributionChannel = con.lstDistributionChannel;
        List<SelectOption> lstMonths = con.lstMonths;
        List<SelectOption> lstSalesOrg = con.lstSalesOrg;
        List<SelectOption> lstDivisionCode = con.lstDivisionCode;
        con.search();
        //Integer totalRecords = con.totalRecords;
        con.next();
        con.previous();
        Boolean booHasNext = con.hasNext;
        Boolean booHasPrevious = con.hasPrevious;
        Report oReport = con.getReport(Label.Account_with_Standard_Order);
    }
      
}