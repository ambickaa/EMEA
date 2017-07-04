//-------------------------------------------------------
// Apex class  AccountPageRetoureController
// Test class  AccountPageRetoureController_Test
// Author    Support Team
// Last update  30/03/2017 by Support Team
//-------------------------------------------------------
public with sharing class AccountPageRetoureController
{
    public Division__c currentDivision { get { return Util.currentDivision; } set;}
    private Map<Id, Retoure__c> Map_Records;
    public Retoure__c Retoure {get; set;}

//-------------------------------------------------------
// Initialization of all boolean variables.
//-------------------------------------------------------
    public Boolean modeEdit {get; set;}
    public Boolean showRetoureMessages {get; set;}
    public Boolean isOwner {get { return Util.isAccountOwner; } protected set;}
    public Boolean isFarmAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite');} protected set;}
    public Boolean isDistAccount {get { return Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS');} protected set;}
    public Boolean isAdmin {get { Set<String> Set_AdminProfiles = new Set<String>{'System Administrator', 'Data Management', 'Support'};
    	return Set_AdminProfiles.contains(Util.currentUser.Profile.Name);} protected set;}
    
	public AccountPageRetoureController()
	{
		system.debug('INI: AccountPageRetoureController');
		
        showRetoureMessages = modeEdit = false;
    }

    //-------------------------------------------------------
// Getting the set of fields to display for the records.
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
			//if(isFarmAccount) AccountType = '_Farm_';
			//if(isDistAccount) AccountType = '_Dist_';
    
			String countryISO = Util.countryView.country.TXT_Country_ISO_Code__c != null ? Util.countryView.country.TXT_Country_ISO_Code__c : (Util.currentUser.CountryISOCode__c != null ? Util.currentUser.CountryISOCode__c : '');
        
              if(countryISO != '')
              {
                  if(SObjectType.Retoure__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO) != null)
                      FieldSet_Component = SObjectType.Retoure__c.FieldSets.getMap().get('AccountPage' + AccountType + countryISO).getFields();
                  else
                      FieldSet_Component = SObjectType.Retoure__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
              } else {
                  FieldSet_Component = SObjectType.Retoure__c.FieldSets.getMap().get('AccountPage' + AccountType + 'Default').getFields();
              }
			}
            return FieldSet_Component;
        } protected set;
    }

    //-------------------------------------------------------
// Initialization of the list of displayed records retrieved
// from the method getRecords() and other important maps and lists.
//-------------------------------------------------------
    public List<Retoure__c> List_Records {
        get {
            if(List_Records == null) {
                getRecords();
            }
            return List_Records;
        }
        private set;
    }

//-------------------------------------------------------
// Method to retrieve the current campaign for the Visualforce component.
//-------------------------------------------------------
    public Campaign currentCampaign {
      get {
        if(currentCampaign == null && Util.currentCampaign != null)
          currentCampaign = Util.currentCampaign;
        return currentCampaign;
      } 
      private set;
    }

//-------------------------------------------------------
// Method to retrieve the current year for the Visualforce component.
//-------------------------------------------------------
    public String currentYear {
      get {
        if(currentYear == null)
        {
			if(Util.currentCampaign != null) currentYear = currentCampaign.YearV2__r.Name;
			else currentYear = Util.currentYear.Name;
        }
        return currentYear;
      } 
      private set;
    }

//-------------------------------------------------------
// Method to retrieve the existent records.
//-------------------------------------------------------

    private void getRecords()
        {
            Map_Records = new Map<Id, Retoure__c>();
            List_Records = new List<Retoure__c>();
            
            String q = 'SELECT Id, Name, TXT_Bemerkung__c, Vorlieferant1__r.Name, Vorlieferant2__r.Name, Vorlieferant3__r.Name';
//-------------------------------------------------------
// Using the fieldSet to query all necessary fields, taking some of them out
// when they are essential for the Visualforce page to avoid duplicate values.
//-------------------------------------------------------
            for(Schema.FieldSetMember f : FieldSet_Component)
            {
                if(f.getFieldPath() != 'Id' && f.getFieldPath() != 'Name' && f.getFieldPath() != 'TXT_Bemerkung__c')
                    q += ', ' + f.getFieldPath();
            }
            q += ' FROM Retoure__c';
            q += ' WHERE Account__c = \'' + Util.currentAccount.Id + '\'';
            q += ' AND Division__c = \'' + Util.currentDivision.Id + '\'';
            q += ' AND TXT_year__c = \'' + currentYear + '\'';

            List_Records = (List<Retoure__c>)Database.query(q);
//-------------------------------------------------------
// Key map to recover data on update/insert actions.
//-------------------------------------------------------
            if (List_Records.size() == 0) {
                Retoure__c Retoure = new Retoure__c();
                Retoure.Account__c = Util.currentAccount.Id;
                Retoure.Division__c = Util.currentDivision.Id;
                Retoure.TXT_year__c = currentYear;
                List_Records.add(Retoure);
            }

            for(Retoure__c r : List_Records)
            {
                Map_Records.put(r.Id, r);
            }
        }

//-------------------------------------------------------
// This method enables the Edit mode, where the selected
// records are editable.
// - It gets records through getRecords()
// - It enables the Edit mode
//-------------------------------------------------------
    public void modeEdit()
    {
        getRecords();
        modeEdit = true;
    }

//-------------------------------------------------------
// This method disables the Edit mode.
// - It gets records through getRecords()
// - It disables the Edit mode.
//-------------------------------------------------------
    public void cancelModes()
    {
        getRecords();
        modeEdit = false;
    }

    public void doSave()
    {
            if(modeEdit)
            {
                if (List_Records != null && List_Records.size() > 0)
                {
                    Retoure = List_Records[0]; 
                    
                    //Before Save or Insert check that the MENGE can not be greater than the POG of the Excel Products.
                    Decimal OSR_DECmenge=0;
                    Decimal Corn_DECmenge=0;
                    Boolean BOOcheckError=false;
                    
                    if(util.currentDivision.name == 'OSR')
                    {
                        for(CampaignLineItem__c ForAP : [SELECT POG__c FROM CampaignLineItem__c
                                                       WHERE CampaignRef__r.isActive=true
                                                       AND CampaignRef__r.Owner.ID=:userInfo.getUserID() 
                                                       AND FarmRef__r.ID=:Util.currentAccount.Id 
                                                       AND Type__c='Charged' 
                                                       AND ProductCatalogEntryRef__r.DE_isPremium__c =true 
                                                       AND ProductRef__r.ProductTreatment__c IN ('Thiram','Thiram+DMM')
                                                       AND CampaignRef__r.DivisionRef__c=:Util.divisionId])
                                                       {
                                                           if(ForAP.POG__c <> null) OSR_DECmenge = OSR_DECmenge + ForAP.POG__c;
                                                       }                        
                        
                        //If the MENGE is greater than POG then display the error:
                                        
                        if(Retoure.FruekaufMenge__c > OSR_DECmenge){system.debug('*****4');Util.addErrorMessage(Label.AccountPage_Message_Fruhkauf_Menge + ' ' + OSR_DECmenge); BOOcheckError = true;}
                        if(Retoure.RabattMenge__c > OSR_DECmenge){system.debug('*****5');Util.addErrorMessage(Label.AccountPage_Message_Extrarabatt_Menge + ' ' + OSR_DECmenge); BOOcheckError = true;}
                    }
                    
                    if(util.currentDivision.name == 'Corn')
                    {
                        for(CampaignLineItem__c ForAP : [SELECT POG__c FROM CampaignLineItem__c
                                                       WHERE CampaignRef__r.isActive=true
                                                       AND CampaignRef__r.Owner.ID=:userInfo.getUserID() 
                                                       AND FarmRef__r.ID=:Util.currentAccount.Id 
                                                       AND Type__c='Charged'
                                                       AND ProductCatalogEntryRef__r.CHK_ZVD__c =true
                                                       AND CampaignRef__r.DivisionRef__c=:Util.divisionId])
                                                       {
                                                           if(ForAP.POG__c <> null) Corn_DECmenge = Corn_DECmenge + ForAP.POG__c;
                                                       }

                        //If the MENGE is greater than POG then display the error:
                                        
                        if(Retoure.FruekaufMenge__c > Corn_DECmenge){system.debug('*****6'); Util.addErrorMessage(Label.AccountPage_Message_Fruhkauf_Menge + ' ' + Corn_DECmenge); BOOcheckError = true;}
                        if(Retoure.RabattMenge__c > Corn_DECmenge){system.debug('*****7');Util.addErrorMessage(Label.AccountPage_Message_Extrarabatt_Menge + ' ' + Corn_DECmenge); BOOcheckError = true;}
                    }                    
                    
                    if(BOOcheckError)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.AccountPage_msg_error_while_saving));
                    }
                    else
                    {
                        try
                        {
                            if(Retoure.Id == null) insert  Retoure;
                            else                   update Retoure;
                            cancelmodes();
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.AccountPage_msg_confirm_update));
                        } 
                        catch (DMLException e)
                        {
                            for(Integer i = 0; i < e.getNumDml(); i++)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
                        }
                    }
                }
            }
            showRetoureMessages = true;
    }
}