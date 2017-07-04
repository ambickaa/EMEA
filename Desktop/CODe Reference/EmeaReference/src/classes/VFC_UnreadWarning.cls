public with sharing class VFC_UnreadWarning {

    public case casedetail{get;set;}
    
    public case cSave{get;set;}
    
    public VFC_UnreadWarning(ApexPages.StandardController controller) {
        casedetail=(case)controller.getRecord();
    }
    public PageReference save() {
        cSave=[select id,GC_IsUnread_Email__c from case where id = :casedetail.id];
        if(cSave.GC_IsUnread_Email__c == true)
        {
         ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.severity.INFO, 'Warning: You have Unread Emails or should un-check the Unread Email tickbox'));
        }
        
         return null;
    }

}