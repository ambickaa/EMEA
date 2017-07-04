//-------------------------------------------------------
// Apex class  AccountPageMarkCampController
// Test class  AccountPageMarkCampController_Test
// Author    Support Team
// Last update  30/03/2017
//-------------------------------------------------------
public with sharing class AccountPageMarkCampController {

//-------------------------------------------------------
// Initialization of the list of displayed records
// retrieved from the method getRecords().
//-------------------------------------------------------
    public List<Campaign> List_Records {
        get {
            if(List_Records == null) {
                getRecords();
            }
            return List_Records;
        }
        private set;
    }

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
    	return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;} 

    
//-------------------------------------------------------
// Getting the set of fields to display for campaign section.
//-------------------------------------------------------
    public List<Schema.FieldSetMember> FieldSet_Component
    {
      get {
        if(FieldSet_Component == null)
        {
//-------------------------------------------------------
// A different fieldSet is obtained based on the type of
// the account and the country of the current user.
//-------------------------------------------------------
          String AccountType = '';
          if(isFarmAccount) AccountType = '_Farm_';
          if(isDistAccount) AccountType = '_Dist_';
          
          //system.debug('!Util.currentUser.CountryISOCode__c: ' + Util.currentUser.CountryISOCode__c);
          //system.debug('!Util.countryView.country.TXT_Country_ISO_Code__c: ' + Util.countryView.country.TXT_Country_ISO_Code__c);
        
          String countryISO = Util.countryView.country.TXT_Country_ISO_Code__c != null ? Util.countryView.country.TXT_Country_ISO_Code__c : (Util.currentUser.CountryISOCode__c != null ? Util.currentUser.CountryISOCode__c : '');
              
          if(countryISO != '')
          {
            if(SObjectType.Campaign.FieldSets.getMap().get('AccountPage_Marketing' + AccountType + countryISO) != null)
              FieldSet_Component = SObjectType.Campaign.FieldSets.getMap().get('AccountPage_Marketing' + AccountType + countryISO).getFields();
            else
              FieldSet_Component = SObjectType.Campaign.FieldSets.getMap().get('AccountPage_Marketing' + AccountType + 'Default').getFields();
          }  else {
          
          FieldSet_Component = SObjectType.Campaign.FieldSets.getMap().get('AccountPage_Marketing' + AccountType + 'Default').getFields();
          }
        }
        return FieldSet_Component;
      } protected set;
    }   
    
    
//-------------------------------------------------------
// Apex class constructor, calling the empty ini() method.
//-------------------------------------------------------
    public AccountPageMarkCampController()
    {
        ini();
    }

//-------------------------------------------------------
// Initial empty method.
//-------------------------------------------------------
    private void ini()
    {
        system.debug('***INI: AccountPageMarkCampController');
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
//-------------------------------------------------------
    private void getRecords()
    {
      Set<ID>SetCampaigns = new Set<ID>();
      for (CampaignMember CampMember :[SELECT Id, CampaignId FROM CampaignMember WHERE ContactId IN (SELECT Id FROM Contact WHERE AccountId =: Util.currentAccount.Id)]){
          SetCampaigns.add(CampMember.CampaignId);
      }
      
      system.debug('Campaigns IDs: ' + SetCampaigns);
      
      List_Records = new List<Campaign>();
      
      String StringCampaigns ='';
      
      for ( ID CampItem : SetCampaigns){
          If (StringCampaigns==''){
              StringCampaigns += '\''+ CampItem + '\'';
          } else{
              StringCampaigns += ',\''+CampItem + '\'';
          }
      }
      String q = '';
      q += 'SELECT Id';
      //-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
    for(Schema.FieldSetMember f : FieldSet_Component)
    {
        if(f.getFieldPath() != 'Id')
            q += ', ' + f.getFieldPath();
    }
        
        q += ' FROM Campaign';
        q += ' WHERE ID IN (' + StringCampaigns + ') and recordtypeid = \'' + Util.recordType.get('Campaign:Marketing_campaign') + '\'';
//-------------------------------------------------------
// The list of records is populated only when the current account
// is a farm or a distributor with an existent current campaign.
//-------------------------------------------------------
    if((isFarmAccount || isDistAccount) && (SetCampaigns.size()>0))
          List_Records = (List<Campaign>)Database.query(q);
    }

}