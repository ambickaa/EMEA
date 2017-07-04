@RestResource(urlMapping='/getDeletedLogicalEntity/Trial/*')
global with sharing class REST_DelLogicalEntityTrialEast{

    @HttpPost
    global static REST_DelLogicalEntity_Trial getDeletedTrials(REST_DelLogicalEntity_Trial paramInfo)
    {
    	    	
        REST_DelLogicalEntity_Trial returned = new REST_DelLogicalEntity_Trial();
        
        returned.groups = new List<CampaignLineItemGroup__c>();
        returned.trials = new List<CampaignLineItem__c>();  
         
        Id OSRCampaign=UtilREST.OSRCurrentCampaign;
	    Id CornCampaign=UtilREST.CornCurrentCampaign;   
	    
	    Set<ID> cliWithSharing  = new Set<ID> ();
		
        for(CampaignLineItem__Share cli: UtilREST.currentUserCliShared )
        {
            if(cli.AccessLevel=='Edit' || cli.AccessLevel=='Read' )
                cliWithSharing.add(cli.ParentId);
        }
		
        Map<ID,CampaignLineItem__c> paramInfoTrials = new Map<ID,CampaignLineItem__c>(paramInfo.trials);
        Set<ID> paramInfoTrialsIDs = paramInfoTrials.keySet();
        
        List<CampaignLineItem__c> currentTrials = new List<CampaignLineItem__c>();
        Set<Id> currentTrialsIDs = new Set<Id>();
        Set<ID> currentGroupsIDs = new Set<Id>();
        Map<ID,CampaignLineItemGroup__c> paramInfoGroups = new Map<ID,CampaignLineItemGroup__c>(paramInfo.groups);
        Set<ID> paramInfoGroupsIDs = paramInfoGroups.keySet();
        
       
        for(CampaignLineItem__c trial: [
         SELECT ID, CampaignLineItemGroupRef__c,CampaignName__c,CampaignRef__c FROM CampaignLineItem__c 
         WHERE /*ID IN :paramInfoTrialsIDs AND*/ ProductCatalogEntryRef__r.ProductCatalogRef__c in:UtilREST.activeTrialCatalogs 
         AND CampaignRef__c!=null AND ProductRef__c!=null  AND CampaignLineItemGroupRef__c!=null AND CampaignLineItemGroupRef__r.CampaignRef__c!=null
         AND FarmRef__c!=null  AND FarmRef__r.Name!=null  AND RecordTypeId='012D000000035B3IAI' //TRIALS
         AND (OwnerId=:Util.currentUser.ID   OR Id in: cliWithSharing)          
         AND CampaignLineItemGroupRef__c!=null AND CampaignLineItemGroupRef__r.AccountRef__r.Name!=null  AND  FarmRef__r.Name!=null] 
        )
        {
        	
           if(trial.CampaignName__c.contains('Corn')  && trial.CampaignRef__c!=CornCampaign)
                trial.CampaignRef__c=CornCampaign;
           if(trial.CampaignName__c.contains('OSR')  && trial.CampaignRef__c!=OSRCampaign)
               trial.CampaignRef__c=OSRCampaign;
        	if(trial.CampaignRef__c!=null)
        	{
	        	currentGroupsIDs.add(trial.CampaignLineItemGroupRef__c);
	        	currentTrialsIDs.add(trial.id);
        	}
        }
        
        
        paramInfoTrialsIDs.removeAll(currentTrialsIDs);
        for(ID i : paramInfoTrialsIDs){
            returned.trials.add(paramInfoTrials.get(i));
        }

        
        paramInfoGroupsIDs.removeAll(currentGroupsIDs);
        for(ID i : paramInfoGroupsIDs){
            returned.groups.add(paramInfoGroups.get(i));
        }        
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Trial getExample()
    {
        REST_DelLogicalEntity_Trial returned = new REST_DelLogicalEntity_Trial();
        
        returned.groups = [SELECT ID FROM CampaignLineItemGroup__c LIMIT 1 ];
        returned.trials = [SELECT ID FROM CampaignLineItem__c LIMIT 1 ];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Trial
    {
        public List<CampaignLineItemGroup__c> groups;
        public List<CampaignLineItem__c> trials;
    }
    
    
}