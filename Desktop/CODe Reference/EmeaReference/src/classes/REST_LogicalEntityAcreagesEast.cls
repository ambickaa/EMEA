@RestResource(urlMapping='/getLogicalEntity/Acreages_2/*')
global with sharing class REST_LogicalEntityAcreagesEast{
    
    public static final Integer queryLimit = 2000; 
    public static final ID FarmRecordType = '012D00000002zq3IAA';
    public static final ID OtherRecordType = '012D000000038IgIAI';
    
    @HttpPost
    global static REST_LogicalEntity_Acreage getAcreages(REST_Request paramInfo)
    {
        
        REST_Request acrRequest = paramInfo;
        REST_LogicalEntity_Acreage returned = new REST_LogicalEntity_Acreage();
        returned.pagetimestamp=acrRequest.pagetimestamp;        
        returned.lastItem=acrRequest.lastItem;
        returned.mode=acrRequest.mode;       
        returned.lastId='';
           
        returned.Acreages = new List<Acreage__c>();
        
        Integer rows=0;
        
        List<ID> accShared = New List<ID>();
        List<ID> userGroupFilter = New List<ID>();
        userGroupFilter.add(Util.currentUser.Id);
        for(GroupMember item : [SELECT GroupId from GroupMember where UserOrGroupId=:Util.currentUser.Id])
        {
            userGroupFilter.add(item.GroupId);            
        }
        
        
        for(AccountShare acc : [ SELECT AccountId   
                                        FROM AccountShare WHERE UserOrGroupId IN :userGroupFilter
                                        AND  AccountAccessLevel='Edit' ])
        {
            accShared.add(acc.AccountId);
        }
        
           
        for(Acreage__c acr : [ 
                SELECT
                    RecordTypeId,  
                    Name,
                    AcrTotalAcreages__c, 
                    AcrPrevTotalAcreages__c, 
                    Country__c,  
                    AcrFarmRef__c, 
                    LastModifiedDate, 
                    OwnerId, 
                    AcrProductGroupRef__c, 
                    AcrProductTypeRef__c, 
                    AcrProviderRef__c, 
                    AcrYearRef__c                    
                FROM Acreage__c 
                WHERE lastModifiedDate > :acrRequest.pagetimestamp 
                AND AcrFarmRef__r.RecordTypeId!=null 
                AND AcrFarmRef__r.RecordTypeId!=:OtherRecordType
                AND AcrYearRef__c=:Util.currentYear.Id  
                AND (NOT ( (AcrFarmRef__c NOT in :accshared
                )AND                                
                (AcrFarmRef__r.OwnerId!=:Util.currentUser.Id)
                ))                         
                AND AcrProviderRef__c!=null
                AND AcrProductGroupRef__c!=null
                AND AcrProviderRef__r.Name!=null
                AND AcrProviderRef__c in ( SELECT ID FROM Account WHERE RecordTypeId!=null AND RecordTypeId!=:FarmRecordType AND RecordTypeId!=:OtherRecordType)
                AND ID> : acrRequest.lastId
                ORDER BY ID 
                LIMIT : queryLIMIT
            ])
            {
                returned.Acreages.add(acr);
            }
            
            rows=returned.Acreages.size();         
            if(rows==queryLimit)
            {
                acrRequest.lastId=returned.Acreages.get(rows-1).Id;
            }   
                           
        returned.calculateTimestamp(acrRequest.maxtimestamp);  
               
        return returned;
    }
    
    global class REST_LogicalEntity_Acreage{
        public List<Acreage__c> Acreages {get;set;}
        
        public DateTime timestamp {get;set;}
        public DateTime pagetimestamp {get;set;}       
        public DateTime maxtimestamp {get;set;}     
        public Boolean queryMore {get;set;}        
        public Integer mode {get;set;}         
        public Integer lastItem {get;set;}  
        public String lastId {get;set;}
        
        public void calculateTimestamp(Datetime reqMaxTimestamp)
        {   
            maxtimestamp=reqMaxTimestamp;         
            for(Acreage__c acr : Acreages )
            {
                if(maxtimestamp == null || maxtimestamp < acr.LastModifiedDate)maxtimestamp = acr.LastModifiedDate;
            }
                                         
            if(Acreages.size()<queryLimit)
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
                lastId=(String)Acreages.get(queryLimit-1).ID;
                queryMore=true;
            }
            
        timestamp=pagetimestamp;                    
        }
    
    }
    
}