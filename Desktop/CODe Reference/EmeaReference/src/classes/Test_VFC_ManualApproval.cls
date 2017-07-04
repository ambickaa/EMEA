@isTest
public class Test_VFC_ManualApproval {
    
   
            testMethod private static void testMethod1(){
            RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Map<String,Account> nMap = new Map<String,Account>();
            //Account acc=TestUtilities.getAccount(nMap,True);
            Country__c countries=new Country__c(Name='TestCountry');
            insert countries;
            Account acc = new Account(Name='Account121212'+system.currentTimeMillis(),GC_SAP_ID__c='1233434342132',CountryRef__c=countries.id);
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            Profile p1 = [select id from profile where name='System Administrator']; 
            User UserTest1=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem1@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
            insert UserTest1;
            User UserTest=new User( ManagerId=UserTest1.Id,Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           insert UserTest;
            Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR;
                List<Case>CList=new List<Case>();
                
                Case c1=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=1,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,GC_Currency_Descr__c='EUR',GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                CList.add(c1); 
                Case c2=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=2,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c2); 
                Case c3=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=3,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,Approver3__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c3); 
                Case c4=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=4,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,Approver3__c =UserTest.Id,Approver4__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c4); 
                Case c5=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=5,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,Approver3__c =UserTest.Id,Approver4__c =UserTest.Id,Approver5__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c5); 
                
                 insert CList;
               
                 //System.debug('Check 1 : ' + Limits.getQueries());
                Test.startTest(); 
                 ApexPages.StandardController sc = new ApexPages.StandardController(CList[0]);
                 PageReference pageRef = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[0].Id));
                 Test.setCurrentPage(pageRef);
                 VFC_ManualApproval Manual=new VFC_ManualApproval(sc);
                 Manual.Edit();
                 Manual.saveFinal();
                 Manual.Cancel();
                
                 ApexPages.StandardController sc1 = new ApexPages.StandardController(CList[1]);
                 PageReference pageRef1 = Page.VFP_ManualApproval;
                 pageRef1.getParameters().put('id', String.valueOf(CList[1].Id));
                 Test.setCurrentPage(pageRef1);
                 VFC_ManualApproval Manual1=new VFC_ManualApproval(sc1);
                 Manual1.Edit();
                 Manual1.saveFinal();
                 Manual1.Cancel();
                
                 ApexPages.StandardController sc2 = new ApexPages.StandardController(CList[2]);
                 PageReference pageRef2 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[2].Id));
                 Test.setCurrentPage(pageRef2);
                 VFC_ManualApproval Manual2=new VFC_ManualApproval(sc2);
                 Manual2.Edit();
                 Manual2.saveFinal();
                 Manual2.Cancel();
                
                 ApexPages.StandardController sc3 = new ApexPages.StandardController(CList[3]);
                 PageReference pageRef3 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[3].Id));
                 Test.setCurrentPage(pageRef3);
                 VFC_ManualApproval Manual3=new VFC_ManualApproval(sc3);
                 Manual3.Edit();
                 Manual3.saveFinal();
                 Manual3.Cancel();
                
                 ApexPages.StandardController sc4 = new ApexPages.StandardController(CList[4]);
                 PageReference pageRef4 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[4].Id));
                 Test.setCurrentPage(pageRef4);
                 VFC_ManualApproval Manual4=new VFC_ManualApproval(sc4);
                 Manual4.Edit();
                 //Manual4.saveFinal();
                 Manual4.Cancel();               
                 Test.stopTest();
                
                 
                 
                
            }
           testMethod private static void testMethod2(){
            RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Map<String,Account> nMap = new Map<String,Account>();
            //Account acc=TestUtilities.getAccount(nMap,True);
            Country__c countries=new Country__c(Name='TestCountry');
            insert countries;
            Account acc = new Account(Name='Account121212'+system.currentTimeMillis(),GC_SAP_ID__c='1233434342132',CountryRef__c=countries.id);
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            Profile p1 = [select id from profile where name='System Administrator'];
            User UserTest1=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem1@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
            insert UserTest1;
            User UserTest=new User( ManagerId=UserTest1.Id,Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           insert UserTest;
            Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR;
                List<Case>CList=new List<Case>();
                
              
               
                Case c6=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=6,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,Approver2__c =UserTest.Id,Approver3__c =UserTest.Id,Approver4__c =UserTest.Id,Approver5__c =UserTest.Id,Approver6__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c6); 
                Case c7=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=7,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c7); 
                Case c8=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=8,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c8); 
                Case c9=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=9,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                 CList.add(c9); 
                Case c10=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c='Parallel',Approval_Steps__c=10,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,Approver1__c =UserTest.Id,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                CList.add(c10); 
                insert CList;
               Test.startTest();
                 ApexPages.StandardController sc = new ApexPages.StandardController(CList[0]);
                 PageReference pageRef = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[0].Id));
                 Test.setCurrentPage(pageRef);
                 VFC_ManualApproval Manual=new VFC_ManualApproval(sc);
                 Manual.Edit();
                 Manual.saveFinal();
                 Manual.Cancel();
                
                 ApexPages.StandardController sc1 = new ApexPages.StandardController(CList[1]);
                 PageReference pageRef1 = Page.VFP_ManualApproval;
                 pageRef1.getParameters().put('id', String.valueOf(CList[1].Id));
                 Test.setCurrentPage(pageRef1);
                 VFC_ManualApproval Manual1=new VFC_ManualApproval(sc1);
                 Manual1.Edit();
                 Manual1.saveFinal();
                 Manual1.Cancel();
                
                 ApexPages.StandardController sc2 = new ApexPages.StandardController(CList[2]);
                 PageReference pageRef2 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[2].Id));
                 Test.setCurrentPage(pageRef2);
                 VFC_ManualApproval Manual2=new VFC_ManualApproval(sc2);
                 Manual2.Edit();
                 Manual2.saveFinal();
                 Manual2.Cancel();
                
                 ApexPages.StandardController sc3 = new ApexPages.StandardController(CList[3]);
                 PageReference pageRef3 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[3].Id));
                 Test.setCurrentPage(pageRef3);
                 VFC_ManualApproval Manual3=new VFC_ManualApproval(sc3);
                 Manual3.Edit();
                 Manual3.saveFinal();
                 Manual3.Cancel();
                
                 ApexPages.StandardController sc4 = new ApexPages.StandardController(CList[4]);
                 PageReference pageRef4 = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[4].Id));
                 Test.setCurrentPage(pageRef4);
                 VFC_ManualApproval Manual4=new VFC_ManualApproval(sc4);
                 Manual4.Edit();
                 //Manual4.saveFinal();
                 Manual4.Cancel();
               Test.stopTest();
             }
    
    
        testMethod private static void testMethod3(){
            RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
            Map<String,Account> nMap = new Map<String,Account>();
             Country__c countries=new Country__c(Name='TestCountry');
            insert countries;
            Account acc = new Account(Name='Account121212'+system.currentTimeMillis(),GC_SAP_ID__c='1233434342132',CountryRef__c=countries.id);
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name='Customer Service'];
            Profile p1 = [select id from profile where name='System Administrator'];
            User UserTest1=new User( Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem1@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
            insert UserTest1;
            User UserTest=new User( ManagerId=UserTest1.Id,Alias='JSEO123', Email='jseoanem@everis.com',Username='testASCjseoanem@everis.com', LastName='Seoane', TimeZoneSidKey='Europe/Prague',LocaleSidKey='de_DE',EmailEncodingKey='ISO-8859-1',ProfileId=p1.id, LanguageLocaleKey='de', 
            Division='S&T', StandardDivision__c='Corn', Country='Germany', isActive=true );
           insert UserTest;
            Case_Approval_Rule__c CAR=new Case_Approval_Rule__c(Name='Test', Case_Reason__c='Programs/Compensation', Secondary_Reason__c='Customer Accommodation', Approver1__c=UserTest.id, Approver2__c=UserTest.id, Parallel_Sequential__c='Sequential', Approver3__c=UserTest.id, Approver4__c=UserTest.id, Approver5__c=UserTest.id, Approver6__c=UserTest.id, Approver7__c=UserTest.id, Approver8__c=UserTest.id, Approver9__c=UserTest.id, Approver10__c=UserTest.id, Approval_Amount_Min__c=0, Approval_Amount_Max__c=2, Sales_District__c='Multiple', Product_Group__c='Multiple');
                insert CAR;
                List<Case>CList=new List<Case>();
                
                Case c1=new case(RecordTypeId=recType.id,AccountId=acc.id,GC_Secondary_Reason_Descr__c='Customer Accommodation',Reason='Programs/Compensation',Approval_Type__c='Manual',GC_No_ofCust_for_CA__c=11,Parallel_Sequential__c=null,Approval_Steps__c=1,GC_Sales_Org_Descr__c='Multiple',GC_Sales_District_Descr__c='Multiple',GC_Division_Descr__c='17+15',GC_Prdt_Group_Descr__c='Multiple',GC_CA_Frmt_descr__c='Discount on Invoice',GC_Currency_Descr__c='EUR',GC_Amount_in_LC_Currncy__c=0.00,GC_CA_Reason_descr__c='Accounts Receivable',GC_CA_Amount_in_USD__c=0.00,GC_Max_CA_Amt_LC__c=0.00,GC_Max_CA_Amt_USD__c=0.00,Approval_Validation_1__c=True,GC_CA_Rsn_Cmmnt_Text__c='additional rebate',Related_Marketing_Program__c='dce',Supporting_Basis_for_CA_amount__c='afeae',Unbudget_budgeted_CA_amount__c='Budgeted CA Amount',Accrual_Methodology__c='automatic');
                CList.add(c1); 
                
                
                 insert CList;
            Test.startTest();
                 ApexPages.StandardController sc = new ApexPages.StandardController(CList[0]);
                 PageReference pageRef = Page.VFP_ManualApproval;
                 pageRef.getParameters().put('id', String.valueOf(CList[0].Id));
                 Test.setCurrentPage(pageRef);
                 VFC_ManualApproval Manual=new VFC_ManualApproval(sc);
                 Manual.Edit();
                 Manual.saveFinal();
                 Manual.Cancel();
            Test.stopTest();
        }
}