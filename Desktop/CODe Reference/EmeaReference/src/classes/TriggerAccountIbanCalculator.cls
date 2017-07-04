/** 
    CR-00000424 :  IBAN Field calculator.
    This trigger will automatically calculate the IBAN number for each country and fill the field IBAN

*/
public without sharing class TriggerAccountIbanCalculator implements Triggers.Handler
{
    //---------------------------------------------------------------------------------------------------------------
    // Public Variables
    //---------------------------------------------------------------------------------------------------------------
    public Map<String, String> Map_ISOCode {get; set;}
    public Map<String, String> Map_Alphabet {get; set;}

    //---------------------------------------------------------------------------------------------------------------
    // Get a map with countryRef and Country name
    //---------------------------------------------------------------------------------------------------------------
    public static Map<Id, String> Map_Countries {
    	get {
    		if(Map_Countries == null) {
    			Map_Countries = new Map<Id,String>();
    			for(Country__c c : [SELECT Id, Name FROM Country__c WHERE Name IN : Label.IBAN_Countries.split(',')])
    				Map_Countries.put(c.Id, c.Name);
    		}
    		return Map_Countries;
    	}
    	set;
    }
    
    public void handle()
    {
        //---------------------------------------------------------------------------------------------------------------
        // Initialisation
        //---------------------------------------------------------------------------------------------------------------
        Map<Id, String> Map_Account_BAN = new Map<Id, String>();
        List<Account> List_Accounts = new List<Account>();
        //---------------------------------------------------------------------------------------------------------------
        // Get a map with Accounts to update and old the BAN to compare and see if it changed
        //---------------------------------------------------------------------------------------------------------------       
        if (trigger.isUpdate){
            for (Account a : (List<Account>)Trigger.old){
                if(Map_Countries.containsKey(a.CountryRef__c)){
                    Map_Account_BAN.put(a.id, a.GC_Bank_Account_Number__c);
                }
            }
        }
        //---------------------------------------------------------------------------------------------------------------
        // For all Accounts from the included countries.
        //---------------------------------------------------------------------------------------------------------------
        for (Account a : (List<Account>)Trigger.new){
            if (Map_Countries.containsKey(a.CountryRef__c)){
        //---------------------------------------------------------------------------------------------------------------
        // Get a list with the accounts to insert.
        //---------------------------------------------------------------------------------------------------------------               
                if(trigger.IsInsert && a.GC_Bank_Account_Number__c != null && a.GC_Bank_Account_Number__c!=''){
                    List_Accounts.add(a);
                }
        //---------------------------------------------------------------------------------------------------------------
        // Get a list with the accounts to update.
        //---------------------------------------------------------------------------------------------------------------
                if(trigger.IsUpdate){
                    if(a.GC_Bank_Account_Number__c != Map_Account_BAN.get(a.id)){
                        List_Accounts.add(a);
                    }
                }
            }
        }

        system.debug('***AccountIDs: ' + List_Accounts);
        //---------------------------------------------------------------------------------------------------------------
        // IIf at least one account has had the Account Number changed:
        // Get a map with Country and ISO code.
        // Get a map with the alphabet and position +10 ( A = 10, B = 11, etc.)
        //---------------------------------------------------------------------------------------------------------------       
        If (List_Accounts.size()>0) {
            getMapISOCode();
            getMapAlphabet();
        }
        //---------------------------------------------------------------------------------------------------------------
        // Iterate all accounts listed.
        //---------------------------------------------------------------------------------------------------------------
        for (Account a : List_Accounts){
            String BankAccountNumber = a.GC_Bank_Account_Number__c;
        //---------------------------------------------------------------------------------------------------------------
        // Get Bank account number and remove '/' and '-'
        //---------------------------------------------------------------------------------------------------------------       
            if(BankAccountNumber != '' && BankAccountNumber != null){
                //BankAccountNumber.deleteWhitespace();
                BankAccountNumber = BankAccountNumber.trim();
                BankAccountNumber = BankAccountNumber.replaceAll('(\\s+)', '');
                String BAN1 = BankAccountNumber.remove('/');
                String BAN = BAN1.remove('-');
        //---------------------------------------------------------------------------------------------------------------
        // Add zeros until the length is 20
        //---------------------------------------------------------------------------------------------------------------
                while(BAN.length()<20){
                    BAN = '0' + BAN;
                }
                BAN = BAN.right(4) + BAN.left(16);
        //---------------------------------------------------------------------------------------------------------------
        // Creation of the 26-digit number --> BAN + ISO code values + 00
        //---------------------------------------------------------------------------------------------------------------
                String BankAccountNumber26 = '';
                List<String> List_ISO = Map_ISOCode.get(Map_Countries.get(a.CountryRef__c)).split('');
                BankAccountNumber26 = BAN + Map_Alphabet.get(List_ISO[0]) + Map_Alphabet.get(List_ISO[1])  + '00';
        //---------------------------------------------------------------------------------------------------------------
        // Get IBAN control digit
        //---------------------------------------------------------------------------------------------------------------
                //double ICD = (double)BankAccountNumber26;
                decimal ICD = decimal.valueOf(BankAccountNumber26);
                ICD =  ICD/97;
                ICD = 98 - (97*(ICD - math.floor(ICD)));
                system.debug('*** IBAN Control Digit: ' + ICD);
                ICD = integer.valueOf(ICD.round(System.RoundingMode.HALF_UP));
        //---------------------------------------------------------------------------------------------------------------
        // Populate IBAN field
        //---------------------------------------------------------------------------------------------------------------               
                String IBAN = '';
                if (math.floor(ICD/10) != 0) {
                    IBAN = Map_ISOCode.get(Map_Countries.get(a.CountryRef__c)) + String.valueOf(ICD) + BAN;
                } else {
                    IBAN = Map_ISOCode.get(Map_Countries.get(a.CountryRef__c)) + '0' + String.valueOf(ICD) + BAN;
                }
                a.TXT_IBAN__c = IBAN;
            } else {
                a.TXT_IBAN__c  = '';
            }
        }
    }
        //---------------------------------------------------------------------------------------------------------------
        // getMapISOCode()
        // This method gets a map with all countries in the list of cases and their ISO codes from a system custom label.
        //---------------------------------------------------------------------------------------------------------------
    private void getMapISOCode() {
        
        Map_ISOCode = new Map<String, String>();
        List<String> List_Countries_ISO = Label.Countries_ISO.split(',');
        for(String c : List_Countries_ISO) {
            List<String> ciso = c.split('=');
            Map_ISOCode.put(ciso[0],ciso[1]);
        }
    }
        //---------------------------------------------------------------------------------------------------------------
        // getMapAlphabet()
        // This method gets a map with the alphabet and the corresponding value of each letter ( A = 10, B = 11, etc.).
        //---------------------------------------------------------------------------------------------------------------
    private void getMapAlphabet(){
    
        List<String> List_Alphabet = Label.Alphabet.split(',');
        Map_Alphabet = new Map<String, String>();
        for (Integer i = 0; i < List_Alphabet.size(); i++){
            Integer pos = i + 10;
            String position = String.valueOf(pos);
            Map_Alphabet.put(List_Alphabet[i].toUpperCase(),position);
        }
    }
}