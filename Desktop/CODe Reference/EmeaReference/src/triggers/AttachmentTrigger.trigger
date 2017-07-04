/**
 * @author ACS Accenture
 * @date November 2015
 * @description Attachment Trigger
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer           Date            Description
 *  ----------------------------------------------------------------------------- 
 *	ACS Accenture		11/14/2015		Newly created.	(Invoice PDF)
 */
trigger AttachmentTrigger on Attachment (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	
    AttachmentTriggerHandler handler = new AttachmentTriggerHandler();
    //if (trigger.isBefore) {
    //    if (trigger.isInsert) {            
    //    }
        
    //    if (trigger.isUpdate) {
    //    }
        
    //    if (trigger.isDelete) {           
    //    }
    //}

    if (trigger.isAfter) {
        if (trigger.isInsert) {
        	handler.OnAfterInsert(Trigger.new);
        } 
        
        //if (trigger.isUpdate) {
        //}
        
        if (trigger.isDelete) {
        	handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        }
        
        //if (trigger.isUndelete) {
        //}
    }
}