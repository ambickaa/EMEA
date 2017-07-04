public virtual class ProductVirtualGenericSearch
{
	public Product2 searchProduct {get; set;}
	
	// result of Search
    public List<Product2x> results {get; set;}
    
    public ProductVirtualGenericSearch()
    {
    	
        searchProduct = new Product2();
        results = new List<Product2x>();
    }
}