/**
* @author: Accenture
* @date: 2015
* @project: Invoice PDF
*
* @group: ACS
*
* @description: Trigger Handler on Attachment that handles populate/delete the Attachment Id in the Invoice__c object.
*/
public class AttachmentTriggerHandler {
	
	/*******************************************************************************************************
    * @description: Updates the Invoice__c with the Attactment Id when the attachment is inserted.
    * @param: newAttachments the records involved in the transaction.    
    * @return:
    * @example:
    * 
    */ 	
	public void OnAfterInsert(Attachment[] newAttachments){
		System.debug('Attachment OnAfterInsert entry : ');
		
		Map<Id, Id> parentIdMap = new Map<Id, Id>();	
		List<Invoice__c> updateInvList = new List<Invoice__c>();	

		
		for(Attachment att : getInvoiceAttachmentList(newAttachments)){
			parentIdMap.put(att.ParentId, att.Id);
		}
		if(parentIdMap.size()>0){
			Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>([SELECT Id, Invoice_PDF_Att_Id__c FROM Invoice__c WHERE Id IN : parentIdMap.keySet()]);

			for(Id invId : invoiceMap.keySet()){
				invoiceMap.get(invId).Invoice_PDF_Att_Id__c = parentIdMap.get(invId);
			}			
			try{
				update invoiceMap.values();
			}catch(Exception e){System.debug('AttachmentTriggerHandler OnAfterInsert error : ' +e.getMessage());}
		}
	}
	
	/*******************************************************************************************************
    * @description: Deletes Attactment Id from the Invoice__c when the attachment is deleted.
    * @param: newAttachments the records involved in the transaction.    
    * @return:
    * @example:
    * 
    */
	public void OnAfterDelete(Attachment[] oldAttachments, Map<Id, Attachment> oldAttachmentsMap){	
		System.debug('Attachment OnAfterDelete  entry : ');

		List<Invoice__c> updateInvList = new List<Invoice__c>();
		Set<Id> attId = new Set<Id>();
		
		for(Attachment att : getInvoiceAttachmentList(oldAttachments)){
			attId.add(att.ParentId);			
		}
		if(attId.size()>0){
			for(Invoice__c inv : [SELECT Id, Invoice_PDF_Att_Id__c FROM Invoice__c WHERE Id = : attId]){			
				inv.Invoice_PDF_Att_Id__c = '';
				updateInvList.add(inv);
			}
		}
		if(updateInvList.size()>0){
			try{				
				update updateInvList;
			}catch(Exception e){System.debug('AttachmentTriggerHandler OnAfterDelete : ' +e.getMessage());}			
		}
	}

	public List<Attachment> getInvoiceAttachmentList(Attachment[] attachmentList){
		System.debug('getInvoiceAttachmentList Attachment entry : ');
		
		List<Attachment> invoiceAttachmentList = new List<Attachment>();
		Map<Id, Attachment> invoiceAttachmentMap = new Map<Id, Attachment>();
		List<Invoice__c> invoiceList = new List<Invoice__c>();
		Set<Id> attParentId = new Set<Id>();

		for(Attachment att : attachmentList){
			if(att.ParentId != null){
				attParentId.add(att.ParentId);
				invoiceAttachmentMap.put(att.ParentId, att);
			}			
		}
		if(attParentId.size() > 0){
			invoiceList = [SELECT Id FROM Invoice__c WHERE Id IN : attParentId];
		}
		if(invoiceList.size() > 0){
			for(Invoice__c inv : invoiceList){
				invoiceAttachmentList.add(invoiceAttachmentMap.get(inv.Id));
			}
		}
		return invoiceAttachmentList;
	}
}