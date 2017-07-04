global with sharing class SMcampaignUpdate {
    
    webservice static string cloneCampaign(id campaignId)
    {
        SM_Campaign__c smc = [select CreatedById, LastModifiedById, OwnerId, Name, LKP_Catalog__c, LKP_Country__c, LKP_Country__r.Name, LKP_Division__c, PICK_Email_template_type__c, 
                              MPCK_Language__c, PICK_Library__c, CHK_Save_report_library__c, Seedsman_report_type__c, CHK_Send_to_farmer__c, 
                              LKP_Year__c, LKP_Year__r.YearNextYear__r.name from SM_Campaign__c where id =: campaignId limit 1];
        // First we create the new campaign.
        String nouNom = 'Seedsman Campaign - ' + smc.LKP_Country__r.Name + ' - ' + smc.LKP_Year__r.YearNextYear__r.name;
        ProductCatalog__c ctlg = [SELECT Name, id FROM ProductCatalog__c WHERE (CountryRef__c=:smc.LKP_Country__c) and (DivisionRef__c=:smc.LKP_Division__c) and (YearRef__c=:smc.LKP_Year__r.YearNextYear__c) limit 1];
        
        SM_Campaign__c nextSMc = new SM_Campaign__c(Name=nouNom, LKP_Catalog__c=ctlg.id, LKP_Country__c=smc.LKP_Country__c, LKP_Division__c=smc.LKP_Division__c, PICK_Email_template_type__c=smc.PICK_Email_template_type__c, 
                              MPCK_Language__c=smc.MPCK_Language__c, PICK_Library__c=smc.PICK_Library__c, CHK_Save_report_library__c=smc.CHK_Save_report_library__c, Seedsman_report_type__c=smc.Seedsman_report_type__c, CHK_Send_to_farmer__c=smc.CHK_Send_to_farmer__c, 
                              LKP_Year__c=smc.LKP_Year__r.YearNextYear__c);
        insert nextSMc;
        string filter =smc.Id;
        // Now we get all the data from the different campaign factors and clone them into the new year's campaign.
        // STAGES
        List<SM_Stage__c> oldStages = new List<SM_Stage__c>();
        oldStages = Database.query('SELECT id, Name, CreatedById, LastModifiedById, TXT_Order__c, LKP_SeedsmanCampaign__c, LKP_StageMaster__c FROM SM_Stage__c WHERE LKP_SeedsmanCampaign__c=:filter');
        
        Map<Id, SM_Stage__c> oldStagesMap = new Map<Id, SM_Stage__c>([SELECT id, Name, CreatedById, LastModifiedById, TXT_Order__c, LKP_SeedsmanCampaign__c, LKP_StageMaster__c FROM SM_Stage__c WHERE LKP_SeedsmanCampaign__c=:filter]);
        
        List<SM_Stage__c> newStages = new List<SM_Stage__c>();
        for(Id stgId: oldStagesMap.keySet())
        {
            SM_Stage__c stageTemp = new SM_Stage__c();
            stageTemp=oldStagesMap.get(stgId);
            stageTemp.Id=null;
            stageTemp.LKP_SeedsmanCampaign__c = nextSmc.Id;
            newStages.add(stageTemp);
        }
        insert newStages;
        Integer cont=0;
        for(Id stgId: oldStagesMap.keySet())
        {
            oldStagesMap.put(stgId, newStages[cont]);
            cont++;
        }      
        // EXT. CONDITIONS
        List<SM_External_Conditions__c> oldExtCond = new List<SM_External_Conditions__c>();
        oldExtCond = Database.query('SELECT id, Name, CreatedById, LastModifiedById, LKP_ExternalConditionsMaster__c, LKP_SeedsmanCampaign__c, LKP_Stage__c, LKP_Stage__r.Id FROM SM_External_Conditions__c WHERE LKP_SeedsmanCampaign__c=:filter');
        List<SM_External_Conditions__c> newExtCond = new List<SM_External_Conditions__c>();
        for(SM_External_Conditions__c ec: oldExtCond){
            SM_External_Conditions__c eCon = new SM_External_Conditions__c(LKP_SeedsmanCampaign__c=nextSMc.Id, LKP_Stage__c = oldStagesMap.get(ec.LKP_Stage__r.Id).Id, LKP_ExternalConditionsMaster__c=ec.LKP_ExternalConditionsMaster__c);
            newExtCond.add(eCon);
        }
        insert newExtCond;    
        // CAUSES    
        List<SM_Symptoms_Causes__c> oldCauses = new List<SM_Symptoms_Causes__c>();
        oldCauses = Database.query('SELECT id, Name, CreatedById, LastModifiedById, LKP_CausesMaster__c, LKP_SeedsmanCampaigns__c, LKP_Stage__c, LKP_Stage__r.Id, TXT_SymptomsGroup__c, LKP_SymptomsMaster__c FROM SM_Symptoms_Causes__c WHERE LKP_SeedsmanCampaigns__c=:filter');
        List<SM_Symptoms_Causes__c> newCauses = new List<SM_Symptoms_Causes__c>();
        for(SM_Symptoms_Causes__c cs: oldCauses){
            cs.id=null;
            integer i = 0;
            cs.LKP_Stage__c = oldStagesMap.get(cs.LKP_Stage__r.Id).Id;
            cs.LKP_SeedsmanCampaigns__c = nextSMc.Id;
            newCauses.add(cs);
        }
        insert newCauses;    
        // VISUAL RATINGS
        List<SM_Visual_Rating__c> oldVRatings = new List<SM_Visual_Rating__c>();
        oldVRatings = Database.query('SELECT id, Name, CreatedById, LastModifiedById, NUM_Order__c, LKP_SeedsmanCampaign__c, LKP_Stage__c, LKP_Stage__r.Id, TXTA_Values__c, LKP_VisualRatingMaster__c FROM SM_Visual_Rating__c WHERE LKP_SeedsmanCampaign__c=:filter');
        List<SM_Visual_Rating__c> newVRatings = new List<SM_Visual_Rating__c>();
        for(SM_Visual_Rating__c vr: oldVRatings){
            vr.id=null;
            vr.LKP_Stage__c = oldStagesMap.get(vr.LKP_Stage__r.Id).Id;
            vr.LKP_SeedsmanCampaign__c = nextSMc.Id;
            newVRatings.add(vr);
        }
        insert newVRatings;
        // OBSERVATIONS
        List<SM_Observations__c> oldObs = new List<SM_Observations__c>();
        oldObs = Database.query('SELECT id, Name, CreatedById, LastModifiedById, LKP_ObservationsMaster__c, NUM_Order__c, CHK_Required__c, LKP_SeedsmanCampaign__c, LKP_Stage__c, LKP_Stage__r.Id FROM SM_Observations__c WHERE LKP_SeedsmanCampaign__c=:filter');
        List<SM_Observations__c> newObs = new List<SM_Observations__c>();
        for(SM_Observations__c obs: oldObs){
            obs.id=null;
            obs.LKP_Stage__c = oldStagesMap.get(obs.LKP_Stage__r.Id).Id;
            obs.LKP_SeedsmanCampaign__c = nextSMc.Id;
            newObs.add(obs);
        }
        insert newObs;
        
        return nextSMc.Id;
        
    }
    

}