@isTest
private class Test_ComplaintLists
{
    
    private static testMethod void testComplaintProcessController()
    {
        Case c = new Case();
        insert c;
        
        Complaint_Process__c cp = new Complaint_Process__c(LKP_Complaint__c = c.id);
        insert cp;
        ApexPages.StandardController stdCase = new ApexPages.StandardController(c);
        
        Test.setCurrentPageReference(new PageReference('Page.listcomplaintProcess')); 
        System.currentPageReference().getParameters().put('id', c.id);
        
        listComplaintProcessController  cont = new listComplaintProcessController(stdCase );
        cont.getProcesses();
        cont.getStatus();
        cont.edit();
        cont.cancel();
        
        cont = new listComplaintProcessController(stdCase );         
        cont.newRow();
        cont.save();   
        cont.listcProcess[0].selected=true;
        cont.del();
    }
    
    private static testMethod void testComplaintProductController()
    {                        
        Account acc = new Account(name='testAccount', GC_Cust_Account_Grp_Descr__c='Sold-to party');
        insert acc;
        
        Product2 prod = new Product2(name='testProduct', ProductSAPCode__c='1');
        insert prod;
        
        Delivery__c del = new Delivery__c (GC_Account_Integration_Key__c=acc.Id, GC_Integration_Key__c='1',GC_Order_Number__c='2', GC_Delivery_Date__c=date.newInstance(2017, 8, 21));
        insert del;
        
        
        Delivery_Line_Item__c delLine = new Delivery_Line_Item__c(GC_Item_Descr__c='num1', GC_Batch_Number_Text__c='1', GC_Dlvry_Integration_Key__c=del.Id, GC_Item_Code__c='1', GC_Integration_Key__c='3');
        insert delLine;
        
        Delivery_Line_Item__c delLine2 = new Delivery_Line_Item__c(GC_Item_Descr__c='num2', GC_Batch_Number_Text__c='2', GC_Dlvry_Integration_Key__c=del.Id, GC_Item_Code__c='1', GC_Integration_Key__c='4333');
        insert delLine2;
        
        Case c = new Case(LKP_Direct_Customer_Name__c =acc.id);
        insert c;
        
        Complaint_Products__c cp = new Complaint_Products__c(LKP_CASE__c= c.id);
        insert cp;
        
        Year__c jahr = new Year__c(Name='2017', YearStartDate__c=date.newInstance(2017, 1, 1), YearEndDate__c=date.newInstance(2017, 11, 31), Current_Year__c=true);
        insert jahr;
        
        Test.startTest();
        
        ApexPages.StandardController stdCase = new ApexPages.StandardController(c);
        
        Test.setCurrentPageReference(new PageReference('Page.listcomplaintProduct')); 
        System.currentPageReference().getParameters().put('id', c.id);
        
        listComplaintProductController  cont = new listComplaintProductController(stdCase );
        
        cont.edit();
        cont.cancel();
        cont.newRow();
        cont.save();
        
        cont = new listComplaintProductController(stdCase );
        cont.newRow();
        cont.listcProducts[0].selected=true;
        cont.del();
    }
    
}