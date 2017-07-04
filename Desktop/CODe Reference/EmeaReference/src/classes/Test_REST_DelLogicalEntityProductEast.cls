@isTest
public class Test_REST_DelLogicalEntityProductEast{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        
        List<Product2> ForDelPro= new List<Product2>();
        List<ProductCatalogEntry__c> ForDelPCE= new List<ProductCatalogEntry__c>();
        List<ProductCatalog__c> ForDelPCA= new List<ProductCatalog__c>();
        List<Stock__c> ForDelSto= new List<Stock__c>();
        
		ForDelPro.add(Test_REST_DataFactoryEast.Pr1);
		ForDelPro.add(Test_REST_DataFactoryEast.Pr2);
		
		ForDelPCE.add(Test_REST_DataFactoryEast.pce);
		ForDelPCE.add(Test_REST_DataFactoryEast.pcepast);
		
		ForDelPCA.add(Test_REST_DataFactoryEast.prcat); 
		ForDelPCA.add(Test_REST_DataFactoryEast.pastcat); 
		ForDelPCA.add(Test_REST_DataFactoryEast.trcat); 
		ForDelPCA.add(Test_REST_DataFactoryEast.procat); 
		
        ForDelSto.add(Test_REST_DataFactoryEast.Sto);                         
      	
        REST_DelLogicalEntityProductEast.REST_DelLogicalEntity_Product params = new REST_DelLogicalEntityProductEast.REST_DelLogicalEntity_Product();
        params.products=ForDelPro;
        params.productcatalogs=ForDelPCA;
        params.productcatalogentries=ForDelPCE;
        params.Stocks=ForDelSto;
             
        REST_DelLogicalEntityProductEast.REST_DelLogicalEntity_Product returned = REST_DelLogicalEntityProductEast.getDeletedProducts(params);
        
        System.AssertEquals(returned.products.Size(),0);
        System.AssertEquals(returned.productcatalogs.get(0).Id,Test_REST_DataFactoryEast.pastcat.ID);
        System.AssertEquals(returned.productcatalogentries.get(0).Id,Test_REST_DataFactoryEast.pcepast.ID);
        
        test.stopTest();
    }   
     public static testmethod void ExTest(){

        Test_REST_DataFactoryEast.TestData();
   		
   		test.StartTest();
   		
        REST_DelLogicalEntityProductEast.REST_DelLogicalEntity_Product params = new REST_DelLogicalEntityProductEast.REST_DelLogicalEntity_Product();
        params = REST_DelLogicalEntityProductEast.getExample();
        System.Assert(params.Stocks.Size()==1);
        
        test.stopTest();
     }        
}