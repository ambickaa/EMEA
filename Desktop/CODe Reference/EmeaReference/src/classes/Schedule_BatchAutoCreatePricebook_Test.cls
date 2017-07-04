@isTest
private class Schedule_BatchAutoCreatePricebook_Test{

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    public static void data()
    {
         //Insert previous data for orders
         Country__c country = new Country__c(Name = 'testCountry');
         insert country;

         Account account = new Account(Name = 'testAccount', CountryRef__c = country.Id, RecordTypeId = Util.RecordType.get('Account:DistRetPoS'));
         insert account;

         Date tday = Date.today();

         Active_PriceBooks__c ap = new Active_PriceBooks__c (Name = 'AG-AT#CP#2016#CH02#00');

         Order order1 = new Order();
         order1.AccountID=account.Id;
         order1.ShipTo_Acc_Integration_Key__c = account.Id;
         order1.Status='Draft';
         order1.Divison_Code__c='17';
         order1.Sales_District_Code__c='AG-IT';
         order1.Sales_Org_Code__c='IT01';
         order1.GC_Doc_Creation_Date__c = tday;
         order1.GC_Integration_Key__c='SAP00001';
         //order1.GC_Document_Type_Descr__c = docList.get(0);
         order1.EffectiveDate = tday;

         Order order2 = new Order();
         order2.AccountID=account.Id;
         order2.ShipTo_Acc_Integration_Key__c = account.Id;
         order2.Status='Draft';
         order2.Divison_Code__c='15';
         order2.Sales_District_Code__c='AG-IT';
         order2.Sales_Org_Code__c='IT01';
         order2.GC_Doc_Creation_Date__c = tday;
         order2.GC_Integration_Key__c='SAP00001';
         //order1.GC_Document_Type_Descr__c = docList.get(0);
         order2.EffectiveDate = tday;
         insert order2;

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
                        new Schedule_BatchAutoCreatePricebook());
      
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