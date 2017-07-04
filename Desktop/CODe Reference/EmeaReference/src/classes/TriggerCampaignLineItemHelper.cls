public abstract class TriggerCampaignLineItemHelper{
    public static Set<ID> rsa {get;private set;}
    private static Set<ID> accountSharingEnabled ;
    private static Set<ID> notRSA;

    public static void add(Set<ID> paramIDs) // set of Accounts
    {
        if(rsa == null) rsa = new Set<ID>();
        if(notRSA == null) notRSA = new Set<ID>();
        if(accountSharingEnabled  == null) accountSharingEnabled  = new Set<ID>();
        paramIDs.removeAll(rsa);
        paramIDs.removeAll(notRSA);
        
        if(!paramIDs.isEmpty()){
            for(Account a : [SELECT CountryID__c from Account WHERE ID IN :paramIDs]){
                if( a.CountryID__c != null && new CountryAdapter(a.CountryID__c).isRSATacticalPlan){
                    rsa.add(a.id);
                }else{
                    notRSA.add(a.id);
                }
                if (a.CountryID__c != null && new CountryAdapter(a.CountryID__c).isAccountSharingEnabled){
                    accountSharingEnabled.add(a.id);
                }
            }
        }
    }
    
    public static boolean isAccountSharingEnabled(ID paramAccountID)
    {
        return accountSharingEnabled  != null && accountSharingEnabled.contains(paramAccountID);
    }
}