public class TriggerCampaignAutoData implements Triggers.Handler
{
    private static map<Id, Year__c> yearsMap = new map<Id, Year__c>();
    private static map<Id, Country__c> countriesMap = new map<Id, Country__c>();
    private static map<Id, Division__c> divisionsMap = new map<Id, Division__c>();
    private static map<Id, User> usersMap = new map<Id, User>();
    
    public static map<Id, Year__c> getYears(list<Id> yearsList) {
        map<Id, Year__c> result = new map<Id, Year__c>();
        
        list<Id> finalFilter = new list<Id>();
        for (Id element: yearsList) {
            if (!yearsMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, yearsMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Year__c> newElements = new list<Year__c>([SELECT Id, Name FROM Year__c WHERE Id IN :finalFilter]);
            result.putAll(newElements);
            yearsMap.putAll(newElements);
        }
        
        return result;
    }
    
    public static map<Id, Country__c> getCountries(list<Id> countryList) {
        map<Id, Country__c> result = new map<Id, Country__c>();
        
        list<Id> finalFilter = new list<Id>();
        for (Id element: countryList) {
            if (!countriesMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, countriesMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Country__c> newElements = new list<Country__c>([SELECT Id, Name FROM Country__c WHERE Id IN :finalFilter]);
            result.putAll(newElements);
            countriesMap.putAll(newElements);
        }
        
        return result;
    }
    
    public static map<Id, Division__c> getDivisions(list<Id> divisionList) {
        map<Id, Division__c> result = new map<Id, Division__c>();
        
        list<Id> finalFilter = new list<Id>();
        for (Id element: divisionList) {
            if (!divisionsMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, divisionsMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Division__c> newElements = new list<Division__c>([SELECT Id, Name FROM Division__c WHERE Id IN :finalFilter]);
            result.putAll(newElements);
            divisionsMap.putAll(newElements);
        }
        
        return result;
    }

    public static map<Id, User> getUsers(list<Id> userList) {
        map<Id, User> result = new map<Id, User>();
        
        list<Id> finalFilter = new list<Id>();
        for (Id element: userList) {
            if (!usersMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, usersMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<User> newElements = new list<User>([SELECT Id, Name FROM User WHERE Id IN :finalFilter]);
            result.putAll(newElements);
            usersMap.putAll(newElements);
        }
        
        return result;
    }
    
    public void handle()
    {
        Set<Id> aYears = new Set<Id>();
        Set<Id> aCountries = new Set<Id>();
        Set<Id> aDivisions = new Set<Id>();
        Set<Id> aUsers = new Set<Id>();
        
        for (Campaign aCampaign : (List<Campaign>)Trigger.new)
        {
            if (aCampaign.YearV2__c != null)
            {
                aYears.add(aCampaign.YearV2__c);
            }
            if (aCampaign.CountryRef__c != null)
            {
                aCountries.add(aCampaign.CountryRef__c);
            }
            if (aCampaign.DivisionRef__c != null)
            {
                aDivisions.add(aCampaign.DivisionRef__c);
            }
            aUsers.add(aCampaign.OwnerId);
        }
        
        /*Map<Id, Year__c> aYearMap = new Map<Id, Year__c>([SELECT Id, Name FROM Year__c WHERE Id IN :aYears]);*/
        Map<Id, Year__c> aYearMap = getYears(new list<Id>(aYears));
        /*Map<Id, Country__c> aCountyMap = new Map<Id, Country__c>([SELECT Id, Name FROM Country__c WHERE Id IN :aCountries]);*/
        Map<Id, Country__c> aCountyMap = getCountries(new list<Id>(aCountries));
        /*Map<Id, Division__c> aDivisionMap = new Map<Id, Division__c>([SELECT Id, Name FROM Division__c WHERE Id IN :aDivisions]);*/
        Map<Id, Division__c> aDivisionMap = getDivisions(new list<Id>(aDivisions));
        /*Map<Id, User> aUserMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :aUsers]);*/
        Map<Id, User> aUserMap = getUsers(new list<Id>(aUsers));
        
        for (Campaign aCampaign: (List<Campaign>)Trigger.new)
        {
            if (aCampaign.RecordTypeId == Util.recordType.get('Campaign:Sales_camp'))
            {
                // Set Name
                List<String> aNameList = new List<String>();
                Country__c aCountry = aCountyMap.get(aCampaign.CountryRef__c);
                if (aCountry != null)
                {
                    aNameList.add(aCountry.Name);
                }
                Division__c aDivision = aDivisionMap.get(aCampaign.DivisionRef__c);
                if (aDivision != null)
                {
                    aNameList.add(aDivision.Name);
                }
                Year__c aYear = aYearMap.get(aCampaign.YearV2__c);
                if (aYear != null)
                {
                    aNameList.add(aYear.Name);
                }
                User aUser = aUserMap.get(aCampaign.OwnerId);
                if (aUser != null)
                {
                    aNameList.add(aUser.Name);
                }
                if (aCampaign.DE_Season__c != null && aCampaign.DE_Season__c != '')
                {
                    aNameList.add(aCampaign.DE_Season__c);
                }
                aCampaign.Name = Util.joinStrings(aNameList, ' - ');
                
                // Set Inital Status
                if (aCampaign.StartDate > Date.today())
                {
                    aCampaign.StatusCode__c = 100;
                    aCampaign.IsActive = false;
                }
                if (aCampaign.StartDate <= Date.today() && aCampaign.EndDate > Date.today())
                {
                    aCampaign.StatusCode__c = 200;
                    aCampaign.IsActive = true;
                }
                if (aCampaign.EndDate <= Date.today() && aCampaign.ArchiveDate__c > Date.today())
                {
                    System.debug('::::::::::::trigger');
                    aCampaign.StatusCode__c = 300;
                    aCampaign.IsActive = false;
                }
                if (aCampaign.ArchiveDate__c <= Date.today())
                {
                    aCampaign.StatusCode__c = 400;
                    aCampaign.IsActive = false;
                }
            }
           if (aCampaign.RecordTypeId == Util.recordType.get('Campaign:NPS'))
            {
                // Set Name
                List<String> aNameList = new List<String>();
                Country__c aCountry = aCountyMap.get(aCampaign.CountryRef__c);
                Year__c aYear = aYearMap.get(aCampaign.YearV2__c);
                Division__c aDivision = aDivisionMap.get(aCampaign.DivisionRef__c);
                
                if (aCountry != null)
                {
                    aNameList.add(aCountry.Name);
                }

                if (aDivision != null)
                {
                    aNameList.add(aDivision.Name);
                }
                
                if (aYear != null)
                {
                    aNameList.add(aYear.Name);
                }
                if (aCampaign.TXT_Segment__c != null)
                {
                    aNameList.add(aCampaign.TXT_Segment__c);
                }
                if (aCampaign.TXT_Wave__c != null)
                {
                    aNameList.add(aCampaign.TXT_Wave__c);
                }
                
                
                aCampaign.Name = 'NPS - ' + Util.joinStrings(aNameList, ' - '); 
        }
    }
    
}
}