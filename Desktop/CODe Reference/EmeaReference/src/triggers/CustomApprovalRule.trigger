/***************************************
Organization: Accenture
****************************************/
Trigger CustomApprovalRule on Case_Approval_Rule__c (after insert,after update,before delete)
{
    if(checkRecursive.runOnce3() && checkRecursive.run5==True)
    {
        if (trigger.isAfter && trigger.isInsert )
        {
            Hlpr_customApprovalRule.AfterUpdate(Trigger.new);
        }
        if (trigger.isAFter && trigger.isUpdate)
        {
            Hlpr_customApprovalRule.AfterUpdate(Trigger.new);
        }        
        if(trigger.isBefore && trigger.isdelete)
        {
            //system.debug('Inside Delete approval rule trigger---------');
            Hlpr_customApprovalRule.beforeDelete(trigger.old);
             //system.debug('after Delete approval rule trigger---------');
        }    
            
    }
}