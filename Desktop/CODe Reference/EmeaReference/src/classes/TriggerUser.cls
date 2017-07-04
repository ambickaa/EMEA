public with sharing class TriggerUser implements Triggers.Handler
{
public void handle()
{ 
for (User u : (List<User>)Trigger.new) 
u.DE_ExternalID__c = u.Alias;

}
}