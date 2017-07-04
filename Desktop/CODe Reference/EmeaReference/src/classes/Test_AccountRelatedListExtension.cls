/***************************************
Created By: Abhinav Sharma
Organization: Accenture
Email Id: abhinav.l.sharma@accenture.com
Associated Class: AccountRelatedListExtension
****************************************/

@isTest
public class Test_AccountRelatedListExtension
{
    public static testmethod void AccountRelatedListExtension()
    {
        //Inserting Country data
        Country__c country=new Country__c();
        country.Name='Spain';
        insert country;
        
        //Inserting account data
        Account account=new Account();
        account.Name='aasd';
        account.CountryRef__c=country.Id;
        insert account;
        
         //Inserting sales data
        Sales_Area__c sales=new Sales_Area__c();
        sales.Divison_Code__c='DIV5';
        sales.Sales_District_Code__c='SD1';
        sales.Sales_Org_Code__c='SO1';
        sales.GC_Account_Integration_Key__c=account.Id;
        
        insert sales;
        
        //Inserting Report Data
        Report lstReport = new Report();
           
        //Inserting Order data
        Order order=new Order();
        for(Integer i=1;i<=20;i++){
            order.AccountID=account.Id;
            order.Name='testing'+i;
            order.GC_Integration_Key__c='sdhjshjasd';
            order.Status='Draft';
            order.Divison_Code__c='DIV5';
            order.Sales_District_Code__c='SD1';
            order.Sales_Org_Code__c='SO1';
            order.EffectiveDate=date.newInstance(2014, 9, 15);
        }
        insert order;
        
        //Inserting Delivery data
        Delivery__c dev1=new Delivery__c();
        for(Integer i=1;i<=20;i++){
            dev1.Name='abc'+i;
            dev1.GC_Order_Number__c='sdgskjd';
            dev1.GC_Integration_Key__c='sdfhsjd';
            dev1.GC_Delivery_Number_Text__c='hdfjsd';
            dev1.GC_Account_Integration_Key__c=account.Id;
            dev1.Divison_Code__c='DIV5';
            dev1.Sales_District_Code__c='SD1';
            dev1.Sales_Org_Code__c='SO1';
        }
        insert dev1;
        
        //Inserting Invoice Data
        Invoice__c invoice1=new Invoice__c();
        for(Integer i=1;i<=20;i++){
            invoice1.ShipTo_Acc_Integration_Key__c=account.Id;
            invoice1.GC_Order_Number__c='Inv'+i;
            invoice1.GC_Integration_Key__c='sdjsk';
            invoice1.GC_Invoice_Number_Text__c='sadskj';
            invoice1.GC_Account_Integration_Key__c=account.Id;
            invoice1.Divison_Code__c='DIV5';
            invoice1.Sales_District_Code__c='SD1';
            invoice1.Sales_Org_Code__c='SO1';
        }
        insert invoice1;
        
        //Contract Data
        Contract cntract=new Contract();
        for(Integer i=1;i<=20;i++){
            cntract.Name='Cont'+i;
            cntract.ShipTo_Acc_Integration_Key__c=account.Id;
            cntract.GC_Integration_Key__c='jdfjdsfhhfcn';
            cntract.Contract_Order_Text__c='dfhduh';
            cntract.Status='Draft';
            cntract.Divison_Code__c='DIV5';
            cntract.Sales_District_Code__c='SD1';
            cntract.Sales_Org_Code__c='SO1';
            cntract.AccountId=account.Id;
        }
        insert cntract;
        
        Date d=system.today();
        
        AccountRelatedListExtension ctrl = new AccountRelatedListExtension(new ApexPages.StandardController(account));        
        ctrl.ReportID=lstReport.ID;
        ctrl.DReportID=lstReport.ID;
        ctrl.IReportID=lstReport.ID;
        ctrl.CReportID=lstReport.ID;
        ctrl.getSalesOrg();
        ctrl.getDivisonCode();
        ctrl.getChannelCode();
        ctrl.lstFYear = String.ValueOf(d.year());
        ctrl.getFYear();       
        ctrl.lstSalesOrg='SO1';
        ctrl.lstDivisonCode='DIV5';
        ctrl.lstChannelCode='SD1';
        ctrl.AllDatalist();
        ctrl.Datalist();
        
        ctrl.nextbtn();
        ctrl.prvbtn();
        ctrl.AllOnextbtn();
        ctrl.AllOprvbtn();
        ctrl.nextbtnD();
        ctrl.prvbtnD();
        ctrl.AllDnextbtn();
        ctrl.AllDprvbtn();
        ctrl.nextbtnI();
        ctrl.prvbtnI();
        ctrl.AllInextbtn();
        ctrl.AllIprvbtn();
        ctrl.nextbtnC();
        ctrl.prvbtnC();
        ctrl.AllCnextbtn();
        ctrl.AllCprvbtn();
        ctrl.getOnxt();
        ctrl.getDnxt();
        ctrl.getInxt();
        ctrl.getCnxt();  
    }
}