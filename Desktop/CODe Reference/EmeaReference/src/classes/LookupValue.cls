public with sharing class LookupValue
{
	public String id {get; set;}
	public String text {get; set;}

	public LookupValue() {}
	public LookupValue( String id, String text )
	{
		this.id = id;
		this.text = text;
	}
	
	/*public LookupValue clone()
	{
		return new LookupValue(this.id, this.text);
	}*/
}