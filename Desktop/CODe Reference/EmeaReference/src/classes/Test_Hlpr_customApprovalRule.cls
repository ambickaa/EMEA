@isTest
public class Test_Hlpr_customApprovalRule{

  @testSetup static void methodName()
       {
           
            //Profile Query
           Profile p1 = [SELECT Id FROM Profile WHERE Name='Customer Service'];
           //User Insertion
           User UserTest=new User( Alias='JSEO1231',ManagerId=null, Email='jseoanem1@everis.com',Username='testASC1jseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
           Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           insert UserTest; 
           //Record Type Query
           RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
           //Country Insertion for Account
           Country__c countries=new Country__c(Name='TestCountry111');
             insert countries;
           //Account Insertion
           Account acc = new Account(Name='Account121212'+system.currentTimeMillis(),GC_SAP_ID__c='1233434342132',CountryRef__c=countries.id);
             insert acc;
          
           //Case Approval Rule Insertion
           Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Name='testHlprcustomApprovalRule', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c=null, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
               insert CAR;
           
           Case c=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Automated',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Case_Approval_Rule__c=CAR.id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic',GC_Rebate_settlement_amount_in_LC__c=1000,	GC_Local_currency__c='EUR');
           insert c;
           Case_Approval_Rule__c CAR2=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Name='testHlprcustomApprovalRule1', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c='Parallel', Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
               insert CAR2;
           
           Case c2=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Automated',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Case_Approval_Rule__c=CAR2.id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic',GC_Rebate_settlement_amount_in_LC__c=1000,	GC_Local_currency__c='EUR');
            insert c2;
           List<Case_Approval_Rule__c>CARList=new List<Case_Approval_Rule__c>();
            Case_Approval_Rule__c CAR3=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Approver2__c=UserTest.id,Name='testHlprcustomApprovalRule2', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c='Parallel', Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
               CARList.add(CAR3);
           Case_Approval_Rule__c CAR4=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Approver2__c=UserTest.id,Approver3__c=UserTest.id,Name='testHlprcustomApprovalRule3', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c='Parallel', Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
               CARList.add(CAR4);
           Case_Approval_Rule__c CAR5=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Approver2__c=UserTest.id,Approver3__c=UserTest.id,Approver4__c=UserTest.id,Name='testHlprcustomApprovalRule4', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c='Parallel', Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
               CARList.add(CAR5);
           insert CARList;
           
           
          }
    
       private static testmethod void testcase()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase1()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Sequential';
            update CAR; 
         }
    private static testmethod void testcase2()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            update CAR; 
         }
    private static testmethod void testcase3()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=CAr.Approver10__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase4()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase5()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase6()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase7()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase8()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase9()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase10()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase11()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase12()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase13()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Sequential';
            CAr.Approver1__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase14()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            update CAR; 
         }
    private static testmethod void testcase15()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=CAr.Approver10__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase16()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase17()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase18()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase19()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase20()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase21()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase22()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase23()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=CAr.Approver2__c=u.id; 
            update CAR; 
         }
    private static testmethod void testcase24()
        {
           User u=[select id from user where Alias='JSEO1231' limit 1];
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=null;
            update c;
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            CAR.Parallel_Sequential__c='Parallel';
            CAr.Approver1__c=u.id; 
            update CAR; 
         }
    
    private static testmethod void testcase25()
        {   
            User u=[select id from user where Alias='JSEO1231' limit 1];
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule' limit 1 ]; 
            delete CAR;
         }
     private static testmethod void testcase26()
        {   
            
            User u=[select id from user where Alias='JSEO1231' limit 1];
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule2' limit 1 ]; 
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=CAR.id;
            update c;
            delete CAR;
         }
     private static testmethod void testcase27()
        {   
            User u=[select id from user where Alias='JSEO1231' limit 1];
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule3' limit 1 ]; 
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=CAR.id;
            update c;
            delete CAR;
         }
     private static testmethod void testcase28()
        {   
            User u=[select id from user where Alias='JSEO1231' limit 1];
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='testHlprcustomApprovalRule4' limit 1 ]; 
            Case c=[select id,Case_Approval_Rule__c from case where Case_Approval_Rule__r.Name='testHlprcustomApprovalRule' limit 1];
            c.Case_Approval_Rule__c=CAR.id;
            update c;
            delete CAR;
         }
    
   
   
}