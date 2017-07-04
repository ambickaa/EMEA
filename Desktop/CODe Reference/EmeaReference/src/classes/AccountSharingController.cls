public with sharing class AccountSharingController {

    private Account Account ;
    private transient Boolean accountSearched = false;    
    public List<UserWrapper> sharedUsers {get;set;}
    public List<UserWrapper> possibleUsers {get;set;}
    public Set<String> SetId {get; set;}
    
    public Account getAccount(){
        if(accountSearched == null || accountSearched == false){
            try{
                accountSearched = true;
                account = Util.currentAccount;
            }catch(Exception e){
                Util.addErrorMessage('Account does not exist or user does not have enough permissions');
            }
            if(account != null)
            {
            	SetId = new Set<String>();
            	
            	List<AccountShare> List_ac = [select id from AccountShare where userOrGroupID = :util.currentUser.id AND AccountAccessLevel != 'Read' and AccountID = :account.id];
            	            	
            	for(GroupMember gmem : [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Reponsibles'])
                		SetId.add(gmem.UserOrGroupId);
               
				if(List_ac.size() == 0 && !SetId.contains(util.currentUser.id))
				{
					account = null;
					Util.addErrorMessage('Only account owners are allowed to modify its sharing');
				}
            }
        }
        return account;
    }
    
    public AccountSharingController(){
        if(getAccount() == null) return;
        sharedUsers = new List<UserWrapper>();
        possibleUsers = new List<UserWrapper>();

        Set<ID> sharedUserIDs = new Set<ID>();

        Map<ID,User> allUsers = new map<ID,User>([SELECT Name, Division, StandardDivision__c, Country from User]);
        for(AccountShare AccShare : [SELECT AccountAccessLevel, RowCause, UserOrGroupId FROM AccountShare WHERE AccountID = :Account.ID and (RowCause = 'Owner' OR RowCause = 'Manual') ORDER BY AccountAccessLevel DESC]){
            sharedUsers.add(new UserWrapper(allUsers.get(AccShare.UserOrGroupId),AccShare.AccountAccessLevel, true));
            sharedUserIDs.add(AccShare.UserOrGroupId);
        }
        if(Util.currentUser.StandardDivision__c == Util.DIVISION_CORN ||
           Util.currentUser.StandardDivision__c == Util.DIVISION_OSR ||
           SetId.contains(util.currentUser.id))
        {
            for(User u : [SELECT Name, Division, StandardDivision__c FROM User WHERE Country = :Util.currentUser.Country and ID not in :sharedUserIDs AND isActive = true AND (StandardDivision__c = :Util.DIVISION_CORN OR StandardDivision__c = :Util.DIVISION_OSR) ORDER BY Name]){
                possibleUsers.add(new UserWrapper(u,'Edit', false));
            }
        }
		if(Util.currentUser.Division == Util.DIVISION_CP || SetId.contains(util.currentUser.id))
        {
            for(User u : [SELECT Name, Division, StandardDivision__c FROM User WHERE Country = :Util.currentUser.Country and ID not in :sharedUserIDs AND isActive = true AND (Division = :Util.DIVISION_CP) ORDER BY Name]){
                possibleUsers.add(new UserWrapper(u,'Edit', false));
            }
        }
    
    }
    public void add(){
        List<UserWrapper> newPossibleUsers = new List<UserWrapper>();
        for(UserWrapper uw : possibleUsers){
            (uw.selected?sharedUsers:newPossibleUsers).add(uw);
        }
        possibleUsers = newPossibleUsers;
    }
    
    public void save(){
        List<AccountShare> accountShareToInsert = new List<AccountShare>();
        List<CampaignLineItem__share> cliShareToInsert = new List<CampaignLineItem__share>();
        
        List<ID> newSharedUsers = new List<ID>();
        
        
        for(UserWrapper uw : sharedUsers){
            if(!uw.inDB){
                accountShareToInsert.add(new AccountShare(
                    AccountID = account.ID,
                    AccountAccessLevel = 'Edit', 
                    UserOrGroupId = uw.user.ID,
                    OpportunityAccessLevel = 'Read',
                    ContactAccessLevel = 'Edit'));
                newSharedUsers.add(uw.user.ID);
            }
        }
        
        try{
            //new sharingUpdater().accountShareInsert(accountShareToInsert);
            AccountSharingManager.accountShareInsert(accountShareToInsert);
            AccountSharingManager.updateChildrenSharing(new Set<ID>{Util.currentAccount.ID});
            //new TriggerCampaignLineItemSharingManager().updateRelatedAccountPermissions(new Set<ID>{Util.currentAccount.ID});
            triggerAccountSharingManager.forceUpdate = true;
            triggerAccountSharingManager.ButtonSharetoUsers = true;
            update account;
            Util.addConfirmMessage('Saved');
        }catch(Exception e)
        {
            Util.addErrorMessage('Unexpeted Error ( ' + e + ' )');
        }
    }
    public class UserWrapper{
        public Boolean selected {get;set;}
        public Boolean inDB {get;set;}
        public User user {get;set;}
        public String access {get;set;}
        
        public UserWrapper (User paramUser, String paramAccess, Boolean paramInDB){
            user = paramUser;
            selected = false;
            access = paramAccess;
            inDB = paramInDB;
        }
    } 
    public without sharing class sharingUpdater{
        public void accountShareInsert(List<AccountShare> paramShareToInsert){
            insert paramShareToInsert;
        }
    }
}