public class TriggerSetCountryId implements Triggers.Handler
{
    private String countryIdField;
    private String countryRefField;

    public static Map<String, Country__c> mapCountriesByName {
    	get {
    		if(mapCountriesByName == null) {
    			mapCountriesByName = new Map<String, Country__c>();
    			for(Country__c c : [SELECT Id, Name FROM Country__c])
    				mapCountriesByName.put(c.Name, c);
    		}
    		return mapCountriesByName;
    	}
    	set;
    }
    
    public TriggerSetCountryId()
    {
        countryIdField = 'CountryID__c';
        countryRefField = 'CountryRef__c';
    }
    
    public TriggerSetCountryId(String theCountryRefField, String theCountryIdField)
    {
        countryIdField = theCountryIdField;
        countryRefField = theCountryRefField;
    }
    
    public void handle()
    {
        if (countryRefField.contains('.'))
        {
            
        } else
        {
            for (sObject anObject: Trigger.new)
            {
                Object aValue = anObject.get(countryRefField);
                anObject.put(countryIdField, aValue == null ? null : String.valueOf(aValue));
            }
        }
        
        for (SObject anObject: Trigger.new)
        {
            if(anObject instanceof Account)
            {
                Account acc = (Account)anObject;
                if(acc.countryref__c== null && acc.gc_country_name__c!=null && acc.gc_country_name__c!='' && mapCountriesByName.get(acc.gc_country_name__c)!=null)
                {
                    acc.countryRef__c= mapCountriesByName.get(acc.gc_country_name__c).Id;
                }
            }
        }
    }
}