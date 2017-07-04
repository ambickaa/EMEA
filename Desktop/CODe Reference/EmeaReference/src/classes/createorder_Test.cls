@isTest
private class createorder_Test

{ 
   

     static testMethod void createorderTest()
     {
     set<id> caseids = new set<id>();
    set<id> accordids = new set<id>();
    set<id> accdelids = new set<id>();
    set<id> accinvids = new set<id>();
    set<id> ordids = new set<id>();
    set<id> delids = new set<id>();
    set<id> invids = new set<id>();
    //Insert Account for Case
      Account acc=new Account();
            acc.Name='Test Account';
            Insert acc;
      accinvids.add(acc.Id);
    
      
      //Insert Order
      Order o=new Order();
      //o.GC_Account_Integration_Key__c=acc.Id;
      o.GC_Integration_Key__c='sadhjhzx';
      o.ShipTo_Acc_Integration_Key__c=acc.Id;
      o.AccountId=acc.Id;
      o.EffectiveDate=date.newInstance(2014, 9, 15);
      o.Status='Draft';
      insert o;
      
      //Insert Delivery
      Delivery__c d=new Delivery__c();
     d.GC_Account_Integration_Key__c=acc.Id;
      d.GC_Integration_Key__c='sadhjhzx';
      d.ShipTo_Acc_Integration_Key__c=acc.Id;
      d.GC_Order_Number__c='sdb';
      d.GC_Delivery_Number_Text__c='h';
      d.name = 'test';
      insert d;
      accdelids.add(d.Id);
      system.debug('aaaaaaaaaaaaa'+d.name);
      
      //Insert Invoice
      Invoice__c Inv=new Invoice__c();
      Inv.GC_Account_Integration_Key__c=acc.Id;
      Inv.GC_Integration_Key__c='sadhjhzx';
      Inv.ShipTo_Acc_Integration_Key__c=acc.Id;
      Inv.GC_Order_Number__c='sdg';
      Inv.Name='test';
      insert Inv;
      system.debug('bbbbbbbbbbbb'+d.name);
      // Insert Case
      Case c=new Case();
      c.recordtypeid='012570000003HCV';
      c.AccountId=acc.Id;
      c.Priority='Low';
      c.Origin='Email';
      c.Status='Open';
      c.GC_Sales_Org_Descr__c='BE01';
      c.GC_Cut_Off_Hours_Descr__c='Urgent';
      c.Reason='Returns';
      c.Subject='Test';
      c.Description='sdhsadj';
      c.GC_First_Pass_descr__c='Yes';
      c.GC_IsComplaint_Descr__c='No';
      c.GC_Source_Order_SFID__c=o.Id;
      c.GC_Source_Delivery_SFID__c =d.Id;
     c.GC_Source_Invoice_SFID__c =Inv.Id;
      insert c;
      caseids.add(c.Id);
      delids.add(c.GC_Source_Delivery_SFID__c );
      invids.add(c.GC_Source_Invoice_SFID__c );
     List<Case> clist=new List<Case>();
       clist.add(c);
   HLPR_CreateCase h=new HLPR_CreateCase();
  // ProcessInsert(clist);
      
      }
}