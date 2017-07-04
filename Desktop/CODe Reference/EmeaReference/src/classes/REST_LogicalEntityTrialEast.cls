@RestResource(urlMapping='/getLogicalEntity/Trial_2/*') 
global with sharing class REST_LogicalEntityTrialEast{ 

    public static final Integer queryLimit =1000; 
    public static final ID OtherRecordType = '012D000000038IgIAI';
	public static final ID SalesRecordType = '012D000000035B2IAI';
	public static final Id TrialRecordType = '012D000000035B3IAI';

    @HttpPost
    global static REST_LogicalEntity_Trial getTrials(REST_Request paramInfo)
    {
    		        
	        REST_Request tRequest = paramInfo;
	        
	        REST_LogicalEntity_Trial returned = new REST_LogicalEntity_Trial ();
	        returned.pagetimestamp=tRequest.pagetimestamp;        
	        returned.lastItem=tRequest.lastItem;
	        returned.mode=tRequest.mode;       
    	    returned.lastId='';
    	
	        returned.groups=new List<CampaignLineItemGroup__c>();
	        returned.trials=new List<CampaignLineItem__c>();
	        Id OSRCampaign=UtilREST.OSRCurrentCampaign;
	        Id CornCampaign=UtilREST.CornCurrentCampaign;
	        
	        tRequest.pagetimestamp=UtilREST.resetTimestamp(tRequest.pagetimestamp);
	        
	        Set<ID> groupToQuery = new Set<ID> ();
	        Set<ID> groupToQueryGot = new Set<ID> ();
	        Set<ID> cliWithSharing  = new Set<ID> ();
	        Set<ID> cligroupWithSharing = new Set<ID> ();
	        Set<CampaignLineItem__c> trialCandidates = new set<CampaignLineItem__c>();
	        Set <ID> cliWoGroup = new set<ID>();    	
    		Integer rows=0;
    		
			 returned.mode=0;
   		
	   		List<ID> accShared = new List<ID> ();
	        List<ID> cliShared = new List<ID>();
	        List<Id> groupsModified = new List<Id>();
	        
	        for(CampaignLineItemGroup__c clg: [SELECT ID FROM  CampaignLineItemGroup__c WHERE  
	        								   LastModifiedDate > :tRequest.pagetimestamp AND AccountRef__c!=null
						                       AND CampaignRef__c!=null
						                       AND id in:groupToQuery  
						                       AND AccountRef__r.Name!=null       ])
			{
				groupsModified.add(clg.ID);
			}
	                
	        	
	        for(AccountShare acc:[ SELECT AccountId
													FROM AccountShare 
													WHERE UserOrGroupId=:Util.currentUser.Id AND AccountAccessLevel='Edit' ])
			{
					accShared.add(acc.AccountID);
			}
				
			if(accShared.size()>0)
			{        	
		        for(CampaignLineItem__Share  cliS :  [  SELECT ParentId
															FROM CampaignLineItem__Share 
															WHERE Parent.LastModifiedDate > :tRequest.pagetimestamp AND 
															UserOrGroupId=:Util.currentUser.Id AND( NOT( AccessLevel!='Edit' AND AccessLevel!='Read' AND AccessLevel!='All'  ))
															AND Parent.RecordTypeId=:TrialRecordType																						
															AND (NOT( Parent.FarmRef__c NOT in :accShared AND Parent.FarmRef__r.OwnerId!=:Util.currentUser.Id))																
														])
				{
					cliShared.add(cliS.ParentId);
				}  
													      	
			}
	   
	           
	        for(CampaignLineItem__c trial: [
	            SELECT
	                Name, 
	                CampaignRef__c, 
	                CampaignLineItemGroupRef__c,   
	                FarmRef__c, 
	                LastModifiedDate, 
	                ProductRef__c, 
	                ProductCatalogEntryRef__c, 
	                Provider__c, 
	                RecordTypeId,  
	                Treatment__c,   
	                Yield__c, 
	                campaignName__c, 
	                country__c, 
	                idDevice__c, 
	                year__c,
	                OwnerId
	            FROM
	                CampaignLineItem__c
	            WHERE
	                RecordTypeId=:TrialRecordType //TRIALS
	                AND (NOT (LastModifiedDate <= :tRequest.pagetimestamp AND (CampaignLineItemGroupRef__c NOT in: groupsModified)))               
	                AND ProductCatalogEntryRef__c!=null
	                AND ProductCatalogEntryRef__r.ProductCatalogRef__c!=null
	                AND ProductCatalogEntryRef__r.ProductCatalogRef__c in: UTILREST.activeTrialCatalogs
	                //AND CampaignRef__c!=null
	                AND ProductRef__c!=null
	                AND CampaignLineItemGroupRef__c!=null
	                AND CampaignLineItemGroupRef__r.CampaignRef__c!=null
	                AND FarmRef__c!=null
	                AND FarmRef__r.Name!=null
	                AND FarmRef__r.RecordTypeId!=null
					AND FarmRef__r.RecordTypeId!=:OtherRecordType//recordtype Others              
				    AND ( NOT( Id NOT in :cliShared AND (NOT((OwnerID=:Util.currentUser.Id AND FarmRef__r.OwnerId=:Util.currentUser.Id )))))
					AND ID> : tRequest.lastId
					ORDER BY ID	
					LIMIT : queryLimit		
 
	            ])
	         {
	            if(trial.CampaignName__c.contains('Corn')  && trial.CampaignRef__c!=CornCampaign)
	                trial.CampaignRef__c=CornCampaign;
	           if(trial.CampaignName__c.contains('OSR')  && trial.CampaignRef__c!=OSRCampaign)
	               trial.CampaignRef__c=OSRCampaign;
	        	if(trial.CampaignRef__c!=null)
		        {
		            trialCandidates.add(trial);
		            groupToQuery.add(trial.CampaignLineItemGroupRef__c);
		        }
		        
		        
	         }  
	        	                       	
	         for(CampaignLineItemGroup__c clig: [
	                    SELECT
	                        Name,
	                        AccountRef__c,
	                        CampaignRef__c, 
	                        CampaignName__c, 
	                        Comments__c, 
	                        HarvestedBy__c,  
	                        LastModifiedDate,
	                        Latitude__c,
	                        Longitude__c, 
	                        RecordTypeId, 
	                        Status__c, 
	                        Type__c,
	                        ImportId__c,
	                        ImportSource__c,
	                        idDevice__c,
	                        OwnerId  
	                    FROM
	                        CampaignLineItemGroup__c               
	                    WHERE
	                        LastModifiedDate > :tRequest.pagetimestamp 
	                       AND AccountRef__c!=null
	                       AND CampaignRef__c!=null
	                       AND id in:groupToQuery  
	                       AND AccountRef__r.Name!=null                    
	                    ])
	        {
	            if(clig.CampaignName__c.contains('Corn') && clig.CampaignRef__c!=CornCampaign)
	                clig.CampaignRef__c=CornCampaign;
	            if(clig.CampaignName__c.contains('OSR') && clig.CampaignRef__c!=OSRCampaign)
	                clig.CampaignRef__c=OSRCampaign;
	            if(clig.CampaignRef__c!=null)
	            {
	            	returned.groups.add(clig);
	            	groupToQueryGot.add(clig.id);
	            }
	            
	            
	        }
      
	        for(CampaignLineItem__c clg : trialCandidates )
	        {
	            if(groupToQueryGot.contains(clg.CampaignLineItemGroupRef__c))
	                    returned.trials.add(clg);
	        } 
	        
	        rows=returned.trials.size();
			if(rows==queryLimit)
            {
                tRequest.lastId=returned.trials.get(rows-1).Id;
            }                  
	        
	        
		
		returned.calculateTimestamp(tRequest.maxtimestamp);  
        
        return returned;
      
    }
    
    global class REST_LogicalEntity_Trial {
        
        public List<CampaignLineItemGroup__c> groups {get;set;}
        public List<CampaignLineItem__c>  trials {get;set;}
        //List<Campaign> campaigns {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime maxtimestamp {get;set;}     
        public DateTime pagetimestamp {get;set;}
        public Boolean queryMore {get;set;}        
        public Integer mode {get;set;}         
        public Integer lastItem {get;set;}  
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
        	maxtimestamp=reqMaxTimestamp;         
            
            for(CampaignLineItemGroup__c clig : groups){
                if(maxtimestamp == null || maxtimestamp < clig.LastModifiedDate)maxtimestamp = clig.LastModifiedDate;
            }
            for(CampaignLineItem__c cli : trials){
                if(maxtimestamp == null || maxtimestamp < cli.LastModifiedDate)maxtimestamp = cli.LastModifiedDate;
            }
            /*for(Campaign c : campaigns){
                if(maxtimestamp == null || maxtimestamp < c.LastModifiedDate)maxtimestamp = c.LastModifiedDate;
            }*/
       
            if(trials.size()<queryLimit)
            {
                timestamp=maxtimestamp;
                queryMore=false;
                pagetimestamp=maxtimestamp;
                mode=0;
                lastItem=0;
                LastId='';              
            }   
            else
            {
                lastId=(String)trials.get(queryLimit-1).ID;
                queryMore=true;
            }
                        
        	timestamp=pagetimestamp;                   
            

				
        }
    }
   
}