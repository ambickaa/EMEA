@isTest
public with sharing class Test_Everis_ACS_Deploy_2 
{
	public static testmethod void test_CaseX()
    {
          Country__c country = new Country__c(Name='Bulgaria');
          insert country;
            
          Account account1 = new Account(CountryRef__c=country.Id, Name='Test Account1',City__c='Test City1',StateProvince__c='Test State/Province1',ZIPPostalCode__c='60612');
		insert account1;
     
        Casex cx = new Casex();
        system.debug(cx.commentList);
        system.debug(cx.attachmentList);
        cx.getSelectedRecords();
        cx.getFilledRecords();
        Casex cx2 = new Casex(String.valueOf(account1.Id));
        Casex cx3 = new Casex(new Case());
    }
    
    public static testmethod void test_CaseXFactory()
    {
          Country__c country = new Country__c(Name='Bulgaria');
          insert country;
            
          Account account1 = new Account(CountryRef__c=country.Id, Name='Test Account1',City__c='Test City1',StateProvince__c='Test State/Province1',ZIPPostalCode__c='60612');
		insert account1;
     
        CasexFactory cx = new CasexFactory();
        
        cx.createObjectWrapperForAccountId(account1.id);
        Case cx3 = new Case();
        insert cx3;
        cx.createObjectWrapperForCaseId(cx3.Id);
    }
    
    public static testmethod void test_AccountFarmUpdateBatchable()
    {
    	 Year__c year_py = new Year__c(Name='2014',Current_Year__c=false,YearEndDate__c=date.newinstance(2014,12,31),YearStartDate__c=date.newinstance(2013,1,1));
          insert year_py;
          
          Year__c year = new Year__c(Name='2015',Current_Year__c=true,YearPreviousYear__c=year_py.Id,YearEndDate__c=date.newinstance(2999,12,31),YearStartDate__c=date.newinstance(2015,1,1));
          insert year;
            
          Division__c division1 = new Division__c(Name='OSR');
          insert division1;
          
		Country__c country = new Country__c(Name='South Africa', LKP_CurrentYear__c=year.Id);
       	insert country;       	
       	Account account1 = new Account(recordtypeid=Util.recordType.get('Account:GroupFarmSite'), BlankVATNumber_RSA__c=true,CountryRef__c=country.Id,Name='Test Account1',City__c='Test City1',StateProvince__c='Test State/Province1',ZIPPostalCode__c='60612');
       	insert account1;       	
		Test.startTest();
		AccountFarmUpdateBatchable c = new AccountFarmUpdateBatchable();
		Database.executeBatch(c);
		
		c.SharingUpdate=true;
		c.countryId=country.Id;
		Database.executeBatch(c);
		
		c.toMigrateRSA=true;
		Database.executeBatch(c);
		
		c.toYear=true;
		Database.executeBatch(c);
		
		Test.stopTest();       
    } 
    
    public static testmethod void testutil()
    {
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        Map<String, SystemSettings__c> mapa = Util.SystemSettings;
        
        Account acc2 = [Select id from account limit 1];
        Util.setCurrentAccount(acc2.Id);
        
        Account acc = Util.currentAccount;
        Country__c c = [Select id from country__c limit 1];
        util.setCurrentAccountCountry(acc2.Id);
        Account acc3 = Util.currentAccountCountry;
        boolean b = Util.isCpStandard;
        String str = Util.currentLookupMode;
        CountryAdapter ca = Util.countryView;
        boolean b2 = Util.isAccountOwner;
        Util.resetLead(new Lead());
        Util.getProductGroup('CAMPAIGN_SALES_RM_TEMPLEATE');
        Country__c cI = new Country__c(Name=Util.currentUser.Country);
        insert cI;
        Country__c c2 = Util.currentCountry;
        Util.currentCountry=cI;
        Year__c year = Util.currentYear;
        c2 = Util.currentAP;
        c2.CHK_UPPER_ROLE_PERMISSION__c = true;
        update c2;
        set<Id> setRoles = Util.getSubordinateRoles(userinfo.getUserRoleid());
        
        b = Util.isAccountManager;
        c2.CHK_UPPER_ROLE_PERMISSION__c = false;
        update c2;
        b = Util.isAccountManager;
       PDPCountryGroup__c cg = new PDPCountryGroup__c(name='aaa');
       insert cg;
        List<PDPCountryGroup__c> lista = Util.CountryGroups;        
        Map<String, Product_Grouping__c> mapa2 = util.productgroups; 
		Division__c div = new Division__c(Name='test');
        insert div;
        Map<String, Division__c> mapa3 = util.divisions;
         div=Util.currentDivision;
         Id strId = Util.divisionId;
        
        User usr = new User(Id = userInfo.getUserId(), StandardDivision__c = null);
        update usr;
        Util.currentDivision = null;
        div=Util.currentDivision;
        
        cI.DE_EnableAccountSharing__c=true;
        update cI;
        Campaign camp = util.currentCampaign;
        
        Campaign campI = new Campaign(countryref__c=cI.id, statuscode__c=200, divisionref__c = div.Id);
        insert campI;
        Campaign camp2 = Util.currentCampaignUser;
        
        campI.statuscode__c=300;
        update campI;
        
        camp = util.previewsCampaign;
        
        String str2 = Util.getSetting('CAMPAIGN_SALES_RM_TEMPLEATE');
        Util.addInfoMessage(null);
        b=Util.hasPermissionsForCampaignLineItemEdit;
        Util.addErrorMessage(null);
        util.addConfirmMessage(null);
        Util.addWarningMessage(null);
        Util.addDebugMessage(null);
        
        List<String> strList = new List<String>();
        strList.add('1');
        strList.add('2');
        String joinstr=Util.joinStrings(strList, '-');
        
        Set<Id>setIdList = util.getIdSet(lista);
    }    
    
    
    
}