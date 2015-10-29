__author__ = 'cflagg'

import os, glob, re

# check working directory
cwd = os.getcwd() # store it
print(os.getcwd()) # print it

# set working directory
os.chdir("N:\\common\\TOS\\FOPSDataEntry\\2015\\databases\\veg_characterization")

# renaming function
# source: http://stackoverflow.com/questions/225735/batch-renaming-of-files-in-a-directory
def renamer(files, pattern, replacement):
    for pathname in glob.glob(files):
        basename = os.path.basename(pathname)
        new_filename= re.sub(pattern, replacement, basename)
        if new_filename != basename:
            os.rename(
              pathname,
              os.path.join(os.path.dirname(pathname), new_filename))

# list the files in the dir
os.listdir(cwd)

# use function to rename one piece
# what the r means: http://stackoverflow.com/questions/2081640/what-exactly-do-u-and-r-string-flags-do-in-python-and-what-are-raw-string-l
# the r is called a "string literal"; 'u' is also a string literal
# https://docs.python.org/2.0/ref/strings.html
# http://stackoverflow.com/questions/4780088/in-python-what-does-preceding-a-string-literal-with-r-mean
# the r means that escape characters such as '\' won't work, but will instead be treated as a regular character
renamer('*.accdb',r"_vst_dataIngest_", r"_vst_div_characterization_")

# use function again to rename second piece
renamer('*.accdb',"_v2b", "_v1")

os.listdir('.')


