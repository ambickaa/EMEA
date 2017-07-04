public class TestInit
{
    static final Map<String, String> PRODUCT_GROUPS = new Map<String, String> {'Corn' => 'PRODUCT_GROUP_CORN',
              'OSR' => 'PRODUCT_GROUP_OSR', 'Unknown' => 'PRODUCT_GROUP_OTHER'}; 
    
    //Creates Product grouping system settings, that are mandatory for triggers.
    static
    {
        init();
    }
    
    public static void init()
    {
        Map<String, Product_Grouping__c> aTest = TestInit.productGroupings;
        years = TestInit.years;
        if (Util.DEFAULT_HUNGARY_ACREAGE_PROVIDER == null)
        {
            Account aDistributor = TestInit.createNewDistributor();
            insert aDistributor;
            createSystemSetting('DEFAULT_HUNGARY_ACREAGE_PROVIDER', aDistributor.Id);
            createSystemSetting('DEFAULT_DISTRIBUTOR', aDistributor.Id);
            createSystemSetting('VAT_RSA','0.14');
            createSystemSetting('VAT_value0_RSA','0');
            createSystemSetting('RSA_REST_SVC_JSON_SAVE','All');
    
        }
        Util.systemSettings = null;
    }
    
    public static Map<String, Product_Grouping__c> productGroupings
    {
        get
        {
            if (productGroupings == null)
            {
                productGroupings = new Map<String, Product_Grouping__c>();
                for (String aGroupKey: PRODUCT_GROUPS.keySet())
                {
                    if (Util.getProductGroup(PRODUCT_GROUPS.get(aGroupKey)) == null)
                    {
                        Product_Grouping__c aGroup = new Product_Grouping__c(Name = aGroupKey, 
                              RecordTypeId = Util.recordType.get('Product_Grouping__c:ProductGroup'));
                        productGroupings.put(aGroupKey, aGroup);
                    }
                }
                insert productGroupings.values();
                List<SystemSettings__c> aSettings = new List<SystemSettings__c>();
                for (String aGroupKey: PRODUCT_GROUPS.keySet())
                {
                    if (Util.getProductGroup(PRODUCT_GROUPS.get(aGroupKey)) == null)
                    {
                        aSettings.add(new SystemSettings__c(Name = PRODUCT_GROUPS.get(aGroupKey), Value__c = productGroupings.get(aGroupKey).Id));
                    }
                }
                insert aSettings;
            }
            return productGroupings;
        }
        set;
    }
    
    public static void setCurrentUser( User u )
    {
        util.currentUser = u;
    }
    
    public static List<Account> farmers
    {
        get
        {
            if( farmers == null )
            {
                farmers = new List<Account>();
                farmers.add( createNewFarmer() );
                farmers.add( createNewFarmer() );
                farmers.add( createNewFarmer() );
                farmers.add( createNewFarmer() );
            }

            return farmers;
        } set;
    }
    
    public static Account createNewFarmer()
    {
        Map<String, Object> accValues = new Map<String, Object>
        {
            'Name' => ('New Farm' + al.RandomStringUtils.randomUUID()),
            'RecordTypeId' => Util.recordType.get('Account:GroupFarmSite'),
            'CountryRef__c' => countries.get(0).id,
            'OwnerId' => UserInfo.getUserId()
        };
        return ( Account ) SmartFactory.createSObject( 'Account', accValues );
    }
    
    public static Account createNewCompetitor()
    {
        Map<String, Object> accValues = new Map<String, Object>
        {
            'Name' => ('Competitor' + al.RandomStringUtils.randomUUID()),
            'RecordTypeId' => Util.recordType.get('Account:Competitor'),
            'CountryRef__c' => countries.get(0).id,
            'OwnerId' => UserInfo.getUserId()
        };
        return ( Account ) SmartFactory.createSObject( 'Account', accValues );
    }
    
    public static Account createNewDistributor()
    {
        Map<String, Object> accValues = new Map<String, Object>
        {
            'Name' => ('Monsanto' + al.RandomStringUtils.randomUUID()),
            'RecordTypeId' => Util.recordType.get('Account:DistRetPoS'),
            'CountryRef__c' => countries.get(0).id,
            'OwnerId' => UserInfo.getUserId(),
            'Category__c' => 'Distributor'
        };
        Account anAccount = ( Account ) SmartFactory.createSObject( 'Account', accValues );
        return anAccount;
    }

    public static List<Contact> contacts
    {
        get
        {
            if (contacts == null)
            {
                contacts = new List<Contact>();
                MixedDMLOps.ups( Testinit.farmers );
                Map<String, Object> contValues = new Map<String, Object> {'AccountId' => farmers.get( 0 ).id};
                contacts.add( ( Contact ) SmartFactory.createSObject( 'Contact', contValues ) );
                contacts.add( ( Contact ) SmartFactory.createSObject( 'Contact', contValues ) );
                contacts.add( ( Contact ) SmartFactory.createSObject( 'Contact', contValues ) );
                contacts.add( ( Contact ) SmartFactory.createSObject( 'Contact', contValues ) );
                MixedDMLOps.ins( contacts );
            }

            return contacts;
        }
        set;
    }

    public static List<Country__c> countries
    {
        get
        {
            if( countries == null )
            {
                countries = new List<Country__c>();
                Map<String, Object> countryVal = new Map<String, Object> {'Name' => 'Italy', 'TacticalPlanSetting__c' => 'Italian'};
                Map<String, Object> countryVal2 = new Map<String, Object> {'Name' => 'Germany', 'TacticalPlanSetting__c' => 'Standard'};
                /* French change */
                Map<String, Object> countryVal3 = new Map<String, Object> {'Name' => 'France', 'TacticalPlanSetting__c' => 'French'}; 
                /* French change */
                Map<String, Object> countryVal4 = new Map<String, Object> {'Name' => 'United Kingdom', 'TacticalPlanSetting__c' => 'UK'};
                countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal ) );
                countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal2 ) );
                countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal3 ) );
                countries.add( ( Country__c ) SmartFactory.createSObject( 'Country__c', countryVal4 ) );
                insert countries;
            }

            return countries;
        }
        set;
    }
    
    public static Country__c getCountryByName(String name)
    {
        for(Country__c c : countries)
        {
            if(name == c.name)
            {
                return c;
            }
        }
        return null;
    }

    public static List<Year__c> years
    {
        get
        {
            if( years == null )
            {
                years = new List<Year__c>();
                years.add( new Year__c( name = '2013' ) );
                years.add( new Year__c( name = '2012', Current_Year__c = true ) );
                years.add( new Year__c( name = '2011' ) );
                insert years;
                years.get( 0 ).YearNextYear__c = years.get( 1 ).id;
                years.get( 1 ).YearPreviousYear__c = years.get( 0 ).id;
                years.get( 1 ).YearNextYear__c = years.get( 2 ).id;
                years.get( 2 ).YearPreviousYear__c = years.get( 1 ).id;
                update years;
            }
            return years;
        }
        set;
    }

    public static void setYear( Integer yearID )
    {
        if( yearID == 0 )
        {
            yearID++;
        }
        Util.currentYear = years.get( yearID );
        Util.lastYear = years.get( --yearID );
    }

    public static list<Case> cases
    {
        get
        {
            if ( cases == null )
            {
                cases = new list<Case>();
                Map<String, Object> caseValues = new Map<String, Object> {'AccountId' => farmers[0].id, 'ContactId' => contacts[0].id, 'Status' => 'New'};
                cases.add( ( Case ) SmartFactory.createSObject( 'Case', caseValues ) );
                cases.add( ( Case ) SmartFactory.createSObject( 'Case', caseValues ) );
            }

            return cases;
        } set;
    }

    public static list<CaseComment> casesCom
    {
        get
        {
            if (casesCom == null)
            {
                upsert cases;
                Map<String, Object> commentValues = new Map<String, Object> {'caseId' => cases[0].id};
                casesCom = new list<CaseComment>();
                casesCom.add( ( CaseComment ) SmartFactory.createSObject( 'CaseComment', commentValues ) );
            }

            return casesCom;
        } set;
    }

    public static list<Attachment> attachements
    {
        get
        {
            if (attachements == null)
            {
                upsert cases;
                Map<String, Object> attachValues = new Map<String, Object> {'parentId' => cases[0].id};
                attachements = new list<Attachment>();
                attachements.add( ( Attachment ) SmartFactory.createSObject( 'attachament', attachValues ) );
            }

            return attachements;
        } set;
    }
    
    public static List<Product2> products
    {
        get
        {
            if ( products == null )
            {
                products = new list<Product2>();
                Account aProvider = TestInit.createNewCompetitor();
                insert aProvider;
                Map<String, Object> productValues = new Map<String, Object> {'DivisionRef__c' => getDivision(Util.DIVISION_OSR).Id,
                          'ProductVendor__c' => aProvider.Id};
                for(Integer i=0; i<5; i++)
                {
                    Product2 aProduct = (Product2)SmartFactory.createSObject('Product2', productValues);
                    aProduct.Name = 'Product' + i; 
                    products.add(aProduct);
                }
            }
            
            return products;
        } set;
    }
    
    public static Map<String, Division__c> divisions
    {
        get
        {
            if (divisions == null)
            {
                divisions  = new Map<String, Division__c>();
                
                //Add Division__c with three names(OSR, CORN, CP)
                if ([SELECT Id FROM Division__c].size() == 0)
                {
                    divisions.put(Util.DIVISION_OSR, new Division__c(Name = Util.DIVISION_OSR));
                    divisions.put(Util.DIVISION_CORN, new Division__c(Name = Util.DIVISION_CORN));
                    divisions.put(Util.DIVISION_CP, new Division__c(Name = Util.DIVISION_CP));
                    insert divisions.values();
                }
            }
            return divisions;
        }
        set;
    }
    
    
    public static List<Acreage__c> acreages
    {
        get
        {
            if (acreages == null)
            {
                acreages = new List<Acreage__c>();
                
                acreages.add( ( Acreage__c ) SmartFactory.createSObject( 'Acreage__c' ) );
            }
            return acreages;
        }
        set;
    }
    
    public static Division__c getDivision(String theDivName)
    {
        Division__c aResult = divisions.get(theDivName);
        if (aResult == null)
        {
            aResult = (Division__c) SmartFactory.createSObject('Division__c', new Map<String, Object> {'Name' => theDivName});
            insert aResult;
        }
        return aResult;
    }
    
    public static Campaign campaign
    {
        get
        {
            if (campaign == null)
            {
                Map<String, Object> aCampaignParams = new Map<String, Object>
                {
                    'CountryRef__c' => countries.get(0).Id,
                    'DivisionRef__c' => getDivision(Util.DIVISION_CORN).Id
                };
                campaign = (Campaign)SmartFactory.createSObject('Campaign', aCampaignParams);
            }
            return campaign;
        }
        set;
    }
    
    public static Map<String, ProductCatalog__c> productCatalogs
    {
        get
        {
            if (productCatalogs == null)
            {
                productCatalogs = new Map<String, ProductCatalog__c>();
                Map<String, Object> aProductCatalogParam = new Map<String, Object>
                {
                    'CountryRef__c' => countries.get(1).Id,
                    'YearRef__c' => Util.currentYear.Id,
                    'RecordTypeId' => Util.recordType.get('ProductCatalog__c:SalesProductCatalog'),
                    'DivisionRef__c' => divisions.get(Util.DIVISION_CORN).Id
                };
                
                productCatalogs.put('ProductCatalog__c:SalesProductCatalog', (ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', aProductCatalogParam));
                
                aProductCatalogParam.put('RecordTypeId', Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog'));
                productCatalogs.put('ProductCatalog__c:CompetitorProductCatalog', (ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', aProductCatalogParam));
                
                aProductCatalogParam.put('RecordTypeId', Util.recordType.get('ProductCatalog__c:MarketingProductCatalog'));
                productCatalogs.put('ProductCatalog__c:MarketingProductCatalog', (ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', aProductCatalogParam));
                
                aProductCatalogParam.put('RecordTypeId', Util.recordType.get('ProductCatalog__c:TrialsProductCatalog'));
                productCatalogs.put('ProductCatalog__c:TrialsProductCatalog', (ProductCatalog__c)SmartFactory.createSObject('ProductCatalog__c', aProductCatalogParam));
                
                insert productCatalogs.values();
            }
            return productCatalogs;
        }
        set;
    }
    
    public static PageReference customRedirectModifier(PageReference pg)
    {
        String customUrl = pg.getUrl();
        String newUrl = customUrl.substring(customUrl.indexOf('=')+1, customUrl.length());
        return new PageReference(EncodingUtil.urlDecode(newUrl, 'utf-8'));
    }
    
    public static AccountWrapper accountWrapper {get; set;}
    
    public static void createAccountListController()
    {
        setYear(1);
        Division__c aDivision = getDivision(Util.DIVISION_CORN);
        Country__c aCountry = countries[1];
        Account anAccount = createNewFarmer();
        anAccount.Name = 'Test Account' + al.RandomStringUtils.randomUUID();
        anAccount.CountryRef__c = aCountry.Id;
        insert anAccount;
        Map<String, Object> aPreviousCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today(),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.lastYear.Id
        };
        Campaign aPreviousCampaign = (Campaign)SmartFactory.createSObject('Campaign', aPreviousCampaignParam);
        insert aPreviousCampaign;
        Map<String, Object> aCurrentCampaignParam = new Map<String, Object>
        {
            'CountryRef__c' => anAccount.CountryRef__c,
            'OwnerId' => anAccount.OwnerId,
            'DivisionRef__c' => aDivision.Id,
            'StartDate' => Date.today(),
            'EndDate' => Date.today().addDays(1),
            'ArchiveDate__c' => Date.today().addDays(30),
            'YearV2__c' => Util.currentYear.Id
        };
        Campaign aCurrentCampaign = (Campaign)SmartFactory.createSObject('Campaign', aCurrentCampaignParam);
        insert aCurrentCampaign;
        
        accountWrapper = new AccountWrapper(anAccount, aCurrentCampaign, aPreviousCampaign);
    }
    
    public class AccountWrapper
    {
        public Account accountRecord {get; set;}
        public Campaign campaignRecord {get; set;}
        public Campaign previosCampaignRecord {get; set;}
        
        public AccountWrapper(Account theAccount, Campaign theCampaign, Campaign thePreviousCampaign)
        {
            accountRecord = theAccount;
            campaignRecord = theCampaign;
            previosCampaignRecord = thePreviousCampaign; 
        }
    }
    
    public static void createSystemSetting(String theName, String theValue)
    {
        insert new SystemSettings__c(Name = theName, Value__c = theValue);
    }
}