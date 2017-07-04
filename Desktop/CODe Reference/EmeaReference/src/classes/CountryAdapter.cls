/**
* This class allows to check the currentry country to display special country-specific view/content.
* You can set current country by Account or User.
* !!Important!!! Current status - we display content by account country.
* 
* If you need to display any content in dependence of country - you can just check countryCode field.
* If you need to check the same option many times - just add new method to this class and call it from any place.
* Example:
* public String getMyMegaCountrySpecificTitle()
* {
*   if (countryCode == CountryEnum.switzerland)
*   {
*       return 'Good country!!!!';
*   } else
*   {
*       return 'Bad country!!!!';
*   }
*
* !!!Please, DO NOT check country object/name directly in your controller/VF.
*/

public without sharing class CountryAdapter
{
    //Values for custom tactical plans.
    public static final String TACTICAL_PLAN_ITALIAN = 'Italian';
    public static final String TACTICAL_PLAN_UK = 'UK';
    /* French change */
    public static final String TACTICAL_PLAN_FR = '2.0';
    /* French change */
    
    /* Generic change */
    public static final String TACTICAL_PLAN_GENERIC = 'Generic';
    /* Generic change */
    
    
    public static final String TACTICAL_PLAN_RSA = 'RSA';
    
    //Valor CP Alemania
    public static final String CP_ACTION_PLAN_GERMAN = 'Standard';
    
    //Valor para Alemania
    public static final String ACTION_PLAN_GERMAN = 'German';
    
    //Value for standard tactical 
    public static final String TACTICAL_PLAN_STANDARD = 'Standard';
    
    //Mapping between Country name and Country code enum.
    public static final Map<String, CountryEnum> COUNTRY_CODE_MAP = new Map<String, CountryEnum> {
                    
                  'Bulgaria' => CountryEnum.bulgaria,
                  'Austria' => CountryEnum.austria,
                  'Italy' => CountryEnum.italy,
                  'Germany' => CountryEnum.germany,
                  'France' => CountryEnum.france,
                  'Hungary' => CountryEnum.hungary,
                  'Spain' => CountryEnum.spain,
                  'United Kingdom' => CountryEnum.uk,
                  'Ukraine' => CountryEnum.ukrain,
                  'Turkey' => CountryEnum.turkey,
                  'Switzerland' => CountryEnum.switzerland,
                  'South Africa' => CountryEnum.southAfrica,
                  'Denmark' => CountryEnum.denmark,
                  'Estonia' => CountryEnum.estonia,
                  'Finland' => CountryEnum.finland,
                  'Latvia' => CountryEnum.latvia,
                  'Lithuania' => CountryEnum.lithuania,
                  'Norway' => CountryEnum.norway,
                  'Portugal' => CountryEnum.portugal,
                  'Sweden' => CountryEnum.sweden,
                  'Russia' => CountryEnum.russia,
                  'Czech Republic' => CountryEnum.czechrepublic,
                  'Romania' => CountryEnum.romania,
                  'Slovakia' => CountryEnum.slovakia,
                  'Poland' => CountryEnum.poland,
                  'Serbia' => CountryEnum.serbia,
                  'Croatia' => CountryEnum.croatia};
    
    public static final Map<String, CountryEnum> COUNTRY_ISO_CODE_MAP = new Map<String, CountryEnum> {
                  
                  'IT' => CountryEnum.italy,
                  'DE' => CountryEnum.germany,
                  'FR' => CountryEnum.france,
                  'HU' => CountryEnum.hungary,
                  'SP' => CountryEnum.spain,
                  '??' => CountryEnum.uk,
                  'UA' => CountryEnum.ukrain,
                  'TR' => CountryEnum.turkey,
                  '???' => CountryEnum.switzerland,
                  'RSA' => CountryEnum.southAfrica,
                  'RU' => CountryEnum.russia,
                  'CZ' => CountryEnum.czechrepublic,
                  'RO' => CountryEnum.romania,
                  'SK' => CountryEnum.slovakia,
                  'PL' => CountryEnum.poland,
                  'RS' => CountryEnum.serbia,
                  'HR' => CountryEnum.croatia};
    
    
    //Country object
    public Country__c country{get;set;}
    
    // Map of all Countries in the Database
    public static Map<Id, Country__c> allCountryMap
    {
        get
        {
            if(allCountryMap == null)
            {
                allCountryMap = new Map<Id, Country__c>
                (
                    (List<Country__c>)Database.query(
                          new al.SoqlBuilder().selectx(new List<String>{'Id', 'Name', 'TXT_Country_ISO_Code__c', 'Area__r.TXT_Country_ISO_Code__c', 'TacticalPlanSetting__c', 'CP_TacticalPlanSetting__c',
                                /* French change */
                                  'Area__c', 'Area__r.Name', 'Area__r.Id', 'Area__r.TacticalPlanSetting__c','Area__r.CP_TacticalPlanSetting__c','Area__r.DE_EnableAccountSharing__c', 'IT_Block_Fields__c', 'DE_EnableAccountSharing__c', 'Area__r.TrialSetting__c', 'TrialSetting__c', 'AcreageSetting__c', 'Area__r.AcreageSetting__c', 'AccountViewPage__c', 'Area__r.AccountViewPage__c'})
                                 /* French change */
                          .fromx('Country__c')
                          .toSOQL())
                        );
            }
            return allCountryMap;
        }
        set;
    }
    
    public boolean isAccountSharingEnabled
    {
        get
        {
            if(isAccountSharingEnabled == null)
            {
                if(country != null)
                {
                    isAccountSharingEnabled = country.DE_EnableAccountSharing__c;
                }else
                {
                    isAccountSharingEnabled = false;
                }
            }
            return isAccountSharingEnabled;
        }set;
    }
    //NUEVO ALEMANIA
     public boolean isGermanActionPlan
    {
        get
        {
            if (isGermanActionPlan== null)
            {
                isGermanActionPlan= ACTION_PLAN_GERMAN.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isGermanActionPlan;
        }
        set;
    }
    
    //CP ALEMANIA
    
    public boolean isGermanCPActionPlan
    {
        get
        {
            if (isGermanCPActionPlan==null)
            {
                isGermanCPActionPlan=CP_ACTION_PLAN_GERMAN.equalsIgnoreCase(getCPTacticalPlanSetting()); 
            }
            return isGermanCPActionPlan;
        }
        set;
    }
    
    //Should we display Italian version instead of Standard?
    public boolean isItalianTacticalPlan
    {
        get
        {
            if (isItalianTacticalPlan == null)
            {
                isItalianTacticalPlan = TACTICAL_PLAN_ITALIAN.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isItalianTacticalPlan;
        }
        set;
    }
    
    // Is Italian change
    // Is Block fields an delete button
    public boolean isBlockFields
    {
        get
        {
            //if(country.Name == 'italy')
            //{

            isBlockFields = country.IT_Block_Fields__c;

                
            //}
            return isBlockFields;

        }set;
    }
    
    //Should we display UK version instead of Standard?
    public boolean isUKTacticalPlan
    {
        get
        {
            if (isUKTacticalPlan == null)
            {
                isUKTacticalPlan = TACTICAL_PLAN_UK.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isUKTacticalPlan;
        }
        set;
    }
    /* French change */
    //Evaluate if FR version should be displayed instead of Standard
    public boolean isFRTacticalPlan
    {
        get
        {
            if (isFRTacticalPlan == null)
            {
                isFRTacticalPlan = TACTICAL_PLAN_FR.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isFRTacticalPlan;
        }
        set;
    }
    /* French change */
    
    /* Generic change */
    public boolean isGenericAcreages
    {
        get
        {
            if(isGenericAcreages== null)
            {
                if(country != null)
                {
                    isGenericAcreages = country.AcreageSetting__c == 'Generic';
                }else
                {
                    isGenericAcreages = false;
                }
            }
            return isGenericAcreages;
        }set;
    }
    //Evaluate if GENERIC version should be displayed instead of Standard
    public boolean isGenericTacticalPlan
    {
        get
        {
            if (isGenericTacticalPlan == null)
            {
                isGenericTacticalPlan = TACTICAL_PLAN_GENERIC.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isGenericTacticalPlan;
        }
        set;
    }
    /* Generic change */
    
    //Should we display RSA version instead of Standard?
    public boolean isRSATacticalPlan
    {
        get
        {
            if(isRSATacticalPlan == null)
            {
                isRSATacticalPlan = TACTICAL_PLAN_RSA.equalsIgnoreCase(getTacticalPlanSetting());
            }
            return isRSATacticalPlan;
        }
        set;
    }
    
    /* French change */
    // Is Standard visualization of trials
    public boolean isStandardTrial
    {
        get
        {
            if(isStandardTrial == null)
            {
                if(country != null)
                {
                    isStandardTrial = country.TrialSetting__c == 'Standard';
                }else
                {
                    isStandardTrial = false;
                }
            }
            return isStandardTrial;
        }set;
    }
    
    // Is French visualization of acreages
    public boolean isFrenchAcreages
    {
        get
        {
            if(isFrenchAcreages== null)
            {
                if(country != null)
                {
                    isFrenchAcreages = country.AcreageSetting__c == 'French';
                }else
                {
                    isFrenchAcreages = false;
                }
            }
            return isFrenchAcreages;
        }set;
    }
    /* French change */
    public boolean isCancelledStatusValueForTacticalPlan
    {
        get
        {
            if (isCancelledStatusValueForTacticalPlan == null)
            {
                isCancelledStatusValueForTacticalPlan = (countryCode == CountryEnum.hungary);
            }
            return isCancelledStatusValueForTacticalPlan;
        }
        set;
    }
    
    //Checks if Acreages shouyld be created automatically by the data from Account.
    public boolean isAutoCreateAcreages()
    {
        return countryCode == CountryEnum.hungary;
    }
    
    //Checks if Acreages should be shown on Account layout (shown only for RSA)
    public boolean isShownAcreageProductList()
    {
        return countryCode == CountryEnum.southAfrica;
    }
    
    //Should the CP division be hide on account.
    public boolean isHideCPDivision()
    {
      return countryCode == CountryEnum.hungary || isGermanActionPlan;
    }
    
    //Countains Enum country code.
    public CountryEnum countryCode
    {
        get
        {
            if (countryCode == null)
            {
                countryCode = country == null ? null : COUNTRY_CODE_MAP.get(country.Name);
            }
            return countryCode;
        }
        set;
    }
    
    //Default version of country adapter.
    public CountryAdapter()
    {
        this(Util.currentAccount);
    }
    
    //Creates Adpater depending on current Account
    public CountryAdapter(Account theAccount)
    {
        this(theAccount.CountryRef__c);
    }
    
    //Builds Adapter by country Id
    public CountryAdapter(Id theCountryId)
    {
        country = allCountryMap.get(theCountryId);
        if (country != null && country.Area__c != null)
        {
            country = country.Area__r;
        }
    }
    
    public CountryAdapter(User theUser)
    {
        CountryEnum aCountry = COUNTRY_ISO_CODE_MAP.get(theUser.CountryISOCode__c);
        if (aCountry != null)
        {
            String aCountryName = null;
            for (String aName: COUNTRY_CODE_MAP.keySet())
            {
                if (COUNTRY_CODE_MAP.get(aName) == aCountry)
                {
                    aCountryName = aName;
                }
            }
            if (aCountryName != null)
            {
                List<Country__c> aResList = (List<Country__c>) Database.query(
                  new al.SoqlBuilder().selectx(new List<String>{'Id', 'Name', 'TacticalPlanSetting__c', 'CP_TacticalPlanSetting__c', 'Area__c', 'Area__r.Name', 'IT_Block_Fields__c', 'Area__r.Id', 'Area__r.TacticalPlanSetting__c', 'AcreageSetting__c', 'Area__r.AcreageSetting__c', 'Area__r.TrialSetting__c', 'TrialSetting__c', 'AccountViewPage__c', 'Area__r.AccountViewPage__c'})
                  .fromx('Country__c')
                  .wherex(new al.FieldCondition('Name', aCountryName))
                  .limitx(1).toSOQL());
                country = aResList.size() > 0 ? aResList.get(0) : null;
            }
        }
    }
    
    //Get value for tactical plan for the country.
    public String getTacticalPlanSetting()
    {
        return country == null ? null : country.TacticalPlanSetting__c;
    }
    
    public String getCPTacticalPlanSetting()
    {
        return country == null ? null : country.CP_TacticalPlanSetting__c;
    }
    
    
    public boolean isAccountNameDuplicateBlockerEnabled()
    {
        return countryCode == CountryEnum.france;
    }
    
    
    public List<SelectOption>getVoucherTemplates()
    {
        List<SelectOption>selectOptions = new List<SelectOption>();
        if(countryCode == CountryEnum.italy)
        {
            selectOptions.add(new SelectOption('VoucherTempItaly', 'Standard Template'));
        }
        if(countryCode == CountryEnum.romania)
        {
            selectOptions.add(new SelectOption('VoucherTempRomania', 'Standard Template'));
        }
        return selectOptions;
    }
    
    //Enum for country code.
    public enum CountryEnum
    {
        austria,
        bulgaria,
        italy,
        germany,
        france,
        hungary,
        romania,
        southAfrica,
        turkey,
        ukrain,
        uk,
        spain,
        switzerland,
        denmark,
        estonia,
        finland,
        latvia,
        lithuania,
        norway,
        portugal,
        sweden,
        czechrepublic,
        russia,
        slovakia,
        poland,
        serbia,
        croatia
        
    }   
}