public with sharing class Product2x
{
	public String id {get; set;}
	public String name {get; set;}
	public Product2 record {get; set;}
	public boolean checked {get; set;}

	public Product2x (Product2 product)
	{
		this.checked = false;
		this.id = product.id;
		this.name = product.name;
		this.record = product;
	}
}