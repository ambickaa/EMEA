public without sharing class TriggerAccountSharingManager implements Triggers.Handler
{
    public static Set<Id> Set_Territory_Key = new Set<Id>();
    public static Set<Id> Set_InactiveUsers = new Set<Id>();
    public List<AccountShare> List_aShare_toInsert = new List<AccountShare>();
    public List<AccountShare> List_aShare_toDelete = new List<AccountShare>();
    
    public static Map<Id, Map<String, Id>> Map_Account_Data = new Map<Id, Map<String, Id>>();
    public static Map<Id, Boolean> Map_Users_IsActive = new Map<Id, Boolean>();
    public static Map<Id, Set<Id>> Map_Territory_Key_Users = new Map<Id, Set<Id>>();
    public static Map<Id, Set<String>> Map_Territory_Key_Alias = new Map<Id, Set<String>>();
    public static Map<Id, TerritoryManagement__c> Map_Territory_Key = new Map<Id, TerritoryManagement__c>();

    // --------------------------------------------------
    // Maps that only contain Manual Sharing
    // --------------------------------------------------
    public static Map<Id, List<AccountShare>> Map_aShare_Old = new Map<Id, List<AccountShare>>();
    
    private Boolean changeOwner = false;
    private Boolean changeTK = false;
    
    public static Boolean forceUpdate = false;
    public static Boolean ButtonSharetoUsers = false;
    
    // --------------------------------------------------
    // Main method to handle the AccountShare object
    // --------------------------------------------------
    public void handle()
    {
        if(trigger.isInsert)
        {
            if(trigger.isBefore)
            {
                for(Account a : (List<Account>)trigger.new)
                {
                    if(a.DE_Territory_Key__c != null)
                    {
                        Set_Territory_Key.add(a.DE_Territory_Key__c);
                    }
                    
                    if(new CountryAdapter(a.CountryRef__c).isGermanActionPlan)
                    {
                        a.IsCreateCampaignLineItem__c = false;
                    }
                }
                
                if(!Set_Territory_Key.isEmpty())
                {
                    getTMU();
                    setTMFields();
                }
            }
            if(trigger.isAfter)
            {
                for(Account a : (List<Account>)trigger.new)
                {
                    // --------------------------------------------------
                    // Inserting new Account Share related to the Territory Key
                    // --------------------------------------------------
                    if(a.DE_Territory_Key__c != null && Map_Territory_Key_Users.containsKey(a.DE_Territory_Key__c))
                    {
                        for(Id userId : Map_Territory_Key_Users.get(a.DE_Territory_Key__c))
                        {
                            if(userId != a.OwnerId && Map_Users_IsActive.get(userId))
                                List_aShare_toInsert.add(newAccountShare(a.Id, userId));
                        }
                    }
                }
            }
        }
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
            {
                for(Account a : (List<Account>)trigger.new)
                {
                    // --------------------------------------------------
                    // Populating a map for each account with NEW VALUES for
                    // OwnerId and DE_Territory_Key__c if some of them changes
                    // --------------------------------------------------
                    changeOwner = a.OwnerId != ((Account)trigger.oldMap.get(a.Id)).OwnerId;
                    changeTK = a.DE_Territory_Key__c != ((Account)trigger.oldMap.get(a.Id)).DE_Territory_Key__c;
                    
                    if(changeTK || changeOwner || forceUpdate)
                    {
                        Map_Account_Data.put(a.Id, new Map<String, Id>
                            {
                                'New:OwnerId' => a.OwnerId,
                                'New:DE_Territory_Key__c' => a.DE_Territory_Key__c,
                                'Old:OwnerId' => ((Account)trigger.oldMap.get(a.Id)).OwnerId,
                                'Old:DE_Territory_Key__c' => ((Account)trigger.oldMap.get(a.Id)).DE_Territory_Key__c
                            }
                        );
                        if(a.DE_Territory_Key__c != null)
                            Set_Territory_Key.add(a.DE_Territory_Key__c);
                        
                        if(((Account)trigger.oldMap.get(a.Id)).DE_Territory_Key__c != null)
                            Set_Territory_Key.add(((Account)trigger.oldMap.get(a.Id)).DE_Territory_Key__c);
                    }
                    
                    if(new CountryAdapter(a.CountryRef__c).isGermanActionPlan)
                    {
                        a.IsCreateCampaignLineItem__c = false;
                    }
                }

                if(!Map_Account_Data.isEmpty())
                {
                    getTMU();
                    setTMFields();
                    getInactiveUsers();
                    
                    // --------------------------------------------------
                    // Populating a map for each account with its OLD Manual AccountShare
                    // for those accounts whose OwnerId or DE_Territory_Key__c have changed
                    // --------------------------------------------------
                    for(AccountShare aShare : [SELECT
                        Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel
                        FROM AccountShare
                        WHERE AccountId IN :Map_Account_Data.keySet() AND RowCause = 'Manual'])
                    {
                        if(!Set_InactiveUsers.contains(aShare.UserOrGroupId))
                        {
                            if(!Map_aShare_Old.containsKey(aShare.AccountId))
                                Map_aShare_Old.put(aShare.AccountId, new List<AccountShare>{aShare});
                            else
                                Map_aShare_Old.get(aShare.AccountId).add(aShare);
                        }
                    }
                    
                    // --------------------------------------------------
                    // ButtonShareToUsers case
                    // --------------------------------------------------
                    if(ButtonShareToUsers)
                    {
                    	Map<Id, User> Map_User = new Map<Id, User>([SELECT Id, Alias FROM User WHERE IsActive = true]);
                    	for(Account a : (List<Account>)trigger.new)
						{
	                    	if(Map_aShare_Old.containsKey(a.Id))
	                    	{
	                    		for(AccountShare aShare : Map_aShare_Old.get(a.Id))
	                    		{
	                    			if(Map_User.containsKey(aShare.UserOrGroupId) && Map_User.get(aShare.UserOrGroupId).Alias != '' && Map_User.get(aShare.UserOrGroupId).Alias != null && !a.DE_Owners__c.contains(Map_User.get(aShare.UserOrGroupId).Alias))
	                    			{
	                    				if(a.DE_Owners__c != '') a.DE_Owners__c += '\n';
	                    				a.DE_Owners__c += Map_User.get(aShare.UserOrGroupId).Alias;
	                    				
	                    				if(a.DE_OwnersFlat__c != '') a.DE_OwnersFlat__c += ',';
	                    				a.DE_OwnersFlat__c += Map_User.get(aShare.UserOrGroupId).Alias;
	                    				a.DE_OwnersFlat__c = a.DE_OwnersFlat__c.left(255);
	                    			}
	                    		}
	                    	}
						}
                    }
                }
            }
            if(trigger.isAfter)
            {
                for(Id aId : Map_Account_Data.keySet())
                {
                    Map<String, Id> aData = Map_Account_Data.get(aId);

                    // --------------------------------------------------
                    // 1. The account Owner changes, but Territory Key doesn't
                    // --------------------------------------------------
                    if(aData.get('New:OwnerId') != aData.get('Old:OwnerId')
                        && aData.get('New:DE_Territory_Key__c') == aData.get('Old:DE_Territory_Key__c'))
                    {
                        if(Map_aShare_Old.containsKey(aId))
                        {
                            for(AccountShare aShare : Map_aShare_Old.get(aId))
                            {
                                if(aShare.UserOrGroupId != aData.get('New:OwnerId'))
                                {
                                    List_aShare_toInsert.add(newAccountShare(aShare));
                                }
                            }
                        }
                        if(Map_Territory_Key_Users.containsKey(aData.get('New:DE_Territory_Key__c')))
                        {
                            for(Id userId : Map_Territory_Key_Users.get(aData.get('New:DE_Territory_Key__c')))
                            {
                                if(userId == aData.get('Old:OwnerId') && Map_Users_IsActive.get(userId))
                                    List_aShare_toInsert.add(newAccountShare(aId, userId));
                            }
                        }
                    }
                    // --------------------------------------------------
                    // 2. The account Owner changes, and also the Territory Key
                    // --------------------------------------------------
                    else if(aData.get('New:OwnerId') != aData.get('Old:OwnerId')
                        && aData.get('New:DE_Territory_Key__c') != aData.get('Old:DE_Territory_Key__c'))
                    {
                        if(Map_aShare_Old.containsKey(aId))
                        {
                            for(AccountShare aShare : Map_aShare_Old.get(aId))
                            {
                                if(aShare.UserOrGroupId != aData.get('New:OwnerId')
                                    && (Map_Territory_Key_Users.get(aData.get('New:DE_Territory_Key__c')) == null
                                        || !Map_Territory_Key_Users.get(aData.get('New:DE_Territory_Key__c')).contains(aShare.UserOrGroupId))
                                    && (Map_Territory_Key_Users.get(aData.get('Old:DE_Territory_Key__c')) == null
                                        || !Map_Territory_Key_Users.get(aData.get('Old:DE_Territory_Key__c')).contains(aShare.UserOrGroupId)))
                                {
                                    List_aShare_toInsert.add(newAccountShare(aShare));
                                }
                            }
                        }
                    }
                    // --------------------------------------------------
                    // 3. The account Owner doesn't change, but Territory Key does
                    // --------------------------------------------------
                    else if((aData.get('New:OwnerId') == aData.get('Old:OwnerId')
                        && aData.get('New:DE_Territory_Key__c') != aData.get('Old:DE_Territory_Key__c'))
                        || forceUpdate)
                    {
                        if(Map_aShare_Old.containsKey(aId))
                        {
                            for(AccountShare aShare : Map_aShare_Old.get(aId))
                            {
                                if(aData.get('Old:DE_Territory_Key__c') != null
                                    && Map_Territory_Key_Users.containsKey(aData.get('Old:DE_Territory_Key__c'))
                                    && Map_Territory_Key_Users.get(aData.get('Old:DE_Territory_Key__c')).contains(aShare.UserOrGroupId)
                                    && (aData.get('New:DE_Territory_Key__c') == null
                                    || !Map_Territory_Key_Users.containsKey(aData.get('New:DE_Territory_Key__c'))
                                    || !Map_Territory_Key_Users.get(aData.get('New:DE_Territory_Key__c')).contains(aShare.UserOrGroupId)))
                                {
                                    List_aShare_toDelete.add(aShare);
                                }
                            }
                        }
                    }

                    // --------------------------------------------------
                    // 2 + 3. Inserting new Account Share related to the new Territory Key
                    // --------------------------------------------------
                    if(aData.get('New:DE_Territory_Key__c') != null
                        && (aData.get('New:DE_Territory_Key__c') != aData.get('Old:DE_Territory_Key__c') || forceUpdate))
                    {
                        if(Map_Territory_Key_Users.containsKey(aData.get('New:DE_Territory_Key__c')))
                        {
                            for(Id userId : Map_Territory_Key_Users.get(aData.get('New:DE_Territory_Key__c')))
                            {
                                if(userId != aData.get('New:OwnerId') && Map_Users_IsActive.get(userId))
                                    List_aShare_toInsert.add(newAccountShare(aId, userId));
                            }
                        }
                    }
                }
            }
        }

        // --------------------------------------------------
        // DML actions when lists to insert or delete records are not empty
        // --------------------------------------------------
        if(List_aShare_toInsert.size() > 0)
        {
            try
            {
                insert List_aShare_toInsert;
            }
            catch(DmlException e)
            {
                for(Integer i = 0; i < e.getNumDml(); i++)
                {
                    system.debug(e.getDmlMessage(i));
                }
            }
        }
        
        if(List_aShare_toDelete.size() > 0)
        {
            try
            {
                delete List_aShare_toDelete;
            }
            catch(DmlException e)
            {
                for(Integer i = 0; i < e.getNumDml(); i++)
                {
                    system.debug(e.getDmlMessage(i));
                }
            }
        }
        
        if(trigger.isUpdate && trigger.isAfter && !Map_Account_Data.isEmpty())
        	AccountSharingManager.updateChildrenSharing(trigger.newMap.keySet());
    }
    // --------------------------------------------------
    // Methods to create new records of manual AccountShare
    // --------------------------------------------------
    public AccountShare newAccountShare(AccountShare aShare)
    {
        AccountShare a = new AccountShare(
            AccountId = aShare.AccountId,
            UserOrGroupId = aShare.UserOrGroupId,
            AccountAccessLevel = aShare.AccountAccessLevel,
            ContactAccessLevel = aShare.ContactAccessLevel,
            CaseAccessLevel = aShare.CaseAccessLevel,
            OpportunityAccessLevel = aShare.OpportunityAccessLevel                          
        );
        return a;
    }

    public AccountShare newAccountShare(Id aId, Id userId)
    {
        AccountShare a = new AccountShare(
            AccountId = aId,
            UserOrGroupId = userId,
            AccountAccessLevel = 'Edit',
            ContactAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'                     
        );
        return a;
    }

    // --------------------------------------------------
    // Populating a map for each territory related to the changed
    // accounts, including the list of users related to them
    // --------------------------------------------------
    public void getTMU()
    {
        for(TerritoryManagementUser__c tmu : [SELECT
            Id, DE_UserRef__c, DE_UserRef__r.Alias, DE_UserRef__r.IsActive, DE_TerritoryManagementRef__c,
            DE_TerritoryManagementRef__r.DE_CountryRef__c, DE_TerritoryManagementRef__r.DE_StateProvince__c,
            DE_TerritoryManagementRef__r.DE_LandKreis__c, DE_TerritoryManagementRef__r.DE_LandKreis2__c,
            DE_TerritoryManagementRef__r.DE_CP__c, DE_TerritoryManagementRef__r.DE_Ort__c
            FROM TerritoryManagementUser__c
            WHERE DE_TerritoryManagementRef__c IN :Set_Territory_Key])
        {
            // --------------------------------------------------
            // It populates the map with Territory Management + List of users
            // --------------------------------------------------
            if(!Map_Territory_Key_Users.containsKey(tmu.DE_TerritoryManagementRef__c))
                Map_Territory_Key_Users.put(tmu.DE_TerritoryManagementRef__c, new Set<Id>{tmu.DE_UserRef__c});
            else
                Map_Territory_Key_Users.get(tmu.DE_TerritoryManagementRef__c).add(tmu.DE_UserRef__c);

            // --------------------------------------------------
            // It populates the map with Territory Management + List of alias (Active users)
            // --------------------------------------------------
            if(tmu.DE_UserRef__r.IsActive)
            {
                if(!Map_Territory_Key_Alias.containsKey(tmu.DE_TerritoryManagementRef__c))
                    Map_Territory_Key_Alias.put(tmu.DE_TerritoryManagementRef__c, new Set<String>{tmu.DE_UserRef__r.Alias});
                else
                    Map_Territory_Key_Alias.get(tmu.DE_TerritoryManagementRef__c).add(tmu.DE_UserRef__r.Alias);
            }
            
            // --------------------------------------------------
            // It populates the map with users and IsActive boolean
            // --------------------------------------------------
            Map_Users_IsActive.put(tmu.DE_UserRef__c, tmu.DE_UserRef__r.IsActive);
            
            if(!Map_Territory_Key.containsKey(tmu.DE_TerritoryManagementRef__c))
            {
                TerritoryManagement__c tm = new TerritoryManagement__c(
                    DE_CP__c = tmu.DE_TerritoryManagementRef__r.DE_CP__c,
                    DE_Ort__c = tmu.DE_TerritoryManagementRef__r.DE_Ort__c,
                    DE_LandKreis__c = tmu.DE_TerritoryManagementRef__r.DE_LandKreis__c,
                    DE_LandKreis2__c = tmu.DE_TerritoryManagementRef__r.DE_LandKreis2__c,
                    DE_CountryRef__c = tmu.DE_TerritoryManagementRef__r.DE_CountryRef__c,
                    DE_StateProvince__c = tmu.DE_TerritoryManagementRef__r.DE_StateProvince__c
                );
                Map_Territory_Key.put(tmu.DE_TerritoryManagementRef__c, tm);
            }
        }
        // --------------------------------------------------
        // The query for TerritoryManagement__c is necessary because not all TerritoryManagement__c have related TMUs
        // --------------------------------------------------
        if(Set_Territory_Key.size() != Map_Territory_Key.size())
        {
            for(TerritoryManagement__c tm : [SELECT
                Id, DE_CP__c, DE_Ort__c, DE_LandKreis__c, DE_LandKreis2__c, DE_CountryRef__c, DE_StateProvince__c
                FROM TerritoryManagement__c
                WHERE Id IN :Set_Territory_Key AND Id NOT IN :Map_Territory_Key.keySet()])
            {
                Map_Territory_Key.put(tm.Id, tm);
            }
        }
    }

    // --------------------------------------------------
    // It updates the account fields related to the Territory
    // --------------------------------------------------
    public void setTMFields()
    {
        for(Account a : (List<Account>)trigger.new)
        {
            if(trigger.isUpdate && a.DE_Territory_Key__c == null)
            {
                if(a.GC_Integration_Key__c == null || a.GC_Integration_Key__c == '')
                {
                    a.City__c = '';
                    a.County__c = '';
                    a.DE_ZIP_PLZ__c = '';
                    a.DE_Landkreis__c = '';
                    a.StateProvince__c = '';
                }
                a.DE_Owners__c = '';
                a.DE_OwnersFlat__c = '';
            }
            
            if((a.GC_Integration_Key__c == null || a.GC_Integration_Key__c == '')
                && a.DE_Territory_Key__c != null
                && Map_Territory_Key.get(a.DE_Territory_Key__c) != null)
            {
                TerritoryManagement__c tm = Map_Territory_Key.get(a.DE_Territory_Key__c);

                a.City__c = (tm.DE_Ort__c != null && !'-'.equals(tm.DE_Ort__c)) ? tm.DE_Ort__c : a.City__c;
                a.DE_ZIP_PLZ__c = (tm.DE_CP__c != null && !'-'.equals(tm.DE_CP__c)) ? tm.DE_CP__c : a.DE_ZIP_PLZ__c;
                a.County__c = (tm.DE_LandKreis2__c != null && !'-'.equals(tm.DE_LandKreis2__c)) ? tm.DE_LandKreis2__c : a.County__c;
                a.CountryRef__c = (tm.DE_CountryRef__c != null && !'-'.equals(tm.DE_CountryRef__c)) ? tm.DE_CountryRef__c : a.CountryRef__c;
                a.DE_Landkreis__c = (tm.DE_LandKreis__c != null && !'-'.equals(tm.DE_LandKreis__c)) ? tm.DE_LandKreis__c : a.DE_Landkreis__c;
                a.StateProvince__c = (tm.DE_StateProvince__c != null && !'-'.equals(tm.DE_StateProvince__c)) ? tm.DE_StateProvince__c : a.StateProvince__c;
                
                if(Map_Territory_Key_Alias.containsKey(a.DE_Territory_Key__c))
                {
                    a.DE_Owners__c = format(Map_Territory_Key_Alias.get(a.DE_Territory_Key__c), '\n');
                    a.DE_OwnersFlat__c = format(Map_Territory_Key_Alias.get(a.DE_Territory_Key__c), ',').left(255);
                }
            }
            if(a.DE_Territory_Key__c != null && !Map_Territory_Key_Alias.containsKey(a.DE_Territory_Key__c))
            {
                a.DE_Owners__c = '';
                a.DE_OwnersFlat__c = '';
            }
        }
    }
    
    // --------------------------------------------------
    // It gets the inactive users of the system
    // --------------------------------------------------
    public void getInactiveUsers()
    {
        if(Set_InactiveUsers.isEmpty())
        {
            for(User u : [SELECT Id FROM User WHERE IsActive = false])
                Set_InactiveUsers.add(u.Id);
        }
    }

    // --------------------------------------------------
    // It converts the set of alias in a formatted string
    // --------------------------------------------------
    public String format(Set<String> alias, String separator)
    {
        String result = '';
        Integer i = 0;
        for(String s : alias)
        {
            result += (i == 0 ? '' : separator) + s;
            i++;
        }
        return result;
    }
}