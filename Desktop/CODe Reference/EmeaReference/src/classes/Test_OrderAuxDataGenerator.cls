@isTest
global with sharing class Test_OrderAuxDataGenerator {
     // CRON expression: midnight on March 15.Because this is a test, job executes immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';   
    @isTest static  void testController()
    {                
        /*----------- Test Data Creation----------------------*/
        
        
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
        RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' and Name='Sales Order CP' limit 1];
        RecordType opprt2=[Select id,Name from RecordType where SobjectType='Opportunity' and Name='Transfer Order' limit 1];
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User cUser=new user(country='France',TXT_Division__c='15',SAP_Partner_Code__c='111222333',Division='CP',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
        User cUser2=new user(country='Italy',TXT_Division__c='15',SAP_Partner_Code__c='111222336',Division='CP',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
        insert cUser;
        system.runAs(cUser){        
            Country__C counT=new Country__C(name='TestCountry');
            insert counT;
            
            Account testAccount1=new Account(RecordType=rt,GC_SAP_ID__c='7654321',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount2=new Account(RecordType=rt,GC_SAP_ID__c='3456789',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount3=new Account(RecordType=rt,GC_SAP_ID__c='3456780',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            Account testAccount4=new Account(RecordType=rt,GC_SAP_ID__c='3456781',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=counT.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
            insert testAccount1;            
            insert testAccount2;
            insert testAccount3;
            insert testAccount4;
            
            Sales_Area__c area=new Sales_Area__c(name='ES01/00/15');
            Sales_Area__c area2=new Sales_Area__c(name='IT01/00/15');
            insert Area;    
            Partner_Function__c testShipTo2=new Partner_Function__c(Partner_function_descr__c='WE/Ship-to Party' ,Country_Name__c='France',Partner_Function_Code__c='WE',Relation_Type_Descr__c='Ship-to Party',name='testShipTo',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='03456789');            
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
            insert testShipTo2;
            
            Partner_Function__c testShipTo3=new Partner_Function__c(Partner_Function_Code__c='YB',Country_Name__c='France',Partner_function_descr__c='YB/Area Manager',Relation_Type_Descr__c='YB - Area Manager',name='testShipTo3',Primry_Acct_Integration_Key__c=testAccount1.Id,Partner_SAP_ID__c='0111222333');            
            testShipTo2.Sales_Area_Integration_Key__c=area.id;
            insert testShipTo3;
            
            Partner_Function__c testShipTo4=new Partner_Function__c(Partner_function_descr__c='WE/Ship-to Party' ,Country_Name__c='Italy',Partner_Function_Code__c='WE',Relation_Type_Descr__c='Ship-to Party',name='testShipTo',Primry_Acct_Integration_Key__c=testAccount3.Id,Partner_SAP_ID__c='0003456780');            
            testShipTo4.Sales_Area_Integration_Key__c=area2.id;
            insert testShipTo4;
            
            Partner_Function__c testShipTo5=new Partner_Function__c(Partner_Function_Code__c='YA',Country_Name__c='Italy',Partner_function_descr__c='YA/Sales Representative',Relation_Type_Descr__c='YA - Sales Representative',name='testShipTo3',Primry_Acct_Integration_Key__c=testAccount3.Id,Partner_SAP_ID__c='0111222336');            
            testShipTo5.Sales_Area_Integration_Key__c=area2.id;
            insert testShipTo5;
          
            id job=database.executeBatch(NEW OrderAuxDataGenerator(),4);
          } } 
        @isTest static  void testController2()
    {    
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new ScheduledSAPcodeToPartners());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', 
                            String.valueOf(ct.NextFireTime));
        
        
        
        
    }
    global class MockBatchableContext implements Database.BatchableContext {
        private Id jobId;
        private Id childJobId;
        public MockBatchableContext(Id jobId, Id childJobId) {
            this.jobId = jobId;
            this.childJobId = childJobId;
        }
        public Id getJobId() {
            return jobId;
        }
        public Id getChildJobId() {
            return childJobId;
        }     
    }
    
    
}