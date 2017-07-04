@isTest
public class Test_REST_DelLogicalEntityVoucherEast{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        
        List<Voucher__c> ForDelVou= new List<Voucher__c>();
        List<VoucherLineItem__c> ForDelVLI= new List<VoucherLineItem__c>();
         
        REST_DelLogicalEntityVoucherEast.REST_DelLogicalEntity_Voucher params = new REST_DelLogicalEntityVoucherEast.REST_DelLogicalEntity_Voucher();
        params.Vouchers=ForDelVou;
        params.VoucherLineItems=ForDelVLI;
             
        REST_DelLogicalEntityVoucherEast.REST_DelLogicalEntity_Voucher returned = REST_DelLogicalEntityVoucherEast.getDeletedVouchers(params);
             
        System.Assert(returned.vouchers.Size()==0);
        
        System.Assert(returned.voucherLineItems.Size()==0);
        
        params = REST_DelLogicalEntityVoucherEast.getExample();
        System.Assert(params.Vouchers.size()==0);
        
        Test.stopTest();
     }
}