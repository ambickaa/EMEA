/**
* @author: Accenture
* @date: 2015
* @project: Invoice PDF
*
* @group: ACS
*
* @description: Test class for the ACSInvoicePDF_Controller
*               Testing positive nd negatve scenarios
*/
@isTest
private class ACSInvoicePDF_Controller_Test {	

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

    public static ACS_Invoice_PDF_CS__c getInvoiceCustomSetting(){

         ACS_Invoice_PDF_CS__c invoiceCS = new ACS_Invoice_PDF_CS__c(     
             
             Certificate_Name__c = 'MON_US_SFDC_CastIron_Integration_Certificate_1',
             End_Point_URL__c = 'http://api.salesforce.com/ACS/Invoice',
             Request_Time_Out__c = 6000,
             View_PDF_URL__c = '/servlet/servlet.FileDownload?file=', 
             View_Invoice_PDF_Button_URL__c = 'test/test',
             Error_Condition_1__c = 'Error Condition 1',
             Error_Condition_2__c = 'Error Condition 2',
             Error_Condition_3__c = 'Error Condition 3',
             Error_Condition_4__c = 'Error Condition 4',
             Error_Condition_5__c = 'Error Condition 5',
             Message_Condition_1__c = 'Message 1',
             Message_Condition_2__c = 'Message 2',
             Message_Condition_3__c = 'Message 3',
             Message_Condition_4__c = 'Message 4',
             Message_Condition_5__c = 'Message 5',
             Message_Condition_Default__c = 'Default Message'             
         );
        return invoiceCS;                                                              
    }   
	
	@isTest static void autoRunTest() {		
		
        Account testAccount = getAccountRecord('ACS Invoice');
		insert testAccount;
		Invoice__c testInvoice = getInvoiceRecord(testAccount.Id, 'a0vL0000000Fqa1', '357684','0100118782', '');
		insert testInvoice;
		ACS_Invoice_PDF_CS__c testCustomSetting = getInvoiceCustomSetting();
		insert testCustomSetting;
		PageReference testPage = Page.ACSInvoicePDF_VFP;
		Test.setCurrentPage(testPage);	
		ACSInvoicePDF_Controller testextension = new ACSInvoicePDF_Controller(new ApexPages.StandardController(testInvoice));
		ApexPages.currentPage().getParameters().put('id', testInvoice.Id);

		//Test negative scenario where invoice record DO NOT have an invoice PDF in the attachment
		testextension.autoRun();	
		
        //Test Attachment insertion	
		String invoiceId = String.valueOf(testInvoice.Id);
		String testAttachment = testextension.getAttachment('00011', 'Testing', invoiceId);	
		Attachment testAtt = [SELECT Id, ParentId FROM Attachment WHERE Id =: testAttachment];		
		System.assertEquals(testAtt.ParentId, testInvoice.Id);
		
        //Test positive scenario where invoice record have an invoice PDF in the attachment
		testextension.autoRun();		
		System.assert(testextension.autoRun().getURL().contains(testAtt.Id));
	    
        //Test getErrorMessage(String processingError)method
        System.assertEquals(testextension.getErrorMessage('Error Condition 1'), testCustomSetting.Message_Condition_1__c);
        System.assertEquals(testextension.getErrorMessage('Error Condition 2'), testCustomSetting.Message_Condition_2__c);
        System.assertEquals(testextension.getErrorMessage('Error Condition 3'), testCustomSetting.Message_Condition_3__c);
        System.assertEquals(testextension.getErrorMessage('Error Condition 4'), testCustomSetting.Message_Condition_4__c);
        System.assertEquals(testextension.getErrorMessage('Error Condition 5'), testCustomSetting.Message_Condition_5__c);
    }	
}