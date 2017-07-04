@isTest
private class ScheduleCampaignSalesUpdate_Test {

   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   public static void data()
   {
       SystemSettings__c Test_SystemSettings = new SystemSettings__c();
       Test_SystemSettings.Name = 'IgnoreTriggers_Campaign';
       Test_SystemSettings.Value__c = 'true';
       insert Test_SystemSettings;

       Division__c Test_Division = new Division__c(Name = 'x');
       insert Test_Division;
       
       Country__c Test_Country = new Country__c(Name = 'HQ');
       insert Test_Country;

       Year__c Test_Year = new Year__c(Name = String.valueof(system.today().year()),
                               YearStartDate__c = system.today().addDays(-1),
                               YearEndDate__c = system.today().addDays(1));
       insert Test_Year;
       
       List<Campaign> List_Campaigns = new List<Campaign>();
       
       // --------------------------
       // 100: Future
       // --------------------------
       List_Campaigns.add(new Campaign(RecordTypeId = Util.RecordType.get('Campaign:Sales_camp'),
                               Name = 'HQ - x - ' + String.valueof(system.today().year()) + ' - ' + Util.currentUser.Name,
                               DivisionRef__c = Test_Division.Id,
                               CountryRef__c = Test_Country.Id,
                               YearV2__c = Test_Year.Id,
                               OwnerId = Util.currentUser.Id,
                               ArchiveDate__c = system.today().addDays(3),
                               StartDate = system.today().addDays(1),
                               EndDate = system.today().addDays(2),
                               Statuscode__c = 200,
                               IsActive = true));
       
       // --------------------------
       // 200: Active
       // --------------------------
       List_Campaigns.add(new Campaign(RecordTypeId = Util.RecordType.get('Campaign:Sales_camp'),
                               Name = 'HQ - x - ' + String.valueof(system.today().year()) + ' - ' + Util.currentUser.Name,
                               DivisionRef__c = Test_Division.Id,
                               CountryRef__c = Test_Country.Id,
                               YearV2__c = Test_Year.Id,
                               OwnerId = Util.currentUser.Id,
                               ArchiveDate__c = system.today().addDays(2),
                               StartDate = system.today().addDays(-1),
                               EndDate = system.today().addDays(1),
                               Statuscode__c = 100,
                               IsActive = false));

       // --------------------------
       // 300: Closed
       // --------------------------
       List_Campaigns.add(new Campaign(RecordTypeId = Util.RecordType.get('Campaign:Sales_camp'),
                               Name = 'HQ - x - ' + String.valueof(system.today().year()) + ' - ' + Util.currentUser.Name,
                               DivisionRef__c = Test_Division.Id,
                               CountryRef__c = Test_Country.Id,
                               YearV2__c = Test_Year.Id,
                               OwnerId = Util.currentUser.Id,
                               ArchiveDate__c = system.today().addDays(1),
                               StartDate = system.today().addDays(-2),
                               EndDate = system.today().addDays(-1),
                               Statuscode__c = 200,
                               IsActive = true));
                               
       // --------------------------
       // 400: Archived
       // --------------------------
       List_Campaigns.add(new Campaign(RecordTypeId = Util.RecordType.get('Campaign:Sales_camp'),
                               Name = 'HQ - x - ' + String.valueof(system.today().year()) + ' - ' + Util.currentUser.Name,
                               DivisionRef__c = Test_Division.Id,
                               CountryRef__c = Test_Country.Id,
                               YearV2__c = Test_Year.Id,
                               OwnerId = Util.currentUser.Id,
                               ArchiveDate__c = system.today().addDays(-1),
                               StartDate = system.today().addDays(-3),
                               EndDate = system.today().addDays(-2),
                               Statuscode__c = 200,
                               IsActive = false));
                               
       // --------------------------
       // 200: Active and correct. It must not be updated by the batch.
       // --------------------------
       List_Campaigns.add(new Campaign(RecordTypeId = Util.RecordType.get('Campaign:Sales_camp'),
                               Name = 'HQ - x - ' + String.valueof(system.today().year()) + ' - ' + Util.currentUser.Name,
                               DivisionRef__c = Test_Division.Id,
                               CountryRef__c = Test_Country.Id,
                               YearV2__c = Test_Year.Id,
                               OwnerId = Util.currentUser.Id,
                               ArchiveDate__c = system.today().addDays(2),
                               StartDate = system.today().addDays(-1),
                               EndDate = system.today().addDays(1),
                               Statuscode__c = 200,
                               IsActive = true));
                               
       insert List_Campaigns;
       
       Test_SystemSettings.Value__c = 'false';
       update Test_SystemSettings;

   } 

   static testmethod void test()
   {
   
      data();
   
      Test.startTest();
      
      // --------------------------
      // Schedule the test job
      // --------------------------
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ScheduleCampaignSalesUpdate());
      
      // --------------------------
      // Get the information from the CronTrigger API object
      // --------------------------
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
         
      // --------------------------
      // Verify the expressions are the same
      // --------------------------
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);
         
      // --------------------------
      // Verify the job has not run
      // --------------------------
      System.assertEquals(0, ct.TimesTriggered);

      // --------------------------
      // Verify the next time the job will run
      // --------------------------
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));

      Test.stopTest();

   }
}