
String separator = System.getProperty("file.separator");

boolean fileExistsCaseSensitive(String fileName) {
  File dataFolder = new File(dataPath("../../../pictures"));
  
  //File dataFolder = new File(dataPath("/Users/elisacastelli/Documents/GitHub/CPAC_CollectiveDynamicPortrait/pictures"));
  for (File file : dataFolder.listFiles()){
    
    if (file.getName().equals(fileName))
      return true;

  }
  return false;
}
