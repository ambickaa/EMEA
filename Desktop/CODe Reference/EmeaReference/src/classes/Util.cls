public class Util 
{
    //--------------------------------------------------
    // DIVISIONS
    //--------------------------------------------------
    public static final String DIVISION_CORN = 'Corn';
    public static final String DIVISION_OSR = 'OSR';
    public static final String DIVISION_CP = 'CP';
    public static final String DIVISION_LATITUDE = 'Latitude';
    public static final String DIVISION_MONITOR = 'Monitor';
    public static final String DIVISION_ROUNDUP = 'Roundup';
    public static final String DIVISION_MONFAST = 'Monfast';
    public static final String DIVISION_GUARDIAN = 'Guardian Tetra';
    public static final String DIVISION_HARNESS = 'Harness';
    public static final String DIVISION_ACTIMUM = 'Actimum';

    //--------------------------------------------------
    // PRODUCT GROUPS
    //--------------------------------------------------
    public static Map<String, Id> productGroupsMap = new Map<String, Id>();
    public static Id getProductGroup(String theProductGroup)
    {
        Id aResult = productGroupsMap.get(theProductgroup);
        if (aResult == null)
        {
            aResult = getSetting(theProductGroup);
            if (aResult != null)
            {
                productGroupsMap.put(theProductGroup, aResult);
            }
        }
        return aResult;
    }
    public static final String PRODUCT_GROUP_CORN = 'PRODUCT_GROUP_CORN';
    public static final String PRODUCT_GROUP_OSR = 'PRODUCT_GROUP_OSR';
    public static final String PRODUCT_GROUP_OTHER = 'PRODUCT_GROUP_OTHER';
    public static final String PRODUCT_GROUP_WINTER_WHEAT = 'PRODUCT_GROUP_WINTER_WHEAT';
    public static final String PRODUCT_GROUP_TRITICALE = 'PRODUCT_GROUP_TRITICALE';
    public static final String PRODUCT_GROUP_CEREALS= 'PRODUCT_GROUP_CEREALS';
    public static final String PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS = 'PRODUCT_GROUP_OTHER_HERBACEOUS_CROPS';
    public static final String PRODUCT_GROUP_UNKNOW = 'PRODUCT_GROUP_UNKNOW';
    
    //Default distributor, that will be used for hungary acreages.
    public static final Id DEFAULT_HUNGARY_ACREAGE_PROVIDER = (Id) getSetting('DEFAULT_HUNGARY_ACREAGE_PROVIDER');
    
    //Default distributor, that will be used for any acreages.
    public static final Id DEFAULT_DISTRIBUTOR_ACREAGE_PROVIDER = (Id) getSetting('DEFAULT_DISTRIBUTOR');
    
    private static Integer info = 0;
    private static Integer error = 0;
    private static Integer confirm = 0;
    private static Integer warning = 0;
    private static Integer debug = 0;
    public   boolean inTrigger = false;

    public static Map<String, SystemSettings__c> systemSettings
    {
        get
        {
            if (systemSettings == null)
            {
                systemSettings = SystemSettings__c.getAll();
            }
            return systemSettings;
        }
        set;
    }
    
    public static Account currentAccount
    {
        get
        {
            if(currentAccount == null)
            {
                setCurrentAccount(urlParameters.get('id'));
            }
            return currentAccount;
        } set;
    }

    public static void setCurrentAccount(String id)
    {
        Account[] ac = [SELECT ID, OwnerId, Owner.Alias, Owner.UserRoleId, DE_ID_STATUS__c, DE_Owners__c, CountryRef__c, PrimaryDistributor__c, PrimaryPoS__c, ImportId__c, Owner.Name, Name, GC_VATIN_Number__c, Street__c,  ZIPPostalCode__c, City__c, GC_Mobile_Phone__c, RecordTypeId, RecordType.name, RecordType.DeveloperName, IsCreateCampaignLineItem__c, Phone, Category__c, TXT_Partners_Ids__c, LKP_Responsible_ST__c, LKP_Responsible_CP__c FROM Account WHERE ID = :id];
        currentAccount = ac.size() > 0 ? ac[0] : new Account();
    }
    
    public static Account currentAccountCountry
    {
        get
        {
            if(currentAccountCountry == null) {
                setCurrentAccountCountry(urlParameters.get('id'));
            }
            return currentAccountCountry;
        } set;
    }

    public static void setCurrentAccountCountry(String id)
    {
        Account[] ac = [SELECT ID, OwnerId, Owner.Alias, DE_Owners__c, CountryRef__c, CountryRef__r.Name, DE_Territory_Key__c, PrimaryDistributor__c, PrimaryPoS__c, ImportId__c, Owner.Name, name, GC_VATIN_Number__c, Street__c,  ZIPPostalCode__c, City__c, GC_Mobile_Phone__c, RecordTypeId, RecordType.name, IsCreateCampaignLineItem__c, Phone FROM Account WHERE ID = :id];
    	currentAccountCountry = ac.size() > 0 ? ac[0] : new Account();
    }
    
    public static boolean isCpStandard
    {
        get
        {
            return currentAccountCountry.CountryRef__r.Name !=null && currentAccountCountry.CountryRef__r.Name!='' && currentAccountCountry.CountryRef__r.Name!='Germany';
        }
    }
    
    public static String currentLookupMode
    {
        get
        {
            if(currentLookupMode == null)
            {
                currentLookupMode = Util.urlParameters.get('mode');
                
                if(currentLookupMode == 'tacticalEdit')
                {
                    currentLookupMode = 'Sales';
                }
                else if(currentLookupMode == 'trailEdit')
                {
                    currentLookupMode = 'Trial';
                }
                else if(currentLookupMode == 'merchandiseManagementEdit')
                {
                    currentLookupMode = 'GiveAway';
                }
            }
            
            return currentLookupMode;
        }
        set;
    }
    
    /**
    * Adapter for current country view.
    * Please check this one instead of checking county directly.
    * Check CountryAdapter comments to more information.
    */
    public static CountryAdapter countryView
    {
        get
        {
            if (countryView == null)
            {
                countryView = new CountryAdapter();
                system.debug('***countryView = new CountryAdapter()');
            }
            return countryView;
        }
        set;
    }

    // isOwnerFlag for Account
    public static boolean isAccountOwner
    {
        get
        {
			if(isAccountOwner == null)
			{
				if(currentAccount <> null && currentAccount.OwnerId == UserInfo.getUserId())
				{
					isAccountOwner = true;
				}
				else if(currentAccount.OwnerId <> UserInfo.getUserId())
				{
					if(countryView.isAccountSharingEnabled && currentAccount.DE_Owners__c != null && currentAccount.DE_Owners__c.contains(currentUser.alias))
					{
						isAccountOwner = true;
					}
					else
					{
						//Method modification for Distributor Action Plan in Italy & UK
						if(isAccountManager && !(currentAccount.RecordType.Name == 'Group/Farm/Site' && (currentCountry.Name == 'Italy' || currentCountry.Name == 'United Kingdom')))
						{
							isAccountOwner = true;
						}
						else if(currentAccount.TXT_Partners_Ids__c != null && currentUser.SAP_Partner_Code__c != null)
						{
							isAccountOwner = currentAccount.TXT_Partners_Ids__c.contains(currentUser.SAP_Partner_Code__c) ? true : false;
						}
						else if(currentAccount.LKP_Responsible_ST__c == currentUser.Id || currentAccount.LKP_Responsible_CP__c == currentUser.Id)
						{
							isAccountOwner = true;
						}
						else if(isIncludedInSharing)
						{
							isAccountOwner = true;
						}
						else{
							isAccountOwner = false;
						}
					}
				}
			}
			return isAccountOwner;
        }
        set;
    }

    // recordType is a map with all recordtypes and can be accessed by objectName:Recordtype
    public static Map<String, ID> recordType
    {
        get
        {
            if( recordType== null )
            {
                recordType = new Map<String, Id>();

                for( RecordType r : [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r] )
                {
                    recordType.put( r.SobjectType+':'+r.DeveloperName, r.id );
                }
            }
            return recordType;
        }
        set;
    }
    
    public static Map<Id, String> recordTypeId
    {
        get
        {
            if(recordTypeId == null)
            {
                recordTypeId = new Map<Id, String>();
                
                for(String name : recordType.keySet())
                {
                    recordTypeId.put(recordType.get(name), name);
                }
            }
            return recordTypeId;
        }
        set;
    }

    public static User currentUser
    {
        get
        {
            if (currentUser == null)
            {
                User[] u = [SELECT Name,ID, Alias, Division, SAP_Partner_Code__c, Is_Promoter__c, Is_Regional_Manager__c, StandardDivision__c, CountryISOCode__c, Country, UserRoleId, UserRole.Name, LanguageLocaleKey, EMail, Manager.EMail, Manager.Name, Manager.Manager.EMail, Manager.Manager.Name, ManagerId, Manager.ManagerId, Profile.Name FROM User WHERE ID = :UserInfo.getUserId()];
                currentUser = u.size() > 0 ? u[0] : new User();
            }
            return currentUser;
        } set;
    }

    public static Country__c currentCountry
    {
        get
        {
            if (currentCountry == null)
            {
                Country__c[] c = [SELECT ID, CHK_should_Update_Layouts__c, TXT_Planting_Density_Corn__c, TXT_Planting_Density_OSR__c, LKP_CurrentYear__c, Name FROM Country__c WHERE Name= :Util.currentUser.Country];
                currentCountry = c.size() > 0 ? c[0] : new Country__c();
            }
            return currentCountry ;
        } set;
    }
    
    // Start: CR-00000213. 11/03/2015
    public static Country__c currentAP
    {
        get
        {
            if (currentAP == null)
            {
                for (Country__c ap : [SELECT ID, TacticalPlanSetting__c, CHK_UPPER_ROLE_PERMISSION__c, PICK_FieldSets__c FROM Country__c WHERE Name= :Util.currentUser.Country])
                {
                    currentAP = ap;
                }
            }
            return currentAP ;
        } set;
    }
    // End: CR-00000213.
    
    // Start: CR-00000254. 7/05/2015 - MODIFIED ON 06/06/2016
    public static Set<Id> getSubordinateRoles(Id roleId)
    {
        map<Id, Set<Id>> parentAndChildren = new map<Id, Set<Id>>();
        Set<Id> children;
        for(UserRole ur : [SELECT Id, ParentRoleId FROM UserRole])
        {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new Set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }
    
    public static Set<Id> getSubordinateRoles(Id roleId, map<Id, Set<Id>> parentAndChildren)
    {
        Set<Id> subordinateRoles = new Set<Id>();
        Set<Id> remainingSubordinateRoles = new Set<Id>();
        if(parentAndChildren.containsKey(roleId))
        {
            subordinateRoles.addAll(parentAndChildren.get(roleId));
            for(Id subRoleId : subordinateRoles)
            {
                remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
            }
        }
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    }
    
    public static boolean isAccountManager
    {
        get
        {
            if(isAccountManager == null)
            {
                if(currentAP != null)
                {
                    if(currentAP.CHK_UPPER_ROLE_PERMISSION__c == true)
                    {
                        Set<Id> allSubRoleIds = getSubordinateRoles(currentUser.UserRoleId);
                        if(allSubRoleIds.contains(currentAccount.Owner.UserRoleId))
                        {
                            isAccountManager = true;
                        }
                        else
                        {
                            isAccountManager = false;
                        }
                    }
                    else
                    {
                        isAccountManager = false;
                    }
                }
                else isAccountManager = false;
            }
            return isAccountManager;
        }
        set;
    }
    // End: CR-00000254. 7/05/2015 - MODIFIED ON 06/06/2016
    
    public static boolean isIncludedInSharing
    {
    	get
    	{
    		if(isIncludedInSharing == null)
    		{
    			isIncludedInSharing = false;
    			for(AccountShare ac : [SELECT Id, UserOrGroupId FROM AccountShare WHERE AccountId = :currentAccount.Id AND AccountAccessLevel = 'Edit'])
    			{
    				if(currentUser.Id == ac.UserOrGroupId)
    					isIncludedInSharing = true;
    			}
    		}
    		return isIncludedInSharing;
    	}
    	set;
    }

//PDP
 public static List<PDPCountryGroup__c> CountryGroups
    {
        get
        {
            if (CountryGroups == null)
            {
                CountryGroups = new List<PDPCountryGroup__c>();
                for (PDPCountryGroup__c cg : [SELECT ID, Name, Repeat_L1__c, Repeat_L2__c, Repeat_L3__c, Country_LVL_2__c, Grouping__c,SAP_Country_Code__c FROM PDPCountryGroup__c ])
                {
                    CountryGroups.add(cg);
                }
            }
            return CountryGroups;
        } set;
    }

    // last year please check current year
    public static Year__c lastYear
    {
        get
        {
            if( lastYear == null && currentYear <> null )
            {
                LastYear = currentYear.YearPreviousYear__r;
            }
            return lastYear;
        }
        set;
    }
    
    // current year selected by checkbox current year on the year__c record
    public static Year__c currentYear
    {
        get
        {
            if( currentYear == null )
            {
                Year__c[] y = [SELECT Id, YearPreviousYear__c, YearPreviousYear__r.Id, Name, YearStartDate__c, YearEndDate__c FROM Year__c WHERE Current_Year__c = true LIMIT 1];
                Country__c c = Util.currentCountry;
                if(c != null)
                {
                    if(c.LKP_CurrentYear__c != null && c.LKP_CurrentYear__c != y[0].Id)
                    {
                        y = [SELECT ID, YearPreviousYear__c, YearPreviousYear__r.id,Name, YearStartDate__c, YearEndDate__c FROM Year__c WHERE Id =: c.LKP_CurrentYear__c];
                    }
                }
                currentYear = y.size() > 0 ? y[0] : new Year__c();
                return currentYear;                
            }
            return currentYear;
        } set;
    }


    // urlparamter wrapper provides better information for
    public static Map<String, String> urlParameters
    {
        get
        {   
            if (urlParameters == null || urlParameters.isEmpty()) // Fix for components with reRender
            {   
                system.debug(ApexPages.currentpage());
                if(ApexPages.currentPage() != null)
                    urlParameters = ApexPages.currentPage().getParameters();
                else
                    urlParameters = new Map<String, String>();
            }
            return urlParameters;
        } set;
    }

    public static Map<String, Division__c> divisions
    {
        get
        {
            if(divisions == null)
            {
                divisions = new Map<String, Division__c>();
                for(Division__c d : [SELECT Name, id, Standard__c, Color__c FROM Division__c])
                {
                    divisions.put(d.name, d);
                }
            }
            return divisions;
        }
        set;
    }

    public static Id divisionId
    {
        get
        {
            if(divisionId == null)
            {
                if(currentDivision != null)
                {
                    divisionId = currentDivision.Id;
                }
            }
            return divisionId;
        }
        set;
    }

    public static Division__c currentDivision
    {
        get
        {
            if(currentDivision == null)
            {
                if (!urlParameters.containsKey('division'))
                {
                    if(DIVISION_CP.equalsIgnoreCase(currentUser.StandardDivision__c) && countryView.getTacticalPlanSetting() == CountryAdapter.ACTION_PLAN_GERMAN){
                          currentDivision = divisions.get(DIVISION_ROUNDUP);
                    } 
                    else {
                        //If standard division has active campaign then currentdivision = standard division
                        Boolean IsDivision = false;
                        List<Division__c> List_Division = new List<Division__c>();
                        for(Campaign c : [SELECT Id, DivisionRef__c, DivisionRef__r.Name
                          FROM Campaign WHERE OwnerId = :currentUser.id AND StatusCode__c = 200 AND RecordType.name = 'Sales Campaign']) {
                            IsDivision = c.DivisionRef__c == divisions.get(currentUser.StandardDivision__c).Id ? true : IsDivision;
                            
                            if(divisions.containsKey(c.DivisionRef__r.Name))
                                List_Division.add(divisions.get(c.DivisionRef__r.Name));
                         }
                         if(List_Division.size() > 0)
                            currentDivision = IsDivision ? divisions.get(currentUser.StandardDivision__c) : List_Division[0];
                        else
                            currentDivision = divisions.get(currentUser.StandardDivision__c);

                    }
                } else
                {
                    for(Division__c d : divisions.values())
                    {
                        if(d.id == (urlParameters.get('division')))
                        {
                            currentDivision = d;
                        }
                    }
                    
                }
            }
            if(currentDivision == null)
            {
                for(Division__c d : divisions.values())
                {
                    if(d.Standard__c)
                    {
                        currentDivision = d;
                    }
                }
            }
            return currentDivision;
        }
        set;
    }
    
    /**
        Gets the map of Product_grouping objects.
    */
    public static Map<String, Product_Grouping__c> productGroups
    {
        get
        {
            if (productGroups == null)
            {
                productGroups = new Map<String, Product_Grouping__c>();
                List<Product_Grouping__c> aList = [Select Id, Name FROM Product_Grouping__c];
                for (Product_Grouping__c aGroup: aList)
                {
                    productGroups.put(aGroup.Name, aGroup);
                }
            }
            return productGroups;
        }
        set;
    }
    
    public static boolean isCampaign;
    public static Campaign currentCampaign
    {
        get
        {
            if(currentCampaign == null && isCampaign == null)
            {
                isCampaign = false;
                if(countryView.isAccountSharingEnabled){
                    for(Campaign c : [SELECT ID, YearV2__c, Name, TrialPCMRef__c, GiveAwayPCMRef__c, CompetitorPCMRef__c , TaxSalesPCMRef_RSA__c, 
                                  SalesPCMRef__c, DisableForecastStatus__c, DisableAgreedStatus__c, TotalAllocatedCharged__c, TotalAllocatedFOC__c,
                                  TotalCampaignBudget__c, TotalAllocatedBudget__c, TotalPendingBudget__c, DivisionRef__r.name,
                                  TotalPendingAgreedBudget__c, TotalCampaignBudgetFOC__c, TotalPendingAgreedFOC__c,FRML_Total_Forecasted__c,FRML_Total_Agreed__c,FRML_Total_POG__c,
                                  PrcAgreedAdvancementSales__c, PrcAgreedAdvancementFOC__c, TotalPendingForecastFOC__c,
                                  TotalPendingPoGFOC__c, PrcForecastAdvancementSales__c, PrcPoGAdvancementSales__c,
                                  TotalPendingForecastBudget__c,TotalPendingPoGBudget__c, PrcForecastAdvancementFOC__c,
                                  PrcPoGAdvancementFOC__c, ApprovalStatus_RSA__c, TotalSalesCharged__c, TotalForecastCharged__c,
                                  TotalAgreedCharged__c, TotalForecastFOC__c, TotalAgreedFOC__c, TotalSalesFOC__c, DE_Season__c,
                                  DE_PrcAgreedAdvancementSales__c, DE_PrcForecastAdvancementSales__c, DE_PoGAdvancementSales__c, 
                                  DE_TotalPendingAgreedBudget__c, DE_TotalPendingForecastBudget__c, DE_TotalPendingPoGBudget__c, YearV2__r.Name, CountryRef__r.Name, NUM_TotalCampaignBudgetDist__c, NUM_TotalForecastDist__c, NUM_TotalAgreedDist__c, NUM_TotalSalesDist__c,
                                  FRML_TotalPendingForecastDist__c, FRML_TotalPendingAgreedDist__c, FRML_TotalPendingSalesDist__c 
                          FROM Campaign WHERE CountryRef__c = :countryView.country.Id
                                AND OwnerId = :currentUser.Id AND StatusCode__c = 200 AND DivisionRef__c = :divisionId AND RecordType.name = 'Sales Campaign'])
                    {
                        System.debug('*** Current campaign: ' + c);
                        currentCampaign = c;
                        isCampaign = true;
                    }
                }else{
                    for(Campaign c : [SELECT ID, YearV2__c, Name, TrialPCMRef__c, GiveAwayPCMRef__c, CompetitorPCMRef__c , TaxSalesPCMRef_RSA__c, 
                                  SalesPCMRef__c, DisableForecastStatus__c, DisableAgreedStatus__c, TotalAllocatedCharged__c, TotalAllocatedFOC__c,
                                  TotalCampaignBudget__c, TotalAllocatedBudget__c, TotalPendingBudget__c, DivisionRef__r.name,
                                  TotalPendingAgreedBudget__c, TotalCampaignBudgetFOC__c, TotalPendingAgreedFOC__c,FRML_Total_Forecasted__c,FRML_Total_Agreed__c,FRML_Total_POG__c,
                                  PrcAgreedAdvancementSales__c, PrcAgreedAdvancementFOC__c, TotalPendingForecastFOC__c,
                                  TotalPendingPoGFOC__c, PrcForecastAdvancementSales__c, PrcPoGAdvancementSales__c,
                                  TotalPendingForecastBudget__c,TotalPendingPoGBudget__c, PrcForecastAdvancementFOC__c,
                                  PrcPoGAdvancementFOC__c, ApprovalStatus_RSA__c, TotalSalesCharged__c, TotalForecastCharged__c,
                                  TotalAgreedCharged__c, TotalForecastFOC__c, TotalAgreedFOC__c, TotalSalesFOC__c, DE_Season__c, YearV2__r.Name, CountryRef__r.Name, NUM_TotalCampaignBudgetDist__c, NUM_TotalForecastDist__c, NUM_TotalAgreedDist__c, NUM_TotalSalesDist__c,
                                  FRML_TotalPendingForecastDist__c, FRML_TotalPendingAgreedDist__c, FRML_TotalPendingSalesDist__c
                          FROM Campaign WHERE CountryRef__c = :countryView.country.Id
                                AND OwnerId = :currentAccount.OwnerId AND StatusCode__c = 200 AND DivisionRef__c = :divisionId AND RecordType.name = 'Sales Campaign'])
                    {
                        System.debug('*** Current campaign: ' + c);
                        currentCampaign = c;
                        isCampaign = true;
                    }
                }

            }
            return currentCampaign;
        }
        set;
    }
    
    //User current Campaign (remove in future)
    public static boolean isCampaign2;
	public static Campaign currentCampaignUser
    {
        get
        {
            if(currentCampaignUser == null && isCampaign2 == null)
            {
            //CountryRef__c = :countryView.country.Id AND
                         for(Campaign c : [SELECT ID, Name,YearV2__c, TrialPCMRef__c, GiveAwayPCMRef__c, CompetitorPCMRef__c , TaxSalesPCMRef_RSA__c, 
                                  SalesPCMRef__c, DisableForecastStatus__c, TotalAllocatedCharged__c, TotalAllocatedFOC__c,
                                  TotalCampaignBudget__c, TotalAllocatedBudget__c, TotalPendingBudget__c, DivisionRef__r.name,
                                  TotalPendingAgreedBudget__c, TotalCampaignBudgetFOC__c, TotalPendingAgreedFOC__c,FRML_Total_Forecasted__c,FRML_Total_Agreed__c,FRML_Total_POG__c,
                                  PrcAgreedAdvancementSales__c, PrcAgreedAdvancementFOC__c, TotalPendingForecastFOC__c,
                                  TotalPendingPoGFOC__c, PrcForecastAdvancementSales__c, PrcPoGAdvancementSales__c,
                                  TotalPendingForecastBudget__c,TotalPendingPoGBudget__c, PrcForecastAdvancementFOC__c,
                                  PrcPoGAdvancementFOC__c, ApprovalStatus_RSA__c, TotalSalesCharged__c, TotalForecastCharged__c,
                                  TotalAgreedCharged__c, TotalForecastFOC__c, TotalAgreedFOC__c, TotalSalesFOC__c, DE_Season__c,
                                  DE_PrcAgreedAdvancementSales__c, DE_PrcForecastAdvancementSales__c, DE_PoGAdvancementSales__c, 
                                  DE_TotalPendingAgreedBudget__c, DE_TotalPendingForecastBudget__c, DE_TotalPendingPoGBudget__c
                          FROM Campaign WHERE  OwnerId = :currentUser.Id AND StatusCode__c = 200 AND DivisionRef__c = :divisionId])
                    {
                        currentCampaignUser = c;
                        isCampaign2 = true;
                    }
                }
            return currentCampaignUser;
            }
        set;
    }
    
    private static boolean isprevCampaign;
    public static Campaign previewsCampaign
    {
        get
        {
            if(previewsCampaign == null && isprevCampaign == null)
            {
                isprevCampaign = false;
                if(countryView.isAccountSharingEnabled){
                    if( currentCampaign != null ){
                        for(Campaign c : [SELECT ID, Name, TrialPCMRef__c, SalesPCMRef__c, CompetitorPCMRef__c , GiveAwayPCMRef__c, DE_Season__c FROM Campaign WHERE CountryRef__c = :countryView.country.Id AND OwnerId = :currentUser.ID AND StatusCode__c = 300 AND DivisionRef__c = :divisionId AND DE_Season__c = :currentCampaign.DE_Season__c])
                        {
                            System.debug('*** Previous campaign: ' + c);
                            previewsCampaign = c;
                            isprevCampaign = true;
                        }
                    }
                } else
                {
                    for(Campaign c : [SELECT ID, Name, TrialPCMRef__c, SalesPCMRef__c, CompetitorPCMRef__c , GiveAwayPCMRef__c, DE_Season__c FROM Campaign WHERE CountryRef__c = :countryView.country.Id AND OwnerId = :currentAccount.OwnerId AND StatusCode__c = 300 AND DivisionRef__c = :divisionId])
                    {
                        System.debug('*** Previous campaign: ' + c);
                        previewsCampaign = c;
                        isprevCampaign = true;
                    }
                }
            }
            return previewsCampaign;
        }
        set;
    }

    public static boolean hasPermissionsForCampaignLineItemEdit
    {                     
        get
        {
            return (currentCampaign != null && currentCampaign.id != null && isAccountOwner);
        }
        set;
    }

    public static String getSetting(String theName)
    {
        SystemSettings__c aSetting = systemSettings.get(theName);
        return aSetting == null ? null : aSetting.Value__c;
    }
    
    public static void addInfoMessage( Object message )
    {
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO,++info + ': ' + message ) );
    }
    public static void addErrorMessage( Object message )
    {
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR,++error + ' : ' + message ) );
    }
    public static void addConfirmMessage( Object message )
    {
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM,++confirm + ' : ' + message ) );
    }
    public static void addWarningMessage( Object message )
    {
        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING,++warning + ' : ' + message ) );
    }
    
    public static void addDebugMessage( Object message )
    {
        System.debug(LoggingLevel.Error, message);
    }
    
    public static String joinStrings(List<String> theStrings, String theSeparator)
    {
        String aResult = '';
        for (String aString: theStrings)
        {
            if (aString != null && aString.length() > 0)
            {
                aResult += theSeparator + aString;
            }
        }
        if (aResult != '')
        {
            aResult = aResult.subString(theSeparator.length());
        }
        return aResult;
    }
    
    //get Ids from list of objects.
    public static Set<Id> getIdSet(List<sObject> theSObjectList)
    {
        Set<Id> anIdSet = new Set<Id>();
        for (sObject anObject : theSObjectList)
        {
            anIdSet.add(String.valueOf(anObject.get('id')));
        }
        return anIdSet;
    }

	public static Campaign currentCornCampaign;
 
	public static Campaign getcurrentCornCampaign (Id userId)
	{
		if(currentCornCampaign == null )
		{
	        for(Campaign c : [SELECT ID, YearV2__c, Name, TrialPCMRef__c, GiveAwayPCMRef__c, CompetitorPCMRef__c , TaxSalesPCMRef_RSA__c, 
	                      SalesPCMRef__c, DisableForecastStatus__c, TotalAllocatedCharged__c, TotalAllocatedFOC__c,
	                      TotalCampaignBudget__c, TotalAllocatedBudget__c, TotalPendingBudget__c, DivisionRef__r.name,
	                      TotalPendingAgreedBudget__c, TotalCampaignBudgetFOC__c, TotalPendingAgreedFOC__c,FRML_Total_Forecasted__c,FRML_Total_Agreed__c,FRML_Total_POG__c,
	                      PrcAgreedAdvancementSales__c, PrcAgreedAdvancementFOC__c, TotalPendingForecastFOC__c,
	                      TotalPendingPoGFOC__c, PrcForecastAdvancementSales__c, PrcPoGAdvancementSales__c,
	                      TotalPendingForecastBudget__c,TotalPendingPoGBudget__c, PrcForecastAdvancementFOC__c,
	                      PrcPoGAdvancementFOC__c, ApprovalStatus_RSA__c, TotalSalesCharged__c, TotalForecastCharged__c,
	                      TotalAgreedCharged__c, TotalForecastFOC__c, TotalAgreedFOC__c, TotalSalesFOC__c, DE_Season__c
	              FROM Campaign WHERE  OwnerId = :userId AND StatusCode__c = 200 AND DivisionRef__r.Name = 'Corn'])
	        {
	            currentCornCampaign = c;
	        }
		}
		return currentCampaign;
	}

    public static Map<String, String>attachDocs
    {
        get
        {   
            if (attachDocs == null || attachDocs.isEmpty()) //Fix for components with reRender
            {
                attachDocs = new Map<String, String>();             
                for(EnhancedDocument__c doc : [SELECT Content__c,Language__c,Name,Type__c, TXT_Short_Description__c FROM EnhancedDocument__c WHERE CountryRef__r.Name='South Africa'])
                {
                    String textMay = doc.TXT_Short_Description__c.toUpperCase();
                    attachDocs.put(textMay ,doc.Content__c);
                }  
            }       
            return attachDocs;
        } set;
    }
    
    public static Boolean isRegionalManagerRSA
	{
        get
        {
            if( isRegionalManagerRSA == null )
            {
              isRegionalManagerRSA = false;
              
        if(Util.currentUser.Profile.Name.equalsIgnoreCase('RSA_Regional Manager'))
                isRegionalManagerRSA = true; 
                
            }

            return isRegionalManagerRSA ;
        }
        set; 
	}  

    public static void resetLead(Lead l){
        l.FirstName = '---';
        l.LastName = '---';
        l.DAT_Birthday__c = null;
        l.Country = '---';
        l.State = '---';
        l.City = '---';
        l.PostalCode = '---';
        l.Street = '---';
        l.Email = '';
        l.Phone = '---';
        l.Fax = '---';
        l.NUM_Farm_size_per_crop__c = null;
        l.Website = '---';
        l.Company = '---';
        l.TXT_Position_in_the_company__c = '---';
        l.TXT_VAT_ID__c = '---';
        l.PICK_User_category__c = '---';
        l.PICK_Farm_usage__c = null;
        l.PICK_Gender__c = null;
        l.TXT_Suppliers_of_the_farm__c = null;
        
        l.CHK_Consent_Contact_by_email__c = false;
        l.CHK_Consent_Contact_by_fax__c = false;
        l.CHK_Consent_Contact_by_phone__c =  false;
        l.CHK_Consent_Contact_by_postal__c = false;
        l.CHK_Consent_Contact_by_SMS__c = false;
        l.CHK_Consent_Marketing_material__c = false;
        l.CHK_Consent_Newsletters__c = false;
        l.TXT_Security_Token__c = '---';

    }

    @isTest
    public static void testUtil()
    {
        Util.addInfoMessage( '' );
        Util.addErrorMessage( '' );
        Util.addConfirmMessage( '' );
        Util.addWarningMessage( '' );
    }
}