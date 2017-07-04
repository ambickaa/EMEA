public class TriggerCampaignLineItemFillBudgetLookup implements Triggers.Handler{
       
    public void handle(){  
        
        List<Budget__c> Bud = new List<Budget__c>();
        List<CampaignLineItem__c> clistoupdate = new List<CampaignLineItem__c>();
        
        Set<String> productsref = new Set<String>();
        Set<String> years = new Set<String>();
        Set<Id> users = new Set<Id>();
        
        Map<CampaignLineItem__c,Id> cliVsBudId = new Map<CampaignLineItem__c,Id>();
        
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
         {
            if( trigger.isUpdate && (
                trigger.oldMap.get(cli.id).get('ProductRef__c') != trigger.newMap.get(cli.id).get('ProductRef__c') || 
                trigger.oldMap.get(cli.id).get('year__c') != trigger.newMap.get(cli.id).get('year__c') || 
                trigger.oldMap.get(cli.id).get('ownerId') != trigger.newMap.get(cli.id).get('ownerId')) && (
                cli.ProductRef__c != null && cli.year__c != null && cli.ownerId != null && cli.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales')))
                {
                    clistoupdate.add(cli);
                    productsref.add(cli.HybridName__c);
                    years.add(cli.year__c);
                    users.add(cli.ownerId);
                    
                }
            else if (trigger.isInsert  &&
                    cli.ProductRef__c != null && 
                    cli.year__c != null && 
                    cli.ownerId != null && 
                    cli.RecordTypeId == Util.recordType.get('CampaignLineItem__c:Sales'))
                    {
                    clistoupdate.add(cli);
                    productsref.add(cli.HybridName__c);
                    years.add(cli.year__c);
                    users.add(cli.ownerId);
                }   
                
         }
            
        Bud = ([SELECT ID, ProductRef__c, YearRef__r.Name, SalesRep__c, HybridName__c
                 FROM Budget__c 
                 WHERE HybridName__c in :productsref
                 AND YearRef__r.Name in :years
                 AND SalesRep__c  in :users
                 ]);
                 
                 
                     
         if(Bud.size()>0)
         {
            System.savepoint sp = Database.setSavepoint();
            try
            {
             for(CampaignLineItem__c clitoup : clistoupdate)
             {
                for(Budget__c BudToLkp : Bud)
                {
                    if(BudToLkp.HybridName__c==clitoup.HybridName__c && BudToLkp.yearRef__r.Name==clitoup.year__c && BudToLkp.SalesRep__c==clitoup.ownerId)
                    {
                        clitoup.LKP_Budget__c = BudToLkp.Id;
                    }
                }
             }
            }
            catch(Exception e) 
            {
                Database.rollback(sp);  
            }
         }
                         
    }            

}