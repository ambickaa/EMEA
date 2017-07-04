/*
  @description
  @copyright everis
*/
public with sharing class Stock2Pick
{

  public Product2 pc {get;set;}
  public ProductCatalogEntry__c pce {get;set;}
  public boolean selected {get;set;}
  
  /*
    @description Constructor
  */
  public Stock2Pick(Product2 p)
  {
      this.pc = p;
      this.selected = false;
      
  }
  public Stock2Pick(ProductCatalogEntry__c pce){
      this.pce = pce;
      this.selected = false;
  }
  
}