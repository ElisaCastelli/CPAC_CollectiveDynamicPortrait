/** 
 * Python Command (v2.2.3)
 * GoToLoop (2017/Jul/05)
 *
 * Forum.Processing.org/two/discussion/23471/
 * combining-two-pieces-of-code/p2#Item_51
 *
 * Forum.Processing.org/two/discussion/23324/
 * executing-python-3-code-from-within-processing/p1#Item_38
 *
 * GitHub.com/GoToLoop/command/blob/patch-1/src/
 * deadpixel/command/Command.java
 *
 * GitHub.com/GoToLoop/CenturyOfTheSun/blob/master/segmenting.py
 */

import deadpixel.command.Command;

static final String BASH = platform == WINDOWS? "cmd /C " : "bash -c ";

static final String CD = "cd ", PY_APP = "python ";
static final String AMP = " && ", SPC = " ";

static final String PY_DIR = "scripts/";

//static final String PY_FILE = PY_DIR + "abc.py";
static final String PY_FILE = PY_DIR + "segmenting.py";

static final String PICS_DIR = "images/";

static final String PICS_EXTS = "extensions=" +
  ",png,jpg,jpeg,gif,tif,tiff,tga,bmp,wbmp";

String[][] dirs;

void setup() {
  final String dp = dataPath(""), py = dataPath(PY_FILE);
  final String prompt = BASH + CD + dp + AMP + PY_APP + py;

  final String pd = dataPath(PICS_DIR);
  final String pics = join(getPathsFromFolder(pd), SPC);

  final Command cmd = new Command(prompt + SPC + pics);
  println(cmd.command, ENTER);

  println("Success:", cmd.run(), ENTER);
  printArray(cmd.getOutput());

  dirs = getFoldersOfImagePaths();
  println(joinStrArr2d(dirs));
  println("Segment folders found:", dirs.length);

  exit();
}

static final String joinStrArr2d(final String[][] arr2d) {
  final StringBuilder sb = new StringBuilder();
  int outer = 0;

  for (final String[] arr1d : arr2d) {
    sb.append(ENTER);
    int inner = 0;

    for (final String item : arr1d)  sb
      .append('[').append(outer).append("][").append(inner++)
      .append("] ").append(item).append(ENTER);

    ++outer;
  }

  return sb.toString();
}

String[][] getFoldersOfImagePaths() {
  final String[] dirs = getSegFolders();
  final String[][] all = new String[dirs.length][];

  for (int i = 0; i < all.length; all[i] = getPathsFromFolder(dirs[i++]));
  return all;
}

String[] getSegFolders() {
  final File dataFolder = dataFile("");
  if (!dataFolder.isDirectory())  return new String[0];

  final String[] folders = listPaths(dataFolder.getPath(), "directories");
  final StringList sl = new StringList(folders);

  final java.util.Iterator<String> it = sl.iterator();
  while (it.hasNext())  if (!it.next().endsWith("_segments"))  it.remove();

  return sl.array();
}

String[] getPathsFromFolder(final String folder) {
  return listPaths(folder, PICS_EXTS);
}
