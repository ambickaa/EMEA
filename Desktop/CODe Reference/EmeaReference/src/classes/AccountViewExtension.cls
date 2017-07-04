public virtual class AccountViewExtension
{
    public static String anchor {get; set;}
    public String viewLog {get;set;}
    public string currentDivision{get;set;}
    public Division__c  currentUserDivision{get{ return Util.currentDivision; } set;}
    public boolean isCpStandard{set;}
    private List<CampaignLineItem__c> giveaways;
    public Account acct{get;set;} 
    public AccountViewExtension( ApexPages.StandardController stdController )
    {
    
        //HISTORICAL GIVE AWAYS DATA FOR RELATED LIST  
        this.acct= (Account) stdController.getRecord();
        acct.NUM_Locale_Test__c = 100010/100;
            
        anchor = '';
        viewLog='false';
        if(SystemSettings__c.getValues('RSA_viewLog')!=null)
           viewLog=SystemSettings__c.getValues('RSA_viewLog').Value__c;
        Util.setCurrentAccount( ((Account) stdController.getRecord()).id);
 
        if(Util.currentCampaign == null)
        {
            
            Util.addErrorMessage(Label.ErrorMsgNoCampaign);
        }
        else
        {
            //Util.addInfoMessage('CampaignId: '+Util.currentCampaign.Id);
        }
        if(!Util.isAccountOwner)
        {
            Util.addErrorMessage(Label.ErrorMsgNotOwner);
        }

        if(Util.countryView.country == null)
        {
            Util.addWarningMessage(Label.ErrorMsgNoAccountCountry);
        }

        //Util.addInfoMessage('DivisionId: '+Util.divisionId);

        if(!Util.hasPermissionsForCampaignLineItemEdit)
        {
            Util.addErrorMessage('No CampaignLineItems related permissions (Not Account Owner and / or no active Campaign)');
        }
    }
    
    public List<CampaignLineItem__c> getGiveAways()
        {
            Integer YearFilter = Integer.valueOf((Util.currentYear).Name)-3;
            giveaways= [Select id, ProductRef__r.Name, ProductRef__c, Quantity__c,CreatedDate, Year__c,CreatedBy.Name,TotalPriceGiveAway__c FROM CampaignLineItem__c where FarmRef__c = :acct.id and RecordType.name = 'GiveAway' and CampaignRef__r.YearV2__r.NUM_YEAR__c > :YearFilter  order by year__c desc,productref__r.name asc];
            return giveaways;
        }
    
    public String divisionColor
    {
        get
        {
        return Util.currentDivision.color__c;
        }
        set;
    }
    
    public String divisionId
    {
        get
        {
            
            return Util.currentDivision.id;
        }
        set;
    }
    
    public Boolean getIsAutoCreateAcreages()
    {
        return Util.countryView.isAutoCreateAcreages();
    }
    
    public Boolean getIsRSAView()
    {
                return Util.countryView.isRSATacticalPlan;
    }
    public Boolean getIsGermanView()
    {
                return Util.countryView.isGermanActionPlan;
    }
    
    //New implem for CP Action Plan
    public Boolean getIsGermanCPview()
    {
            return Util.countryView.isGermanCPActionPlan;
    }
    
    public Boolean getIsCpStandard()
    {
        return util.isCpStandard;
    }
    
    public Boolean getIsCpUser()
    {
        return (currentUserDivision.name.equalsIgnoreCase('CP')||currentUserDivision.name.equalsIgnoreCase('Roundup')||currentUserDivision.name.equalsIgnoreCase('Monitor')||currentUserDivision.name.equalsIgnoreCase('Monfast')||currentUserDivision.name.equalsIgnoreCase('Latitude')||currentUserDivision.name.equalsIgnoreCase('Guardian Tetra')||currentUserDivision.name.equalsIgnoreCase('Harness')||currentUserDivision.name.equalsIgnoreCase('Actimum'));
    }
    
    public String getUserCountry()
    {
        return Util.currentUser.Country;
    }
    
    public Boolean getIsMoreThanOneCampaign()
    {
        List<Campaign> actCampCount= [SELECT Id FROM Campaign WHERE OwnerId = :util.currentUser.Id AND isActive=true ];
        return actCampCount.size()>1;
    }
  
    
    public Boolean getIsVoucherEnabled()
    {
                return UtilREST.VoucherEnabled;
    }
    
    // French change
    public Boolean getIsStandardTrial(){
        return Util.countryView.isStandardTrial;
    }
    // French change
    
    public Boolean getIsGermanyAcreages()
    {
    
        if (Util.countryView.isGermanActionPlan)
        {
            if (Util.currentAccount.RecordType.name != 'Dist./Ret./PoS')
            {
                return true;
            }else
            {
                return false;
            }
        }else
        {
            return true;
        }
        
        
    }
    
    // French change
    public boolean getIsFrenchAcreages(){
        return Util.countryView.isFrenchAcreages;
    }
    public boolean getIsFrenchTacticalPlan(){
        return Util.countryView.isFRTacticalPlan;
    }
    
    // French change
    
    
    //Generic Change
    public boolean getIsGenericAcreages(){
        return Util.countryView.isGenericAcreages;
    }
    public boolean getIsGenericTacticalPlan(){
        return Util.countryView.isGenericTacticalPlan; 
    }
    //Generic Change
    
    //New AP for Dist change
    public Boolean getIsDist (){
        if (Util.currentAccount.RecordType.name == 'Dist./Ret./PoS')
        {
            return true;
        }else 
        {
            return false;
        }
    }
    //New AP for Dist change

}