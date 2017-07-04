public without sharing class TriggerCaseNPS implements Triggers.Handler
{
    //ID campaign + result Question
    map<String, Integer> mapCampaignResults = new map<String, Integer>();
    set<Id> setIdCampaign = new set<Id>();
    list<Campaign> listCampaigns = new list<Campaign>();
    
    public void handle()
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            for(Case c : (List<Case>)trigger.new)
            {
                if(trigger.isUpdate)
                {
                    if(c.NPS_RESULT_Q1__c != ((Case)trigger.oldmap.get(c.Id)).NPS_RESULT_Q1__c) setIdCampaign.add(c.NPS_CAMPAIGN__c);
                }
                else setIdCampaign.add(c.NPS_CAMPAIGN__c);
            }
        }
        
        else if(Trigger.isDelete)
        {
            for(Case c : (List<Case>)trigger.old)
            {
                setIdCampaign.add(c.NPS_CAMPAIGN__c);
            }
        }
            
        for(Case c: [SELECT NPS_CAMPAIGN__c, NPS_RESULT_Q1__c FROM Case WHERE NPS_CAMPAIGN__c!='' AND  NPS_CAMPAIGN__c IN :setIdCampaign])
        {       
            //Detractors
            if(c.NPS_RESULT_Q1__c <= 6)
            {
                //New value
                if(mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'det') == null) mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'det', 1);
                //Existing value
                else mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'det', mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'det') + 1);              
            }
            //Passives
            else if(c.NPS_RESULT_Q1__c > 6 && c.NPS_RESULT_Q1__c <= 8)
            {
                //New value
                if(mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'pas') == null) mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'pas', 1);
                //Existing value
                else mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'pas', mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'pas') + 1);
            }
            //Promoters
            else if(c.NPS_RESULT_Q1__c >= 9 && c.NPS_RESULT_Q1__c <= 10)
            {
                //New value
                if(mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'pro') == null) mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'pro', 1);
                //Existing value
                else mapCampaignResults.put(String.valueOf(c.NPS_CAMPAIGN__c) + 'pro', mapCampaignResults.get(String.valueOf(c.NPS_CAMPAIGN__c) + 'pro') + 1);              
            }
        }

        //Get campaigns
        if(setIdCampaign.size() > 0) 
        {
            listCampaigns = [SELECT Id, Name, GC_Total_Detractor_Qty__c, GC_Total_Passive_Qty__c, GC_Total_Promoter_Qty__c FROM Campaign WHERE Id IN: setIdCampaign];
        
            for(Campaign camp : listCampaigns)
            {
                if(mapCampaignResults.get(String.ValueOf(camp.Id + 'det')) != null) camp.GC_Total_Detractor_Qty__c = mapCampaignResults.get(String.ValueOf(camp.Id + 'det'));
                if(mapCampaignResults.get(String.ValueOf(camp.Id + 'pas')) != null) camp.GC_Total_Passive_Qty__c = mapCampaignResults.get(String.ValueOf(camp.Id + 'pas'));
                if(mapCampaignResults.get(String.ValueOf(camp.Id + 'pro')) != null) camp.GC_Total_Promoter_Qty__c = mapCampaignResults.get(String.ValueOf(camp.Id + 'pro'));
            }
            
            update listCampaigns;
        }   
    }
        
}