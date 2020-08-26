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
from tkinter import filedialog

# Choose the directory to process (from https://www.programcreek.com/python?code=junerain123%2Fjavsdt%2Fjavsdt-master%2Fjavsdt%2Ffunctions_preparation.py)


# def choose_directory():
#     directory_root = Tk()
#     directory_root.withdraw()
#     path_work = filedialog.askdirectory(
#         initialdir='/Users/guillaume/Documents/Projects/Fiji/Cell-to-cell-Heterogenity', title='Select it')
#     if path_work == '':
#         print('你没有选择目录! 请重新选：')
#         sleep(2)
#         return choose_directory()
#     else:
#         # askdirectory 获得是 正斜杠 路径C:/，所以下面要把 / 换成 反斜杠\
#         return path_work

# Ask for the common part of filenames
def basic_name():
    basename = Tk()
    basename.withdraw()
    base = askstring('Enter the basic name')
    if path_work == '':
        print('Please enter a valid basic name')
        sleep(2)
        return basic_name()
    else:
        return base


basic_name()
print(base)

# choose_directory()

path_work = '/Users/guillaume/Documents/Projects/Fiji/All macro/Resources/Mitochondrial ROS in vitro/Glutamate effect/a_Data/20161214z2'

# Convert 1-digit into 2-digit
# Split the filename into string, number and extension
filename = '20160404z2_TL_w1FITC_s1_t1.TIF'
# temp = re.compile("([a-zA-Z]+)([0-9]+)")
# res = temp.match(filename).groups()

# print(res)
# regex = re.compile('[^A-Za-z0-9]')
# device = regex.sub('', str(device))

