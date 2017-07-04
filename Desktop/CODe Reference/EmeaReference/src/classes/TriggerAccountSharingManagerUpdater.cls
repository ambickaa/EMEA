/**
    This Class run the batch that update the accounts in order to update the owner1, owner2
    Support Team 
***/
public without sharing class TriggerAccountSharingManagerUpdater implements Triggers.Handler {

    private static map<ID,Set<ID>> sharedUsers = new Map<ID,Set<ID>>(); // map<landkraisID,Set<userIDs>>
    private map<ID,Set<String>> sharedUsersAlias = new Map<ID,Set<String>>();// map<landkraisID,Set<Aliases of the owners>>
    private map<ID,Set<ID>> accountShare = new Map<ID,Set<ID>>(); // map<AccountID, Set<UserIDs with access>>
    private static map<ID,User> usersInfo {get{if(usersInfo == null) usersInfo = new Map<ID,User>([select alias from User]); return usersInfo;} set;}

    public static Boolean forceUpdate = false; // to allow others to force updates
    // public Set<TerritoryManagement__c> setTMs = new Set<TerritoryManagement__c>();
    
    public Set<ID> setTMs = new Set<ID>();
    public Set<ID> accountIDset = new Set<ID>();
    public Set<ID> setTMUs = new Set<ID>();
    public Set<ID> setTMs2 = new Set<ID>();
    public List<id> ListTMUs = new List<id>();
    public List<id> ListTMs = new List<id>();

    public void handle()
    {
            //This class doesn't wait for calling the batch although other batchs are running at the same time (Salesforce run batchs sequencially automatically)
            // Schedule the batch to be executed in 1 minutes if there are TMUs pending (Label "Label.Terr_Mgt_Offset_Minutes")
            boolean pendingFound = false;
            Integer i = 0;
            
        if(!trigger.isDelete)
        {
            //Select all TMUs to update
            setTMUs.addAll(trigger.newMap.KeySet());
            System.debug('The list of TMUs that pass the trigger is : ' +setTMUs);
            System.debug('The size of the TMUs list is: ' +setTMUs.size());
            
            //I see if there are TMUs that aren't processed
            while(i<trigger.new.size() && !pendingFound)
            {
                pendingFound = !((TerritoryManagementUser__c)trigger.new[i]).processed__c;
                i++;
            }
            
            //Run the batch here
            if(pendingFound)
            {
                Boolean Delet= false;              
                system.scheduleBatch(new TerritoryMgtUserUpdAccountBatch(UserInfo.getUserEmail(), setTMUs, Delet), 'TerritoryMgt ' + system.now() + ' ,id: '+ ((TerritoryManagementUser__c)trigger.new[0]).id, Integer.valueOf(Label.Terr_Mgt_Offset_Minutes), Integer.valueOf(Label.Terr_Mgt_Batch_Size));
            }
                     
        }
        
        else
        {
            //Select all TMUs to update
            setTMUs.addAll(trigger.oldMap.KeySet()); //Create a set to delete          

                for (TerritoryManagementUser__c tmu : [SELECT DE_TerritoryManagementRef__r.id FROM TerritoryManagementUser__c WHERE id IN:SetTMUs])
                    ListTMs.add(tmu.DE_TerritoryManagementRef__r.id);
                
                setTMs2.addAll(ListTMs);
                System.debug('The values to delete that are passed to the batch are: ' +setTMs2);
                //Run the batch here
                Boolean delet = true;
                system.scheduleBatch(new TerritoryMgtUserDelAccountBatch(UserInfo.getUserEmail(), setTMs2, delet), 'TerritoryMgt2 ' + system.now() + ' ,id: '+ ((TerritoryManagementUser__c)trigger.old[0]).id, Integer.valueOf(Label.Terr_Mgt_Offset_Minutes), Integer.valueOf(Label.Terr_Mgt_Batch_Size));
                
     
        }
    }
}