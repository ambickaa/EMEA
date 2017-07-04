/**
* @author: Accenture
* @date: 2015
* @project: Invoice PDF
* @group: ACS*
* @description: Test the scenarios of the AttachmentTriggerHandler class
*/
@isTest
private class AttachmentTriggerHandler_Test {
	
    public static Account getAccountRecord(String accountName){

    	Account newAccountRecord = new Account();
    	newAccountRecord.Name = 'name '+ accountName;    	   	
    	return newAccountRecord;
    } 

    public static Invoice__c getInvoiceRecord(Id accountId, String invoiceNumber, String orderNumber, String integrationKey, String pdfId ){

    	Invoice__c newInvoiceRecord = new Invoice__c();
    	newInvoiceRecord.Name = invoiceNumber;
    	newInvoiceRecord.GC_Order_Number__c = orderNumber;
    	newInvoiceRecord.GC_Integration_Key__c = integrationKey;
    	newInvoiceRecord.GC_Account_Integration_Key__c = accountId;
    	newInvoiceRecord.Invoice_PDF_Att_Id__c = pdfId;    	
    	return newInvoiceRecord;
    } 
    public static Attachment getAttachment(String invoiceId, String decodeString, Id parentId){        
        
        transient Blob blbPDFContent = EncodingUtil.base64Decode(decodeString);
        transient Attachment attachmentPDF = new Attachment();
        attachmentPdf.ParentId = parentId;
        attachmentPdf.Name = 'Invoice # ' +invoiceId+'.pdf ';
        attachmentPdf.ContentType = 'application/pdf';
        attachmentPdf.IsPrivate = false;
        attachmentPdf.Body = blbPDFContent;       
        return attachmentPDF; 
    }    	  
	
	@isTest static void AttachmentTriggerHandlerOnAfterInsert() {
		
        Account testAccount = getAccountRecord('ACS Invoice');
		insert testAccount;
		Invoice__c testInvoice = getInvoiceRecord(testAccount.Id, 'a0vL0000000Fqa1', '357684','0100118782', '');
		insert testInvoice;
		Attachment testAttachment = getAttachment('12344', 'a0vL0000000Fqa1',testInvoice.Id);		
		insert testAttachment;
		System.assertEquals(testAttachment.Id, [SELECT Id, Invoice_PDF_Att_Id__c FROM Invoice__c WHERE Id =: testInvoice.Id ].Invoice_PDF_Att_Id__c);
	}
	
	@isTest static void AttachmentTriggerHandlerOnAfterDelete() {
		
        Account testAccount = getAccountRecord('ACS Invoice');
		insert testAccount;
		Invoice__c testInvoice = getInvoiceRecord(testAccount.Id, 'a0vL0000000Fqa1', '357684','0100118782', '');
		insert testInvoice;
		Attachment testAttachment = getAttachment('12344', 'a0vL0000000Fqa1',testInvoice.Id);		
		insert testAttachment;
		Test.startTest();
		delete testAttachment;
		System.assertEquals(null, [SELECT Id, Invoice_PDF_Att_Id__c FROM Invoice__c WHERE Id =: testInvoice.Id ].Invoice_PDF_Att_Id__c);
		Test.stopTest();
	}	
}