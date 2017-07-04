/***************************************
Created By: Abhinav Sharma
Organization: Accenture
Email Id: abhinav.l.sharma@accenture.com
Associated Class :PartnerFunctionRelatedListExtension 
****************************************/

@isTest
public class Test_PartnerFunctionRelatedListExtension
{
    public static testmethod void PartnerFunctionRelatedListExtension()
    {
        //Inserting Country data
        Country__c country=new Country__c();
        country.Name='Spain';
        insert country;
        
        //Inserting account data
        Account account=new Account();
        account.Name='Acc Test 1';
        account.CountryRef__c=country.Id;
        insert account;
        
        Report ReportRec = new Report();
        
         //Inserting sales data
        Sales_Area__c sales=new Sales_Area__c();
        sales.Divison_Code__c='DIV5';
        sales.Sales_District_Code__c='SD1';
        sales.Sales_Org_Code__c='SO1';
        sales.Name = 'Test Sales';
        sales.GC_Account_Integration_Key__c=account.Id;
        
        insert sales;
        
        //Inserting Partner function record
        Partner_Function__c partner=new Partner_Function__c();
        for(Integer i=1;i<=20;i++){
            partner.Name='test';
            partner.is_Marked_For_Del__c=false;
            partner.Primry_Acct_Integration_Key__c=account.Id;
            partner.Sales_Area_Integration_Key__c=sales.Id;
            partner.Partner_Function_Descr__c='Test1';
            partner.Partner_SAP_ID__c='4562123';
        }
        
        insert partner;
        
        PartnerFunctionRelatedListExtension ctrl = new PartnerFunctionRelatedListExtension(new ApexPages.StandardController(account));
        List<SelectOption> options = new List<SelectOption>();
        ctrl.lstPartnerFunctionName = 'Test1';
        ctrl.lstSalesArea = 'Test Sales';
        ctrl.lstMarkDelete = 'No';
        ctrl.ReportID = ReportRec.id;
        ctrl.nextbtn();
        ctrl.prvbtn();
        ctrl.Allnextbtn();
        ctrl.Allprvbtn();       
        ctrl.getnxt();
        ctrl.getMarkDelete();
        ctrl.getPartnerFunctionName();
        ctrl.getSalesArea();
        ctrl.Datalist();
        ctrl.fnPartnerFucntion();
        ctrl.fnPartnerFucntionAll();
    }
}