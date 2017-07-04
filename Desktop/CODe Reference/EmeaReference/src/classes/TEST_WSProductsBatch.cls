@isTest(seeAllData=true)
global with sharing class TEST_WSProductsBatch {
    // CRON expression: midnight on March 15.Because this is a test, job executes immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';       
    
    @isTest static void test()
    {
        Division__c division=new Division__c(name='CP');
        year__c year=new year__c(name='2015');
        
        insert division;
        insert year;

        Id pricebookId = Test.getStandardPricebookId();
        pricebook2 pStandard=[select id from pricebook2 where id=:pricebookId];

        List<REL_Factor__c> List_REL_Setting = new List<REL_Factor__c>();
        List_REL_Setting.add(new REL_Factor__c(Name='10109251', REL_Factor__c='680/360'));
        List_REL_Setting.add(new REL_Factor__c(Name='10109252', REL_Factor__c='6.0360'));
        List_REL_Setting.add(new REL_Factor__c(Name='10119202', REL_Factor__c='FAIL'));
        insert List_REL_Setting;
        
        WSProductsBatch ws= new WSProductsBatch();
        MultiStaticResourceCalloutMock multimock  = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(server_urls__c.getInstance('Auth URL').url__c, 'testWStoken');
        multimock.setStaticResource(server_urls__c.getInstance('Product List').url__c+'AG-ES/year/2015?lob=CP&sales-org=ES01&dist-channel=00','testWSProducts');
        multimock.setStatusCode(200);        
        multimock.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, multimock);
        
        list<string> listStr=new list<string>();
        listStr.add('AG-ES#CP#2015#ES01#00');
        WsProductsBatch tBatch=new WSProductsBatch();
        id tjobId;
        id tcjobId;
        MockBatchableContext BC=new MockBatchableContext(tjobId,tcjobId);
        tBatch.execute(BC, listStr);
        
        test.stoptest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new ScheduledProductsBatch());
        
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