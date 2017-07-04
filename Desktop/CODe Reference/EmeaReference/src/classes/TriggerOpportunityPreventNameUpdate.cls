public with sharing class TriggerOpportunityPreventNameUpdate implements Triggers.Handler{

  public Map<Id,String> oldNames = new  Map<Id,String>();
     
  public void handle()
  {
     for (Opportunity opp : (List<Opportunity>)Trigger.new)
     {  
      if(opp.recordtypeid =='012D00000003084' || opp.recordtypeid =='012D00000003FYg')
      {     
        opp.Name=oldNames.get(opp.ID);
        opp.Name=((Map<Id, Opportunity>)Trigger.oldMap).get(opp.id).name;
        
        if (opp.StageName=='Fast warehouse' && opp.TXTA_Sales_Org__c!='TR01' &&((Map<Id, Opportunity>)Trigger.oldMap).get(opp.id).StageName!='Fast warehouse' && !opp.Name.endsWith('(R)'))
         {
             opp.Name = opp.Name + '(R)';
         }
         if (opp.StageName=='Standard' && ((Map<Id, Opportunity>)Trigger.oldMap).get(opp.id).StageName=='Fast warehouse' && opp.Name.endsWith('(R)'))
         {
             opp.Name = opp.Name.replace('(R)', '');
         } 
     }       
     }     
  }
}