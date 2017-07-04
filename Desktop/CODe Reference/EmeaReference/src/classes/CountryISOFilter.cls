public class CountryISOFilter {

	public static String ISOfilter(User usr) {
        
		Country__c code = new Country__c();
		String a;

		// 1. ISO code from User
		// 2. ISO code from Country
		// 3. ISO code from Country Area
		if(usr.CountryISOCode__c != null)
		{
			a = usr.CountryISOCode__c;
		} else {

			code = [SELECT TXT_Country_ISO_Code__c  FROM Country__c WHERE Name = :usr.Country];
			if(code.TXT_Country_ISO_Code__c != null)
			{
				a = code.TXT_Country_ISO_Code__c;
			} else {
				Country__c areaCode = [SELECT Area__c, Area__r.TXT_Country_ISO_Code__c FROM Country__c WHERE Name = :usr.Country];
				a = areaCode.Area__r.TXT_Country_ISO_Code__c;
			}
		}
		return a;
	}
}