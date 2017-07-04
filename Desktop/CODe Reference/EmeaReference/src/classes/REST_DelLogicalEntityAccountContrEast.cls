@RestResource(urlMapping='/getDeletedLogicalEntity/Account/*')
global with sharing class REST_DelLogicalEntityAccountContrEast{

    @HttpPost
    global static REST_DelLogicalEntity_Account getDeletedAccounts(REST_DelLogicalEntity_Account paramInfo)
    {
        REST_DelLogicalEntity_Account returned = new REST_DelLogicalEntity_Account();
        
        returned.accounts = new List<Account>();
        Map<ID,Account> paramInfoAccounts = new Map<ID,Account>(paramInfo.accounts);
        Set<ID> paramInfoAccountIDs = paramInfoAccounts.keySet();
        
        Map<ID,Account> currentAccounts = new Map<ID,Account>([SELECT ID FROM Account WHERE ID IN :paramInfoAccountIDs]);
        Set<ID> currentAccountIDs = currentAccounts.keySet();
        
        paramInfoAccountIDs.removeAll(currentAccountIDs);
        for(ID i : paramInfoAccountIDs){
            returned.accounts.add(paramInfoAccounts.get(i));
        }
        
        
        returned.contacts = new List<Contact>();
        Map<ID,Contact> paramInfoContacts = new Map<ID,Contact>(paramInfo.Contacts);
        Set<ID> paramInfoContactIDs = paramInfoContacts.keySet();
        
        Map<ID,Contact> currentContacts = new Map<ID,Contact>([SELECT ID FROM Contact WHERE ID IN :paramInfoContactIDs]);
        Set<ID> currentContactIDs = currentContacts.keySet();
        
        paramInfoContactIDs.removeAll(currentContactIDs);
        for(ID i : paramInfoContactIDs){
            returned.Contacts.add(paramInfoContacts.get(i));
        }
        
        returned.touchpoints = new List<Touchpoint_Program__c>();
        Map<ID,Touchpoint_Program__c> paramInfoTPP = new Map<ID,Touchpoint_Program__c>(paramInfo.touchpoints);
        Set<ID> paramInfoTPPIDs = paramInfoTPP.keySet();
        
        Map<ID,Touchpoint_Program__c> currentTPP = new Map<ID,Touchpoint_Program__c>([SELECT ID FROM Touchpoint_Program__c WHERE ID IN :paramInfoTPPIDs]);
        Set<ID> currentTPPIDs = currentTPP.keySet();
        
        paramInfoTPPIDs.removeAll(currentTPPIDs);
        for(ID i : paramInfoTPPIDs){
            returned.touchpoints.add(paramInfoTPP.get(i));
        }
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Account getExample()
    {
        REST_DelLogicalEntity_Account returned = new REST_DelLogicalEntity_Account();
        
        returned.accounts = [SELECT ID FROM Account LIMIT 2];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Account {
        public List<Account> accounts;
        public List<Contact> contacts;
        public List<Touchpoint_Program__c> touchpoints;
    }

}