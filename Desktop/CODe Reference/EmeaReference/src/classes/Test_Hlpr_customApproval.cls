@isTest
private class Test_Hlpr_customApproval {
     
       @testSetup static void methodName()
       {
           //Profile Query
           Profile p1 = [SELECT Id FROM Profile WHERE Name='Customer Service'];
           //User Insertion
           User UserTest=new User( Alias='JSEO123',ManagerId=null, Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
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
           
           //Case Insertion
           Case c=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Automated',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic',GC_Rebate_settlement_amount_in_LC__c=1000,	GC_Local_currency__c='EUR');
             insert c;
           Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(	Approver1__c=UserTest.id,Name='TestHlprcustomApproval', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Parallel_Sequential__c='Parallel', Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR;
           c.Approval_Validation_1__c=False;
           update c;
             
        }  
        
        private static testmethod void testcase()
        {
           case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
        
    private static testmethod void testcase2()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase4()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase5()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase6()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval'  limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase7()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         } 
    private static testmethod void testcase8()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval'  limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         } 
    private static testmethod void testcase9()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase10()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval'  limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase11()
        {
            User u=[select id from user where Alias='JSEO123' limit 1];
            
            Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
            CAr.Approver1__c=CAr.Approver2__c=CAr.Approver3__c=CAr.Approver4__c=CAr.Approver5__c=CAr.Approver6__c=CAr.Approver7__c=CAr.Approver8__c=CAr.Approver9__c=CAr.Approver10__c=u.id; 
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated'  and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
    private static testmethod void testcase3()
        {
           Case_Approval_Rule__c CAR=[Select Name, Case_Reason__c, Secondary_Reason__c, Parallel_Sequential__c, Approval_Amount_Min__c, Approval_Amount_Max__c, Sales_District__c, Product_Group__c from Case_Approval_Rule__c where Name='TestHlprcustomApproval' limit 1 ]; 
           CAR.Parallel_Sequential__c='Sequential';
           update CAR; 
            case c=[select id,Approval_Type__c from case where Approval_Type__c='Automated' and Case_Approval_Rule__r.Name='TestHlprcustomApproval' limit 1];
           c.GC_Secondary_Reason_Descr__c='Rebate Settlements';
           update c;
         }
       /* private static testmethod void testcase1()
        {
            RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Map<String,Account> nMap = new Map<String,Account>();
            Account acc=TestUtilities.getAccount(nMap,True);
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            Profile p1 = [select id from profile where name='System Administrator'];
            User UserTest=new User( Alias='JSEO123',ManagerId=null, Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           insert UserTest;
                Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR;
                Case c=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Automated',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id);
                insert c;
                c.Approval_Type__c='Manual';
                update(c);
                
                
        }*/
        /*private static testmethod void testcase2()
        {
            RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            
            Map<String,Account> nMap = new Map<String,Account>();
            Account acc=TestUtilities.getAccount(nMap,True);
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            Profile p1 = [select id from profile where name='System Administrator'];
            User UserTest=new User( Alias='JSEO123',ManagerId=null, Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           
                Case_Approval_Rule__c CAR1=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Rebate Settlements', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Parallel', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=100, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR1;
                //Case_Approval_Rule__c CAR2=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Rebate Settlements', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Parallel', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=null, Approval_Amount_Min__c=0, Approval_Amount_Max__c=100, Sales_District__c='Multiple', Product_Group__c='Multiple');
                //insert CAR2;
                Case c1=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Rebate Settlements',Reason='Programs/Compensation',Approval_Type__c='Automated',GC_No_ofCust_for_CA__c=11,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id);
                insert c1;
                c1.Approval_Type__c='Manual';
                
                update c1;
        }*/
        
    
      /* private static testmethod void testcase1()
        {
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Service Case'].Id;
            Map<String,Account> nMap = new Map<String,Account>();
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            
            User UserTest=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
             
             Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
             insert CAR;
             Case_Approval_Rule__c CAR1=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=50, Sales_District__c='Multiple', Product_Group__c='Multiple');
             insert CAR1;
             case c=[select Id,RecordTypeId,Account_SAP_Number__c,Approval_Type__c,AccountId,GC_Secondary_Reason_Descr__c,Reason,GC_No_ofCust_for_CA__c,GC_Sales_Org_Descr__c,GC_Sales_District_Descr__c,GC_Division_Descr__c,GC_Prdt_Group_Descr__c,GC_CA_Frmt_descr__c,GC_Currency_Descr__c,GC_Amount_in_LC_Currncy__c,GC_CA_Reason_descr__c,GC_CA_Amount_in_USD__c,GC_Max_CA_Amt_LC__c,GC_Max_CA_Amt_USD__c,Approval_Validation_1__c,Approver1__c from case where Approval_Type__c='Automated' limit 1];
              case c1=new case();
                string str = c.Approval_Type__c;
                c1=c;
               
                
                c.Approval_Type__c='Manual';
                update c;
                List<case>Clist=new List<Case>();
                Clist.add(c);
                c1.Approval_Type__c='Automated';
                C1.GC_Secondary_Reason_Descr__c='Rebate Settlements';
                update c1;
               
                car.Parallel_Sequential__c='Parallel';
                update car;
                update c1;
                //Hlpr_customApproval.beforeupdate(Clist,cmap);
           
        }*/
        
        
        
}