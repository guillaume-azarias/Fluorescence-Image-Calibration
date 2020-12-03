# This script is converting 1-digit file names into 2-digits file names
#
# Why: When loading a series of images in Fiji/ImageJ, 1-digit file names
# are not loaded in numerical order but between 2-digit filenames
#
# How: using the regex module
#
# How to use:
#   - Select the folder containing the image to process
#   - Click run

# Import the relevant library

import os
from tkinter import *
from tkinter import filedialog, simpledialog
import regex as re

# Choose the directory to process (from https://www.programcreek.com/python?code=junerain123%2Fjavsdt%2Fjavsdt-master%2Fjavsdt%2Ffunctions_preparation.py)
def choose_directory():
    directory_root = Tk()
    directory_root.withdraw()
    path_work = filedialog.askdirectory(
        initialdir='/Users/guillaume/Documents/Projects/Fiji/All macro/Resources/Mitochondrial ROS in vitro', title='Select the Directory to process')
    if path_work == '':
        print('Please choose a directory !')
        sleep(2)
        return choose_directory()
    else:
        return path_work

# Ask for the common part of filenames
def basic_name():
    basename = Tk()
    basename.withdraw()
    base = simpledialog.askstring(
        '2-digits filename converter', 'Enter the basic name', initialvalue=example_name)
    if base == '':
        print('Please enter a valid basic name')
        return basic_name()
    else:
        return base


directory = choose_directory()
# example_name = '20160404z2_TL_w1FITC_s1_t1'
example_name = re.split('[.]', os.listdir(directory)[10])[0]
root_name = basic_name()
print(root_name)

# Convert 1-digit into 2-digit
path_work = '/Users/guillaume/Documents/Projects/Fiji/All macro/Resources/Mitochondrial ROS in vitro/Dummy'
# filename = '20160404z2_TL_w1FITC_s1_t1.TIF'
# root_name = '20160404z2_TL_w1FITC_s1_t'

# Loop on each file of the folder
for filename in enumerate(os.listdir(path_work)):
    filename = filename[1]
    # Split the filename into string, number and extension
    number_and_extension = re.sub(root_name, '', filename)
    number = re.split('[.]', number_and_extension)[0]

    if len(number) < 2 and number.isdigit():
        number = int(number) # regex originally generated number as a string
        two_digit = str('{:02d}'.format(number))
        
        # Reconstruct the filename
        extension = re.split('[.]', number_and_extension)[1]
        new_filename = root_name + two_digit + extension
        print('new filename: ' + str(new_filename))

        # Save it
        os.rename(path_work + '/' + filename, path_work + '/' + new_filename)

