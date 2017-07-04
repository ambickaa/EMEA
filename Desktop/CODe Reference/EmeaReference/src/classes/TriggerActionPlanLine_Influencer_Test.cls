@isTest
private class TriggerActionPlanLine_Influencer_Test {

    //***********************************************************************************************************
    // RECORDS CREATION: 
    //***********************************************************************************************************
    
    private static void Test_Ini() {

    //***********************************************************************************************************
    //  GET DISTRIBUTOR RECORDTYPE
    //***********************************************************************************************************
        String RTDistributor=Util.recordType.get('Account:DistRetPoS');

    //***********************************************************************************************************
    //  ACCOUNTS: 
    //  - Creation of 4 accounts.
    //  - Define "Account 4" as the influencer of Accounts 1 & 2
    //***********************************************************************************************************

        Account Acc1 = new Account (Name='Account 1', RecordTypeId=RTDistributor);
        Account Acc2 = new Account (Name='Account 2', RecordTypeId=RTDistributor);
        Account Acc3 = new Account (Name='Account 3', RecordTypeId=RTDistributor);
        Account Acc4 = new Account (Name='Account 4', RecordTypeId=RTDistributor, GC_Integration_Key__c='1000001');
        Account Acc5 = new Account (Name='Account 5', RecordTypeId=RTDistributor);

        Insert new List<Account>{Acc1, Acc2, Acc3, Acc4, Acc5};

        Acc1.Influencer__c = Acc4.Id;
        Acc2.Influencer__c = Acc4.Id;
        Acc3.Influencer__c = Acc5.Id;

        Update new List<Account>{Acc1, Acc2, Acc3};

    //***********************************************************************************************************
    //  PRODUCTS
    //***********************************************************************************************************

        Product2 Pr1 = new Product2(Name='Product 1', isActive=true);
        Insert Pr1;

    //***********************************************************************************************************
    //  ACTION PLAN LINES
    //***********************************************************************************************************

       Action_Plan_Line__c APL1 = new Action_Plan_Line__c(LKP_SKU__c=Pr1.ID, LKP_Account__c=Acc1.Id, NUM_Forecast__c=10, NUM_Final_stock__c=30, PICK_Period__c='2000-06');
       Action_Plan_Line__c APL2 = new Action_Plan_Line__c(LKP_SKU__c=Pr1.ID, LKP_Account__c=Acc2.Id, NUM_Forecast__c=20, NUM_Final_stock__c=20, PICK_Period__c='2000-06');
       Action_Plan_Line__c APL3 = new Action_Plan_Line__c(LKP_SKU__c=Pr1.ID, LKP_Account__c=Acc3.Id, NUM_Forecast__c=30, NUM_Final_stock__c=10, PICK_Period__c='2000-06');

       insert new List<Action_Plan_Line__c>{APL1, APL2, APL3};

    //***********************************************************************************************************
    //  ASSERT: Forecast and Final Stock of influencer's Action plan lines
    //***********************************************************************************************************

        for (Action_Plan_Line__c APL : [SELECT Id, LKP_SKU__c, LKP_Account__c, NUM_Forecast__c, NUM_Final_stock__c,PICK_Period__c FROM Action_Plan_Line__c WHERE LKP_SKU__c=: Pr1.Id]){

            if(APL.LKP_Account__c==Acc4.Id && APL.PICK_Period__c=='2000-06')
                system.assertEquals(30, APL.NUM_Forecast__c);
            if(APL.LKP_Account__c==Acc4.Id && APL.PICK_Period__c=='2000-06')
                system.assertEquals(50, APL.NUM_Final_stock__c);
        }

    //***********************************************************************************************************
    //  ASSERT: Account 5 has no SAP code, therefore it has no APL
    //***********************************************************************************************************

        List<Action_Plan_Line__c> List_APL_Acc5 = new List<Action_Plan_Line__c>();

        List_APL_Acc5 = [SELECT Id FROM Action_Plan_Line__c WHERE LKP_Account__c=: Acc5.Id];

        system.assertEquals(0, List_APL_Acc5.size());
        

    //***********************************************************************************************************
    //  DELETE 1 ACTION PLAN LINE
    //***********************************************************************************************************

        delete APL2;
    }

    static testMethod void aggregateNumbers() {

        Test.StartTest();
        Test_Ini();
        Test.StopTest();

    }
}