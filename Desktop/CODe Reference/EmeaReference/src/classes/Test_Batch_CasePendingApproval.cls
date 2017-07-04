@isTest
public class Test_Batch_CasePendingApproval {
    
    @TestSetup    
    private static void CreateData(){
        RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
        Profile p1 = [select id from profile where name='System Administrator'];
        Map<String,Account> nMap = new Map<String,Account>();
        
        Country__c countries=new Country__c(Name='TestCountry111');
        insert countries;
        
       //Account Insertion
        Account acc = new Account(Name='Account121212'+system.currentTimeMillis(),GC_SAP_ID__c='1233434342132',CountryRef__c=countries.id);
        insert acc;
        
        User UserTest1=new User( Alias='JSEO123', Email='demo@test123.com',Username='testASCjseoanem1@test.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
        insert UserTest1;
        
        User UserTest=new User( ManagerId=UserTest1.Id,Alias='JSEO123', Email='demo1@test123.com',Username='testASCjseoanem@test.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
        Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
        insert UserTest;
       
        Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
        insert CAR;
        
        Case c = new case(FlagNo__c = 0,RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',Parallel_Sequential__c='Sequential',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
        insert c;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically using Trigger');
        req1.setObjectId(c.id); 
        req1.setNextApproverIds(new Id[] {UserTest.id});

        // Submit the approval request for the CASE 
        Approval.ProcessResult result = Approval.process(req1);
   
    }
    
    testMethod private static void testMethod1(){
       Schedule_Batch_CasePendingApproval CasePendingApproval=new Schedule_Batch_CasePendingApproval();
       Test.startTest();
           string sch = (system.now().second()>58?1:system.now().second() + 1) + ' ' + system.now().minute() + ' * * * ?';
           system.schedule('Process Trans 2', sch, CasePendingApproval);
       Test.stopTest();
    }
    
    testMethod private static void testMethodDelayedExec(){
        Test.startTest();
            Schedule_Batch_CasePendingApproval CasePendingApproval=new Schedule_Batch_CasePendingApproval();
            Case c = [SELECT ID,FlagNo__c FROM CASE WHERE GC_Secondary_Reason_Descr__c like 'Customer Accommodation%' limit 1];
            c.FlagNo__c = 1;
            update c;
            ProcessInstance pi = [SELECT Id, Status,TargetObjectId,TargetObject.Name ,(SELECT Id, ActorId,ElapsedTimeInHours, ProcessInstanceId FROM Workitems)  FROM ProcessInstance where  status=:System.Label.ProcessInstanceStatus1 and ProcessDefinition.TableEnumOrId =: 'Case'];
            string sch = (system.now().second()>55?4:system.now().second()+4) + ' ' + system.now().minute() + ' * * * ?';
            system.schedule('Process Trans 1', sch, CasePendingApproval);
        Test.stopTest();
    }
    
    testMethod private static void testMethod3(){
        Test.startTest();
        Schedule_Batch_CasePendingApproval CasePendingApproval=new Schedule_Batch_CasePendingApproval();
        string sch = '0 0 * * 1-12 ? *';
        system.schedule('Process Trans 1', sch, CasePendingApproval);
        Test.stopTest();
     }
}