/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_Everis_ACS_deploy_3 {
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        SystemSettings__c s1 = new SystemSettings__c( Name='VAT_RSA',Value__C='1');
        
        SystemSettings__c s2 = new SystemSettings__c( Name='RSA_DISABLE_COPY_FIELDS_YES_NO',Value__C='No');
        
        SystemSettings__c s3 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='10');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3};
            
            insert ssList;
        list<DiscountMasterTable_RSA__c> param= new list<DiscountMasterTable_RSA__c>();
        Country__c c = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
        year__c year=new year__c(name='2015');
        insert year;
        Account Farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm');
        insert Farm;
        
        DiscountMasterTable_RSA__c dis=new DiscountMasterTable_RSA__c(name='04 - April - East',AdditionalDiscount_RSA__c=7,Year_RSA__c=year.Id, Type_RSA__c='Early payment');
        insert dis;
        DiscountMasterTable_RSA__c dis2=new DiscountMasterTable_RSA__c(name='04 - April - East2',AdditionalDiscount_RSA__c=7,Year_RSA__c=year.Id, Type_RSA__c='Early payment');
        insert dis2;
        DiscountMasterTable_RSA__c dis3=new DiscountMasterTable_RSA__c(name='04 - April - East3',AdditionalDiscount_RSA__c=7,Year_RSA__c=year.Id, Type_RSA__c='Early confirmation');
        insert dis3;
        DiscountMasterTable_RSA__c dis4=new DiscountMasterTable_RSA__c(name='04 - April - East4',AdditionalDiscount_RSA__c=7,Year_RSA__c=year.Id, Type_RSA__c='Early confirmation');
        insert dis4;
        
        
        
        
        integer cont=10;        
        List<Order__c> poList = new List<Order__c>();
        for (integer i=0;i<cont;i++){
            Order__c ord = new Order__c( AccountRef_RSA__c=Farm.id, Status_RSA__c='Draft',EarlyPayment_RSA__c =dis.Id,EarlyDelivery_RSA__c =dis3.Id,
                                        RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'), shouldCopy_RSA__c=true,VAT_RSA__c=7,isIrrigated_RSA__c=False); 
            
            poList.add(ord);
        }
        insert poList; 
        List<Order__c> upList = new List<Order__c>();
        
        for (Order__c ord:poList)
        {
            ord.EarlyPayment_RSA__c=dis2.Id;
            ord.EarlyDelivery_RSA__c=dis4.Id;
            upList.add(ord);
        }
        update upList;
        
        
        
        
    }
    /*
    static testMethod void myUnitTest2() 
    {
        Test_REST_DataFactoryEast.TestData();
        Datetime limitD=Datetime.newInstance(2011, 2, 17);
       
        REST_LogicalEntityAccountController.getAccounts(limitD);
        
    }
        static testMethod void myUnitTest3() 
    {

        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
        country__c coun=new country__c(name='Britain');
        insert coun;
        
        Account testAccount1=new Account(RecordType=rt,Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=coun.Id ,IdDevice__c=12.0,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56);
        insert testAccount1;
        Account testAccount2=new Account(RecordType=rt,Name='Account2',Category__c='asdfg',GC_Status_Descr__c='asdx',IdDevice__c=12.0,CountryRef__c=coun.Id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56,TotalOtherAcreagesManualCY__c=100);
        Contact testContact1=new Contact(lastName='testContact1',Account=testAccount1);
        insert testContact1;
        Contact testContact2=new Contact(lastName='testContact2',Account=testAccount2); 
        Contact testContact3=new Contact(lastName='testContact2',Account=testAccount1);
        
        REST_SendLogicalEntityAccountController.REST_AccountObject  accountForTest = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        accountForTest.account=testAccount1;
        accountForTest.action='Insert';
        
        REST_SendLogicalEntityAccountController.REST_AccountObject  accountForTest2 = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        accountForTest2.account=testAccount1;
        accountForTest2.action='Update';
        
        REST_SendLogicalEntityAccountController.REST_AccountObject  accountForTest3 = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        accountForTest3.account=testAccount1;
        accountForTest3.action='Delete';
        
        REST_SendLogicalEntityAccountController.REST_AccountObject accountForTest4 = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        accountForTest4.account=testAccount2;
        accountForTest4.action='Insert';
        
        REST_SendLogicalEntityAccountController.REST_AccountObject accountForTest5 = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        accountForTest5.account=testAccount2;
        accountForTest5.action='Update';
        
        //REST_SendLogicalEntityAccountController.REST_AccountObject accountForTest6 = new REST_SendLogicalEntityAccountController.REST_AccountObject();
        //accountForTest6.account=testAccount2;
        //accountForTest6.action='Delete';
        
        REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        contactForTest.contact=testContact1;
      	contactForTest.action='Insert';
        
        REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest2 = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        contactForTest2.contact=testContact1;
      	contactForTest2.action='Update';
        
        REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest3 = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        contactForTest3.contact=testContact1;
      	contactForTest3.action='Delete';
                
        REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest4 = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        contactForTest4.contact=testContact2;
      	contactForTest4.action='Insert';
        
        REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest5 = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        contactForTest5.contact=testContact2;
      	contactForTest5.action='Update';
        
        //REST_SendLogicalEntityAccountController.REST_ContactObject contactForTest6 = new REST_SendLogicalEntityAccountController.REST_ContactObject();
        //contactForTest6.contact=testContact2;
      	//contactForTest6.action='Delete';
        
        List<REST_SendLogicalEntityAccountController.REST_AccountObject> accsT=new list<REST_SendLogicalEntityAccountController.REST_AccountObject>();
        accsT.add(accountFortest);
        accsT.add(accountFortest2);
        accsT.add(accountFortest3);
		accsT.add(accountFortest4);
        accsT.add(accountFortest5);
        //accsT.add(accountFortest6);
		
        List<REST_SendLogicalEntityAccountController.REST_AccountObject> accsT2=new list<REST_SendLogicalEntityAccountController.REST_AccountObject>();
        accsT2.add(accountFortest4);
        accsT2.add(accountFortest2);
        

        
		List<REST_SendLogicalEntityAccountController.REST_ContactObject> contactsT=new list<REST_SendLogicalEntityAccountController.REST_ContactObject>();  
        contactsT.add(contactFortest);
        contactsT.add(contactFortest2);
        contactsT.add(contactFortest3);
        contactsT.add(contactFortest4);
        contactsT.add(contactFortest5);
        //contactsT.add(contactFortest6);
        
        List<REST_SendLogicalEntityAccountController.REST_ContactObject> contactsT2=new list<REST_SendLogicalEntityAccountController.REST_ContactObject>();  
        contactsT2.add(contactFortest4);
       // contactsT2.add(contactFortest2);
        
        
        REST_SendLogicalEntityAccountController.REST_SendLogicalEntityAccount accSendForTest = new REST_SendLogicalEntityAccountController.REST_SendLogicalEntityAccount();
        accSendForTest.accounts=accsT;
        accSendForTest.contacts=contactsT;
        REST_SendLogicalEntityAccountController.sendAccounts(accSendForTest);
        
        REST_SendLogicalEntityAccountController.REST_SendLogicalEntityAccount accSendForTest2 = new REST_SendLogicalEntityAccountController.REST_SendLogicalEntityAccount();
        accSendForTest2.accounts=accsT2;
        accSendForTest2.contacts=contactsT2;
        REST_SendLogicalEntityAccountController.sendAccounts(accSendForTest2);
    }
    */
}