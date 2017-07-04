public class HlprConUpdate{
public void SapIdUpdate(List<Contact> cn){

list<id> ConId= new list<id>();

for(Contact con :cn)
{
ConId.add(con.AccountId);
}

  List<Account> Acc = [SELECT Id, GC_SAP_ID__c from Account where Id IN :ConId];
for(Account a: Acc )        
{
    for(Contact con1 :cn)
            {
                if(a.GC_SAP_ID__c!= null)
                {
                   con1.Account_SAP_ID_Text__c = a.GC_SAP_ID__c;
                 
                }
             }
        }
}
}