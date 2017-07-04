public class TriggerCampaignUpdateTargets implements Triggers.Handler {

  //--------------------
  // TriggerCampaignUpdateTargets is triggered before updating Campaign
  //--------------------
  public void handle() {

    Map<Id, Schema.RecordTypeInfo> Map_RecordTypeCampaign = Schema.SObjectType.Campaign.getRecordTypeInfosById();

    //--------------------
    // Different Sets are initialized.
    //--------------------
    Set<Id> Set_OwnerId = new Set<Id>();
    Set<Id> Set_DivisionId = new Set<Id>();
    Set<Id> Set_UsersToUpdate= new Set<Id>();

    for(sObject cmp : Trigger.old) {
      Campaign campaign = (Campaign) cmp;

      //--------------------
      // Different Sets are populated.
      //--------------------
      Set_OwnerId.add(campaign.OwnerId);
      Set_DivisionId.add(campaign.DivisionRef__c);
    }  

    //--------------------
    // Maps for users and divisions help to retrieve the whole object, with its corresponding fields.
    //--------------------
    Map<Id, Division__c> Map_Division = new Map<Id, Division__c>([SELECT Id, Name FROM Division__c WHERE Id IN : Set_DivisionId]); 
    Map<Id, User> Map_OwnerId_User = new Map<Id, User>([SELECT Id, NUM_Current_CornCampaign_Target__c, NUM_Current_OSRCampaign_Target__c, NUM_CURRENT_CAMPAIGN_HA_TARGET__c, NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c, NUM_POTENTIAL_HA_CORN__c, NUM_POTENTIAL_HA_OSR__c FROM User WHERE Id IN : Set_OwnerId]);

    //--------------------
    // Loop for all campaigns coming from the trigger onCampaign.
    //--------------------
    for(sObject cmp : Trigger.new) {
      Campaign newCampaign = (Campaign) cmp;
      Campaign oldCampaign = (Campaign) Trigger.oldMap.get(newCampaign.Id);

      User ownerCampaign = Map_OwnerId_User.get(newCampaign.ownerId);
      String divCampaign = Map_Division.get(newCampaign.DivisionRef__c) != null ? Map_Division.get(newCampaign.DivisionRef__c).Name : '';
      String recType = Map_RecordTypeCampaign.get(newCampaign.RecordTypeId).getName();

      //--------------------
      // Only for Sales campaigns that are active.
      //--------------------
      if(recType.equals('Sales Campaign') && newCampaign.isActive) {

        if(newCampaign.TotalCampaignBudget__c != oldCampaign.TotalCampaignBudget__c || newCampaign.Total_Campaign_Budget_Acreages__c != oldCampaign.Total_Campaign_Budget_Acreages__c || newCampaign.NUM_POTENTIAL_HA__c != oldCampaign.NUM_POTENTIAL_HA__c) {

          if(divCampaign.equals('Corn')) {

            ownerCampaign.NUM_Current_CornCampaign_Target__c = newCampaign.TotalCampaignBudget__c;
            ownerCampaign.NUM_CURRENT_CAMPAIGN_HA_TARGET__c = newCampaign.Total_Campaign_Budget_Acreages__c;
            ownerCampaign.NUM_POTENTIAL_HA_CORN__c = newCampaign.NUM_POTENTIAL_HA__c;
          } else if(divCampaign.equals('OSR')) {

            ownerCampaign.NUM_Current_OSRCampaign_Target__c = newCampaign.TotalCampaignBudget__c;
            ownerCampaign.NUM_CURRENT_OSRCAMPAIGN_HA_TARGET__c = newCampaign.Total_Campaign_Budget_Acreages__c;
            ownerCampaign.NUM_POTENTIAL_HA_OSR__c = newCampaign.NUM_POTENTIAL_HA__c;
          }
              //--------------------
              // In case that Budgets fields change, the owner campaign will be updated.
              // The ownerId populates a Set, in order to avoid duplicated values in the final list.
              //--------------------
          Set_UsersToUpdate.add(newCampaign.ownerId);   
        }
      }
    }

    //--------------------
    // Building the final list of users to update from the Set without duplicated values.
    //--------------------
    List<User> List_UsersToUpdate = new List<User>();
    for(Id ownerId : Set_UsersToUpdate)
      List_UsersToUpdate.add(Map_OwnerId_User.get(OwnerId));

    //--------------------
    // Updating users only if there's at least one record in the list.
    //--------------------
    if(List_UsersToUpdate.size() > 0)
      update List_UsersToUpdate;
  }
}