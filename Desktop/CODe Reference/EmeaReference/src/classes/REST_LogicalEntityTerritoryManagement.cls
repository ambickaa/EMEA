@RestResource(urlMapping='/getLogicalEntity/TerritoryManagement_2/*')
global with sharing class REST_LogicalEntityTerritoryManagement{

    public static final Integer queryLimit = 1000; 

    @HttpPost
    global static REST_LogicalEntity_Territory getTerritories(REST_Request paramInfo)
    { 
        REST_LogicalEntity_Territory returned = new REST_LogicalEntity_Territory ();
        
        REST_Request tmRequest = paramInfo;

        returned.pagetimestamp=tmRequest.pagetimestamp;        
        returned.lastItem=tmRequest.lastItem;
       // returned.mode=tmRequest.mode;       
       
        returned.territories = new List<TerritoryManagement__c>();
 	
		Integer rows=0;
 
        if(tmRequest.mode==0)
		{
			for(TerritoryManagement__c terr : [ SELECT 
	              	   DE_CountryRef__c, 
	                   LastModifiedDate,
	                   Name 
	               FROM 
	                   TerritoryManagement__c 
	               WHERE
	                    LastModifiedDate > :tmRequest.pagetimestamp AND DE_CountryRef__r.Name=:Util.currentUser.Country
                        AND ID> : tmRequest.lastId
                        AND ID in (SELECT DE_TerritoryManagementRef__c from TerritoryManagementUser__c where de_userref__c = :Userinfo.getUserId())
			            ORDER BY ID     
			            LIMIT : queryLimit])
									 
			{
			  returned.territories.add(terr);
			}
			
			rows=returned.territories.size();
            if(rows<queryLIMIT)
            {
                tmRequest.mode=1; 
                tmRequest.lastId='';
                returned.mode=1;             
            }
            else
            {
                tmRequest.mode=0;
                tmRequest.lastId=returned.territories.get(rows-1).Id;
            }
		}
		
		if(tmRequest.mode==1)
		{
		
			for(TerritoryManagement__c terr : [SELECT 
						   DE_CountryRef__c, 
						   LastModifiedDate,
						   Name 
					   FROM 
						   TerritoryManagement__c 
					   WHERE
							LastModifiedDate > :tmRequest.pagetimestamp AND DE_CountryRef__r.Name=:Util.currentUser.Country
							AND ID> : tmRequest.lastId
							AND ID in (SELECT DE_Territory_Key__c FROM Account WHERE DE_Territory_Key__c!=null)
							AND ID NOT in (SELECT DE_TerritoryManagementRef__c from TerritoryManagementUser__c where de_userref__c = :Userinfo.getUserId())
							ORDER BY ID     
							LIMIT : queryLimit	               
					])
			{
			returned.territories.add(terr);
            }
            
			rows=returned.territories.size();
			if(rows==queryLimit)
			{
				tmRequest.lastId=returned.territories.get(rows-1).Id;
			}                  
		}
	                    
        returned.pagetimestamp=tmRequest.pagetimestamp;
        returned.mode=tmRequest.mode;       
        returned.lastItem=tmRequest.lastItem; 
               
        returned.calculateTimestamp(tmRequest.maxtimestamp);
                       
        return returned;        
    }
    
    global class REST_LogicalEntity_Territory {
                
        public List<TerritoryManagement__c> territories {get;set;}
        
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
            for(TerritoryManagement__c tm : territories )
            {
                if(maxtimestamp == null || maxtimestamp < tm.LastModifiedDate)maxtimestamp = tm.LastModifiedDate;
            }                                                                     
            if(territories.size()<queryLimit)
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
				lastId=(String)territories.get(queryLimit-1).ID;
				queryMore=true;
			}
			if(lastId==null)
				lastId='';
			timestamp=pagetimestamp;            
							
        }
    }
    
 }