public class TriggerSetAccountDefaultValues{

    public static void fnSetAccountDefaultValues(List<Account> TriggerNew){
        if(UserInfo.getName()==Label.IntegrationUserCheck){
            for (Account oAcc:TriggerNew) {           
                oAcc.GC_Status_Descr__c = Label.AccountStatusActive;
                
                if(oAcc.GC_Cust_Account_Grp_Descr__c==Label.CustAccountGrpShip_toParty){
                    oAcc.Category__c=Label.AccountCategoryPoS;
                }else{
                    oAcc.Category__c=Label.AccountCategoryDistributor;
                }
                
            }
        }
    }  
}