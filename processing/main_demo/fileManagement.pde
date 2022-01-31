
String separator = System.getProperty("file.separator");

boolean fileExistsCaseSensitive(String fileName) {
  File dataFolder = new File(dataPath("../../../pictures"));

  for (File file : dataFolder.listFiles())
    if (file.getName().equals(fileName))
      return true;

  return false;
}
