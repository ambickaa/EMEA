@isTest
private class  InvoicesController1Test{
    
    @testSetup static void createData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='sysadmin@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='sysadmin1z@testorg.com');
        insert u;
        
        Country__c oCountry = new Country__c(Name='India');
        insert oCountry;
        
        Id idRecType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account Global').getRecordTypeId();
        Account oAccount = new Account(Name='Test Acc',RecordTypeId=idRecType,Category__c='Group',CountryRef__c=oCountry.Id);
        insert oAccount ;
        
        Case oCase = new case(accountid=oAccount.id,status='Open',origin='Email',priority='Medium');
        insert oCase;
        
        Invoice__c  oInvoice = new Invoice__c(ShipTo_Acc_Integration_Key__c=oAccount.ID,GC_Payer_Text__c='test'
                                       ,GC_Payer_Descr__c='testPdescription'
                                       ,GC_Account_Integration_Key__c=oAccount.Id,Name='845612354'
                                       ,GC_Order_Number__c='testGCOrderNum',GC_Total_Inv_Amount_Nbr__c=2.0
                                       ,Distribution_Channel_Code__c='DC1',Divison_Code__c='Div1'
                                       ,Sales_Org_Code__c='Org1',GC_Integration_Key__c='1001');
        insert oInvoice;
    }
    
    static testMethod void method1(){
        Case oCase = [SELECT Id FROM Case];
        ApexPages.StandardController sc = new ApexPages.StandardController(oCase);
        ApexPages.currentPage().getParameters().put('Id',oCase.Id);
        
        InvoicesController1 con = new InvoicesController1(sc);
        con.division = 'Div1';
        con.salesOrg = 'Org1';
        con.distributionChannel = 'DC1';
        con.billingDateByMnth = '11';
        con.invTypeDescr = 'PDF';
        List<SelectOption> lstInvTypeDesc = con.lstInvTypeDesc;
        List<SelectOption> lstDistributionChannel = con.lstDistributionChannel;
        con.getQuery();
        con.search();
    }
      
}