@isTest (seeAlldata=true)
public class TEST_REST_VoucherPdfGenerator {

    public static testmethod void testRest() {
     
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/dummy/voucherGenerator/';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');
        // Invoke the method directly
        REST_VoucherPdfGenerator.generateSignedPdfs();

   }

}