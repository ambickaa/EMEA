global with sharing class CustomCSVIterator implements Iterator<string>, Iterable<string> {
  
  public String csvFile;
  
  public CustomCSVIterator(){
    Document document=[SELECT Id, body FROM Document WHERE DeveloperName LIKE 'NFUSalesToInsert%' LIMIT 1];
    csvFile=(document.body).toString();
  }
  global Boolean hasNext(){
    return (csvFile.length()>=1)?true:false;
  }
  global String next(){
    String returned = ''; 
    List<String> lines = csvFile.split('\n',15);
    for(Integer i=0;i<lines.size()-1;i++){
        returned += lines[i] + '\n';
    }

    csvFile= csvFile.replace(returned, '');

    return returned;
  }
  global Iterator<String> Iterator(){
    return this;
  }
}