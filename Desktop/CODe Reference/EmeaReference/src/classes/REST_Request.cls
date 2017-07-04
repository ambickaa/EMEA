global with sharing class REST_Request {

	public DateTime timestamp {get;set;} 
	public DateTime maxtimestamp {get;set;}
	public DateTime pagetimestamp {get;set;}	
	public Integer mode {get;set;}         
	public Integer lastItem {get;set;}  
	public String lastId {get;set;} 
}