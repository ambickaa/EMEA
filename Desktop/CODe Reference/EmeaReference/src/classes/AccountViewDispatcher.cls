public with sharing class AccountViewDispatcher{
    private final ApexPages.StandardController controller;
    
    String recordId;
    String accDeleted;
    Boolean deleted;    
    public AccountViewDispatcher(ApexPages.StandardController sc){
        this.controller = sc;       
        recordId = sc.getId();
        accDeleted = System.currentPageReference().getParameters().get('IsDeleted');   
    }
    
    public PageReference accountRedirect() {
    
        //Code added by ACS Team on 08/19/2015 // 
        Profile p = [select name from Profile where id = :UserInfo.getProfileId()];
        Account acc = new Account();
        try{
          acc = [SELECT id,recordtypeid,IsDeleted from account where id = :recordId limit 1 ALL ROWS];
          deleted = acc.IsDeleted;
          if(deleted){
            throw new DMLException();
          } else {

            RecordType recType = [SELECT DeveloperName,Id,Name FROM RecordType WHERE  id = :acc.recordtypeid limit 1];
            if (System.Label.ProfileName.equals(p.name) 
                        || (System.Label.SystemAdminProfile.equals(p.name) && System.Label.Account_Global.equals(recType.DeveloperName)))

              {
              PageReference customPage = new PageReference('/'+ recordId+'?nooverride=1' );
              customPage.setRedirect(true);
              return customPage;
              }
                //Code Ends Here//
             else
            {
             Map<String, String> mapParameters = ApexPages.currentPage().getParameters();
                System.debug('mapParameters: ' + mapParameters);
                User usr = [SELECT UserPreferencesApexPagesDeveloperMode, Name, Division, Country FROM User WHERE id = :UserInfo.getUserId()];
                System.debug('Developer Mode : ' + usr.UserPreferencesApexPagesDeveloperMode);
                if (usr.UserPreferencesApexPagesDeveloperMode){
                    if (mapParameters.containsKey('core.apexpages.devmode.url')){
                        mapParameters.remove('core.apexpages.devmode.url');
                    }
                }
                PageReference newPage;
                System.debug('Util.countryView.country.AccountViewPage__c : ' +Util.countryView.country.AccountViewPage__c);
                if(usr.Division == 'CP' && usr.Country != 'Germany') newPage = new PageReference('/apex/AccountViewCP');
                else if(usr.Division == 'CP' && usr.Country == 'Germany') newPage = new PageReference('/apex/AccountViewCPDE');
                //Test Modification for IT Dist AP
                //else if(usr.Division == 'S&T' && usr.Country == 'Italy' && acc.RecordTypeId == '012D000000035Au') newPage = new PageReference('/apex/AccountViewUK');
                //End Test Modification
                else newPage = new PageReference('/apex/' + Util.countryView.country.AccountViewPage__c);
                newPage.getParameters().putAll(mapParameters);
                System.debug('Redirecting to : ' + newPage.getUrl());
                return newPage.setRedirect(true);
            }      
          }
        } 
        catch (Exception e){
          PageReference newPage;
          newPage = new PageReference('/apex/AccountViewError?id=' + recordId + '&isDeleted=' + deleted);
          system.debug('Page URL: ' + newPage);
          return newPage.setRedirect(true);
        }
    }
}