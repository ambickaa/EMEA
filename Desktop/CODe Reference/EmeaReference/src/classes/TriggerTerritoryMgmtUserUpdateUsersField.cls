/**
        This Class fills in the TXT_SharedUsers__c field with those users sharing records because of Territory keys
        Support Team 
***/
public without sharing class TriggerTerritoryMgmtUserUpdateUsersField implements Triggers.Handler {
    public void handle(){
        
        Set<Id> userIds = new Set<Id>(); 
        Map<Id, String> idVsAlias = new Map<Id, String>();
        List<TerritoryManagement__c> tm2Update= new List<TerritoryManagement__c>();
        if(!trigger.isDelete){
            Map<Id, List<String>> usersPerTM = new Map<Id, List<String>>();
            for(TerritoryManagementUser__c tmu : (List<TerritoryManagementUser__c>)trigger.new){
                usersPerTM.put(tmu.DE_TerritoryManagementRef__c, new list<String>()); 
                userIds.add(tmu.DE_UserRef__c);
            }           
                
            for(TerritoryManagementUser__c tmu : [SELECT DE_TerritoryManagementRef__c, DE_UserRef__r.Alias 
                                                 FROM TerritoryManagementUser__c 
                                                 WHERE DE_TerritoryManagementRef__c IN :usersPerTM.keySet()]){ 
                List<String> auxList= usersPerTM.get(tmu.DE_TerritoryManagementRef__c);
                auxlist.add(tmu.DE_UserRef__r.Alias);                               
                usersPerTM.put(tmu.DE_TerritoryManagementRef__c, auxlist) ; 
                userIds.add(tmu.DE_UserRef__c);
            }
                  
            for (Id iter : usersPerTM.KeySet()){
                String alias='';
                for(String userAlias : usersPerTM.get(iter)){
                    alias += userAlias+',';
                }
                
                if(alias != '') alias = alias.substring(0,(alias.length())-1);
                /*** The following line avoid the field exception because of inserts of length greater than 255  ***/
                if(alias.length() > 255) alias=alias.substring(0, 253)+'*';
                
                TerritoryManagement__c tM = new TerritoryManagement__c(Id=iter, TXT_SharedUsers__c=alias);
                tm2Update.add(tM);
            }
        } else {
            Map<Id, List<Id>> usersPerTM = new Map<Id, List<Id>>();
            for(TerritoryManagementUser__c tmu : (List<TerritoryManagementUser__c>)trigger.old){
                if(!usersPerTM.containsKey(tmu.DE_TerritoryManagementRef__c)) usersPerTM.put(tmu.DE_TerritoryManagementRef__c, new list<Id>{tmu.DE_UserRef__c}); 
                else {
                    List<Id> auxList= usersPerTM.get(tmu.DE_TerritoryManagementRef__c);
                    auxList.add(tmu.DE_UserRef__c);                         
                    usersPerTM.put(tmu.DE_TerritoryManagementRef__c, auxList);
                }
                userIds.add(tmu.DE_UserRef__c);
            }
            
            for(User user : [SELECT Id, Alias FROM User WHERE Id IN: userIds]){
                idVsAlias.put(user.Id, user.Alias);
            }
            
            for (TerritoryManagement__c tm : [ SELECT ID, TXT_SharedUsers__c FROM TerritoryManagement__c WHERE Id IN : usersPerTM.keySet()]){
                for(Id user : usersPerTM.get(tm.id)){
                    if(tm.TXT_SharedUsers__c.contains(idVsAlias.get(user)+','))tm.TXT_SharedUsers__c=tm.TXT_SharedUsers__c.replace(idVsAlias.get(user)+',','');                 
                    else if(tm.TXT_SharedUsers__c.contains(','+idVsAlias.get(user)))tm.TXT_SharedUsers__c=tm.TXT_SharedUsers__c.replace(','+idVsAlias.get(user),'');                    
                         else tm.TXT_SharedUsers__c=tm.TXT_SharedUsers__c.replace(idVsAlias.get(user),'');
                }
                
                tm2Update.add(tm);  
            }
        }
        Database.saveResult[] sR = Database.update(tm2Update, true);
    }
}