@isTest(SeeAllData=true)
private class Util_Test
{
    
    private static testMethod void Util_Test()
    {
        // Create necessary data for testinG
        Country__c cat = new Country__c(Name='Catalonia', TXT_Country_ISO_Code__c='CAT', CHK_UPPER_ROLE_PERMISSION__c=true);
        insert cat;
        Country__c pais = new Country__c(Name='HQ', TXT_Country_ISO_Code__c='HQ', CHK_UPPER_ROLE_PERMISSION__c=true, TacticalPlanSetting__c='Generic');
        insert pais;
        
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User cUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', 
                            Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                            ProfileId=p.Id, LanguageLocaleKey='en_US', Country='Catalonia');
        insert cUser;
        
        Account acc = new Account(Name='testAcc', CountryRef__c=cat.id, OwnerId=cUser.id);
        insert acc;
        
        Lead l = new Lead(Status='Open', LastName='Xuan', Company='everis', CHK_Consent_Accept_Terms__c=true);
        insert l;
        
        Recordtype salesCmp = [SELECT Id, Name FROM Recordtype WHERE Name='Sales Campaign' LIMIT 1];
        // system.debug('@@namaste countryView : ' + util.countryView.country.id);
        system.debug('@@namaste cmp2 : ' + salesCmp);
        Campaign cmp = new Campaign(CountryRef__c=cat.id, OwnerId=cUser.id, StatusCode__c=200, DivisionRef__c=util.divisionid, Recordtype=salesCmp);
        insert cmp;
        
        system.runAs(cUser){
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', acc.id);
        
            // Execute Util's class methods
            Id prodGrp = Util.getProductGroup('Food');
            Id prodGrp2 = Util.getProductGroup('Food');
            
            String acName = Util.currentAccount.Name;
            system.debug('@@acName : ' + acName);
            String acPais = util.currentAccountCountry.CountryRef__r.Name;
            Boolean cpStd = util.isCpStandard;
            System.currentPageReference().getParameters().put('mode', 'merchandiseManagementEdit');
            String modus = util.currentLookupMode;    // util....=null
            // System.currentPageReference().getParameters().put('currentLookupMode', 'null');    // HELP es poden resetear els parametres?¿
            util.currentLookupMode=null;
            System.currentPageReference().getParameters().put('mode', 'tacticalEdit');
            String modus2 = util.currentLookupMode;
            util.currentLookupMode=null;
            // System.currentPageReference().getParameters().put('currentLookupMode', 'null');
            System.currentPageReference().getParameters().put('mode', 'trailEdit');
            String modus3 = util.currentLookupMode;
            
            Boolean accOwner = util.isAccountOwner;    // HELP Com controlar camps del currentUser?¿ RunAs?¿
            system.debug('@@namaste accountOwner : ' + accOwner);
            util.isAccountOwner=null;
            accOwner=null;
            acc.OwnerId=cUser.id;
            update acc;
            accOwner = util.isAccountOwner;
            
            Map<String, Id> rt= util.recordtype;
            Map<Id, string> rtId= util.recordtypeId;
            
            String uName = util.currentUser.Name;
            system.debug('@@namaste1 : ' + uName);
            Country__c curAP = util.currentAP;
            system.debug('@@namaste2 : ' + curAP);
            
            UserRole emeRol = [SELECT Id, Name FROM UserRole WHERE Name='EME'];
            set<Id> subRols = util.getSubordinateRoles(emeRol.id);
            
            boolean accMng = util.isaccountmanager;    // HELP change currentAP or it's fields?¿
            // WwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWw
            PDPCountryGroup__c pdpCountGrp = new PDPCountryGroup__c(Name='Test', Grouping__c='G', Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=false, 
                                                        Country_LVL_2__c=true, SAP_Country_Code__c='4434313');
            insert pdpCountGrp;
            List<PDPCountryGroup__c> ctryGrp = util.CountryGroups;
            // WwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWw
            
            Year__c anyPassat = util.lastYear;
            
            Map<String, String> urlParms = util.urlParameters;
                    
            Map<String, Division__c> mapDiv = util.divisions;
            Id div = util.divisionId;
            Map<String, Product_Grouping__c> prodGrpMap = util.productGroups;
            
            system.debug('@@namaste countryView : ' + util.countryView);
            system.debug('@@namaste countryView : ' + util.countryView.isAccountSharingEnabled);
            
            Campaign currCampg = util.currentCampaign;
            util.countryView.isAccountSharingEnabled=true;    // HELP Com canviar aquest valor del camp?¿
            // update util.countryView;
            Campaign currCampg2 = util.currentCampaign;
            Campaign curCmpgUsr = util.currentCampaignUser;
            Campaign prvCmp = util.previewsCampaign;
            boolean hasPermCLI = util.hasPermissionsForCampaignLineItemEdit;
            
            String msg='yes we test';
            util.addInfoMessage(msg);
            util.addErrorMessage(msg);
            util.addConfirmMessage(msg);
            util.addWarningMessage(msg);
            util.addDebugMessage(msg);
            
            List<String> joinIt = msg.split(' ');
            String joined = util.joinStrings(joinIt, '-');
            List<Account> listAcc = new List<Account>(); 
            listAcc.add(acc);
            Set<id> idSet = util.getIdSet(listAcc);
            
            Campaign curCornCamp = util.getcurrentCornCampaign(cUser.id);
            
            Map<String, String> attDoc = util.attachDocs;
            
            Boolean rgnMng = util.isRegionalManagerRSA;
            
            util.resetLead(l);
            
            // boolean trig = util.inTrigger;
            
            system.debug('@@namaste3 : ' + Util.currentUser.Country);
            
        }
    }
    
    private static testMethod void Util_Test2()
    {
        // Create necessary data for testinG
        Country__c cat = new Country__c(Name='Catalonia', TXT_Country_ISO_Code__c='CAT', CHK_UPPER_ROLE_PERMISSION__c=true);
        insert cat;
        Country__c pais = new Country__c(Name='HQ', TXT_Country_ISO_Code__c='HQ', CHK_UPPER_ROLE_PERMISSION__c=true, TacticalPlanSetting__c='Generic');
        insert pais;
        
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User cUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', 
                            Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                            ProfileId=p.Id, LanguageLocaleKey='en_US', Country='Catalonia');
        insert cUser;
        User otherUser=new user(TXT_Division__c='15',TXT_Sales_Org__c='00',Username='apocalypse123@test.com', LastName='testrt', Email='testother@test.com', 
                            Alias='oTEST', CommunityNickname='TiESTo', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                            ProfileId=p.Id, LanguageLocaleKey='en_US', Country='Catalonia', SAP_Partner_Code__c='we68w789cs7cf78');
        insert otherUser;
        
        Recordtype accRt = [SELECT Id, Name FROM Recordtype WHERE Name='Group/Farm/Site' LIMIT 1];
        Account acc = new Account(Name='testAcc', CountryRef__c=cat.id, OwnerId=otherUser.id, RecordTypeId=accRt.id, TXT_Partners_Ids__c='wh4t3v3r');
        insert acc;
        
        // Lead l = new Lead(Status='Open', LastName='Xuan', Company='everis', CHK_Consent_Accept_Terms__c=true);
        // insert l;
        
        Recordtype salesCmp = [SELECT Id, Name FROM Recordtype WHERE Name='Sales Campaign' LIMIT 1];
        // system.debug('@@namaste countryView : ' + util.countryView.country.id);
        system.debug('@@namaste cmp2 : ' + salesCmp);
        Campaign cmp = new Campaign(CountryRef__c=cat.id, OwnerId=cUser.id, StatusCode__c=200, DivisionRef__c=util.divisionid, Recordtype=salesCmp);
        insert cmp;
        
        system.runAs(cUser){
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('id', acc.id);
        
            // Execute Util's class methods
            // Id prodGrp = Util.getProductGroup('Food');
            // Id prodGrp2 = Util.getProductGroup('Food');
            
            String acName = Util.currentAccount.Name;
            system.debug('@@acName : ' + acName);
            // String acPais = util.currentAccountCountry.CountryRef__r.Name;
            // Boolean cpStd = util.isCpStandard;
            // System.currentPageReference().getParameters().put('mode', 'merchandiseManagementEdit');
            // String modus = util.currentLookupMode;    // util....=null
            // System.currentPageReference().getParameters().put('currentLookupMode', 'null');    // HELP es poden resetear els parametres?¿
            // util.currentLookupMode=null;
            // System.currentPageReference().getParameters().put('mode', 'tacticalEdit');
            // String modus2 = util.currentLookupMode;
            // util.currentLookupMode=null;
            // System.currentPageReference().getParameters().put('currentLookupMode', 'null');
            // System.currentPageReference().getParameters().put('mode', 'trailEdit');
            // String modus3 = util.currentLookupMode;
            
            system.debug('@@ currAcc partners : ' + util.currentAccount.TXT_Partners_Ids__c);
            system.debug('@@ currUs SAPc : ' + util.currentUser.SAP_Partner_Code__c);
            system.debug('@@ currUs : ' + util.currentUser);
            
            Boolean accOwner = util.isAccountOwner;    // HELP Com controlar camps del currentUser?¿ RunAs?¿
            system.debug('@@namaste accountOwner : ' + accOwner);
            // util.isAccountOwner=null;
            // accOwner=null;
            // acc.OwnerId=cUser.id;
            // update acc;
            // accOwner = util.isAccountOwner;
            
            // Map<String, Id> rt= util.recordtype;
            // Map<Id, string> rtId= util.recordtypeId;
            
            // String uName = util.currentUser.Name;
            // system.debug('@@namaste1 : ' + uName);
            // Country__c curAP = util.currentAP;
            // system.debug('@@namaste2 : ' + curAP);
            
            
        }
    }
    
}