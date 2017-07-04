@isTest
private class  DeliveriesControllerTest{
    
    @testSetup static void createData(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt; 
        User u = new User(Alias = uniqueName.substring(18, 23), Email='sysadmin@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
        insert u;
        
        Country__c oCountry = new Country__c(Name='India');
        insert oCountry;
        
        Id idRecType = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Account Global').getRecordTypeId();
        Account oAccount = new Account(Name='Test Acc',RecordTypeId=idRecType,Category__c='Group',CountryRef__c=oCountry.Id);
        insert oAccount ;
        
        Delivery__c oDelivery = new Delivery__c(ShipTo_Acc_Integration_Key__c=oAccount.Id
                                        ,GC_Account_Integration_Key__c=oAccount.Id
                                        ,Name='12345678925',GC_Order_Number__c='12345678927'
                                        ,Distribution_Channel_Code__c='DC1'
                                        ,GC_Ovrall_Delvy_Stat_Descr__c='testDesc'
                                        ,Divison_Code__c='Div1',Sales_Org_Code__c='Org1'
                                        ,GC_Integration_Key__c='2001');
        insert oDelivery;
        
        Delivery_Line_Item__c d1 = new Delivery_Line_Item__c(Name = '900001',
                                    GC_Dlvry_Integration_Key__c= oDelivery.id,
                                    //GC_SKULine_Item_Nbr__c = '900001',
                                    GC_Integration_Key__c ='900001',
                                    GC_Item_Code__c ='123'
                                    );
       insert d1;
       
       Delivery_Line_Item__c d2 = new Delivery_Line_Item__c(Name = '900002',
                                    GC_Dlvry_Integration_Key__c= oDelivery.id,
                                    //GC_SKULine_Item_Nbr__c = '900001',
                                    GC_Integration_Key__c ='900002',
                                    GC_Item_Code__c ='123'
                                    );
       insert d2;
    }
    
    static testMethod void TestOrdersController(){
        Account oAccount = [SELECT Id FROM Account];
        ApexPages.StandardController sc = new ApexPages.StandardController(oAccount);
        ApexPages.currentPage().getParameters().put('accountId',oAccount.Id);
        
        DeliveriesController con = new DeliveriesController(sc);
        con.division = 'Div1';
        con.salesOrg = 'Org1';      
        con.distributionChannel = 'DC1';
        con.dlvryStatusDescr = 'testDesc';
        con.dlvryDateByMnth = '9';
        List<SelectOption> lstDlvryStatusDesc = con.lstDlvryStatusDesc;
        List<SelectOption> lstDistributionChannel = con.lstDistributionChannel;
        con.getQuery();
        con.search();
    }
      
}