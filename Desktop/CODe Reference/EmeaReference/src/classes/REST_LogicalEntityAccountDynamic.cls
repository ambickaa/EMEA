@RestResource(urlMapping='/getLogicalEntity/AccountDynamic/*')
global with sharing class REST_LogicalEntityAccountDynamic{ 
 
    public static final ID FarmRecordType = '012D00000002zq3IAA';
    public static final ID OtherRecordType = '012D000000038IgIAI';
    public static final Integer queryLimit = 250;
    @HttpPost  
    global static REST_LogicalEntity_Account getAccounts(REST_Request paramInfo)
    {
        REST_Request accRequest = paramInfo;
        REST_LogicalEntity_Account returned = new REST_LogicalEntity_Account(); 
        returned.Accounts = new List<Account>();
        returned.lastId='';
        Set<Id> accountsWithContactsModifiedSet = new Set<Id>();
      
        system.debug('timestamp: '+accRequest.pagetimestamp);
        system.debug('timestamp2: '+ +(accRequest.pagetimestamp.formatGmt('YYYY-MM-dd')+'T'+accRequest.pagetimestamp.formatGmt('HH:mm:ss.SSS')+'Z')+' ');
        
        for(Contact c : [SELECT AccountID FROM CONTACT
                         WHERE lastModifiedDate > :accRequest.pagetimestamp 
                         AND id in (SELECT Contactid FROM CONTACTSHARE 
                                    WHERE UserOrGroupId=:Util.currentUser.Id AND (contactAccessLevel='Edit' OR contactAccessLevel='All'))
                         ORDER BY lastModifiedDate LIMIT 25000]){
            
            if(c.AccountID != null) {
                accountsWithContactsModifiedSet.add(c.AccountID);
            }
        } 
        
        for(Touchpoint_Program__c t : [SELECT LKP_ACCOUNT__c FROM Touchpoint_Program__c 
                                       WHERE lastModifiedDate > :accRequest.pagetimestamp
                                       AND   lastModifiedDate > :Date.today().addMonths(-24)
                                       AND   LKP_ACCOUNT__c != null
                                       ORDER BY lastModifiedDate LIMIT 25000]){
            
            if(t.LKP_ACCOUNT__c != null) {
                accountsWithContactsModifiedSet.add(t.LKP_ACCOUNT__c);
            }
        }      

        String accShared =''; 
        Set<Id> accSharedId = new Set<Id>();
        for(AccountShare acc : [ SELECT AccountId FROM AccountShare 
                                 WHERE UserOrGroupId=:Util.currentUser.Id AND AccountAccessLevel='Edit'
                                 AND (NOT( Account.systemmodstamp<= :accRequest.pagetimestamp
                                 AND AccountId NOT in:accountsWithContactsModifiedSet)) ]){
            accShared+='\''+acc.AccountID+'\',';
            accSharedId.add(acc.AccountID); 
        }
        
        Integer rows=0;
 
        // Get the map of sObjectType information
        map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe(); 
        
        String accountFields = '';
        map<String, Schema.SObjectField> accountFieldsMap = GlobalMap.get('Account').getDescribe().fields.getMap();
        for(String key : accountFieldsMap.keyset())
        {       
            Schema.SObjectField item = accountFieldsMap.get(key);
            if(item.getDescribe().isAccessible())
                accountFields += item.getDescribe().getName()+',';
        }
        
        String contactFields = '';
        map<String, Schema.SObjectField> contactFieldsMap = GlobalMap.get('Contact').getDescribe().fields.getMap();
        for(String key : contactFieldsMap.keyset())
        {       
            Schema.SObjectField item = contactFieldsMap.get(key);
            if(item.getDescribe().isAccessible())
                contactFields += item.getDescribe().getName()+',';
        }
        
        String tppFields = '';
        map<String, Schema.SObjectField> tppFieldsMap = GlobalMap.get('Touchpoint_Program__c').getDescribe().fields.getMap();
        for(String key : tppFieldsMap.keyset())
        {       
            Schema.SObjectField item = tppFieldsMap.get(key);
            if(item.getDescribe().isAccessible())
                tppFields += item.getDescribe().getName()+',';
        }
        
        /*
            Mode 0 retrieves accounts owned by the user and not shared with others
               When mode 0 finishes, mode 1 is launched to sequentially retrieve accounts shared with others
        */
        //**Primero saca paquetes de 250 de cuentas que son propiedad del User.
        if(accRequest.mode==0){
        
            String QUERY = 'SELECT '+accountFields+' (SELECT '+tppFields.removeEnd(',')+' FROM Account_Plans__r), (SELECT '+contactFields.removeEnd(',')+' FROM Contacts) FROM Account';
            QUERY += ' WHERE (NOT( lastmodifieddate<= ' +(accRequest.pagetimestamp.formatGmt('YYYY-MM-dd')+'T'+accRequest.pagetimestamp.formatGmt('HH:mm:ss.SSS')+'Z')+' ';
            if(!accountsWithContactsModifiedSet.isEmpty()) QUERY += ' AND Id NOT in :accountsWithContactsModifiedSet ';
            QUERY +=')) ';
            QUERY += ' AND( RecordTypeId!=\''+OtherRecordType+'\' AND RecordTypeId!=null) ';
            if(!accSharedID.isEmpty())   QUERY += 'AND (NOT( OwnerId!=\''+Util.currentUser.id+'\' AND ID IN:accSharedId )) '; //Cuentas que son del USUARIO pero non COMPARTIDAS en el SHARED.
            QUERY += ' AND ID >\''+accRequest.lastId+'\' ORDER BY ID LIMIT '+queryLimit;   
            system.debug('query: '+QUERY);
        
            for (Account acc : Database.query(QUERY)){
                returned.Accounts.add(acc);
            }
            
            rows=returned.Accounts.size();
            if(rows<queryLIMIT){//** Una vez ha recogido todas las cuentas del propietario pasa al MODO 1.
                accRequest.mode=1; 
                accRequest.lastId='';
                returned.mode=1;   
                          
            }else{//** Se realiza este código hasta qye recoge todas las cuentas del propietario.
                accRequest.mode=0;
                accRequest.lastId=returned.Accounts.get(rows-1).Id;
            }   
        }
        
        //** En este modo recoge todas las cuentas compartidas pero el usuario no es propietario.
        if(accRequest.mode==1){

            String QUERY = 'SELECT '+accountFields+' (SELECT '+tppFields.removeEnd(',')+' FROM Account_Plans__r), (SELECT '+contactFields.removeEnd(',')+' FROM Contacts) FROM Account';
            QUERY += ' WHERE (NOT( lastmodifieddate<= ' +(accRequest.pagetimestamp.formatGmt('YYYY-MM-dd')+'T'+accRequest.pagetimestamp.formatGmt('HH:mm:ss.SSS')+'Z')+' ';
            if(!accountsWithContactsModifiedSet.isEmpty()) QUERY += ' AND Id NOT in :accountsWithContactsModifiedSet ';
            QUERY +=')) ';
            QUERY += ' AND( RecordTypeId!=\''+OtherRecordType+'\' AND RecordTypeId!=null) ';
            QUERY += ' AND OwnerId!=\''+Util.currentUser.id+'\' ';            //Cuentas que NO son del USUARIO pero son COMPARTIDAS en el SHARED. Sergio.
            if(!accSharedID.isEmpty())   QUERY += ' AND ID IN:accSharedId  '; //Cuentas que NO son del USUARIO pero son COMPARTIDAS en el SHARED.
            QUERY += ' AND ID >\''+accRequest.lastId+'\' ORDER BY ID LIMIT '+queryLimit;
            system.debug('query: '+QUERY);

            for(Account acc: Database.query(QUERY)){
                acc.shared__c=true;
                returned.Accounts.add(acc);
            }
            
            rows=returned.Accounts.size();
            if(rows==queryLimit){// Se rellama a este codigo hasta conseguir todas las cuentas. Después, simplemente, no se rellama.
                accRequest.lastId=returned.Accounts.get(rows-1).Id;
            }                  
        }
                
        returned.pagetimestamp=accRequest.pagetimestamp;
        returned.mode=accRequest.mode;       
        returned.lastItem=accRequest.lastItem; 
               
        returned.calculateTimestamp(accRequest.maxtimestamp);
                       
        return returned;        

    }      
            
    global class REST_LogicalEntity_Account{
        public List<Account> Accounts {get;set;}
        public DateTime timestamp {get;set;}
        public DateTime pagetimestamp {get;set;}               
        public DateTime maxtimestamp {get;set;}
        public Boolean queryMore {get;set;}
        public Integer mode {get;set;} //1 owner, 2 shared, 3 others
        public Integer lastItem {get;set;}      
        public String lastId {get;set;}
                          
        public void calculateTimestamp(Datetime reqMaxTimestamp){
            
            maxtimestamp=reqMaxTimestamp;
                         
            for(Account acc : Accounts){
                if(maxtimestamp == null || maxtimestamp < acc.LastModifiedDate) maxtimestamp = acc.LastModifiedDate;   
                for(Contact con : acc.Contacts)
                {
                    if(maxtimestamp == null || maxtimestamp < con.LastModifiedDate) maxtimestamp = con.LastModifiedDate;               
                }
                for(Touchpoint_Program__c tpp : acc.Account_Plans__r)
                {
                    if(maxtimestamp == null || maxtimestamp < tpp.LastModifiedDate) maxtimestamp = tpp.LastModifiedDate;               
                }                  
            } 
            
            if(accounts.size()<queryLimit)
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
                queryMore=true;
                lastId=(String)Accounts.get(queryLimit-1).ID;          
            }
           timestamp=pagetimestamp;            
        }       
    }
    
}