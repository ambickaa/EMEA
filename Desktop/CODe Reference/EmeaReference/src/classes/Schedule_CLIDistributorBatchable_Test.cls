@isTest
public class Schedule_CLIDistributorBatchable_Test{
    
    // CRON expression: midnight on March 15
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';
     
   public static void additionalDataSetup() {
        //Insert system setting
        SystemSettings__c ss = new SystemSettings__c();
        ss.Name = 'IgnoreTriggers_Cli';
        ss.Value__c = 'false';
        insert ss;
   } 
     
    public static testMethod void test()
    {
        additionalDataSetup();
        
        //Sets up query base for start method in batch
        String q = 'SELECT Id, OwnerId, LKP_Responsible_ST__c FROM Account WHERE RecordType.Name = ' + '\'' + 'Dist./Ret./PoS' + '\'' + ' AND CountryRef__r.Name = ';

        //Define variables in countryList
        String countryList = 'Poland-PL01-005D0000002HsiT-10';
        String country;
        String code;
        String owner;
        List <String> labelCountry= new List<String>();
        List <String> listFortest= new List<String>();
        listFortest.add('Test1');
        listFortest.add('Test2');
        Boolean IsLast;
        
        labelCountry = countryList.split('-');
        country = labelCountry.get(0);
        code = labelCountry.get(1);
        owner = labelCountry.get(2);
        String query = q + '\'' + country + '\'';
        IsLast=false;
                
        //Test Batch        
        Test.startTest();
        CampaignLineItemDistributorBatchable tBatch=new CampaignLineItemDistributorBatchable(query,country,listFortest,listFortest,'Corn',code,owner,'Test','Test', IsLast);
        Database.executeBatch(tBatch);
        Test.stopTest();
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
                                       CRON_EXP, 
                                       new Schedule_CLIDistributorBatchable());
        
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
}