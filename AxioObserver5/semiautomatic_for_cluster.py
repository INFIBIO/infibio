###SCRIPT FOR 96 WELL-PLATE MANAGING ON THE MICROSCOPE####
##

# Focus all the capture points, change the range of autofocus to 30 um (minimum)

from System.IO import File, Directory, FileInfo, Path
import os
import datetime
import time
import sys
from System import ApplicationException
from System import TimeoutException
import string
import random

## set variables to be changed:
XX = 'Exp_Zymolyase_C100_50_T35_ConA03-20240219' # Needs to be changed at the start of a new experiment
refpos = 2 # DIC_TL
objpos = 4 # 63x objective  
pocillos = 7 # number of pocillos with sample (change at the start of a new experiment)
wells = ['F6','F7','F8','F9','F10','F11','F12'] #wells filled with sample
zymo = '1000' # Set the concentration of yeast
temp = 'RT' # Set the temperature of the experiment in ºC
temp_str = str(temp)
zymo_str = str(zymo)

## fixed variables: 
userPath = ('D:\Xisca\Experiments')
wgPath = ('D:\Xisca\Experiments')
path = r'D:\Xisca\Experiments\{}'.format(XX) 
os.mkdir(path)
intensities = {2:60, 3:80, 4:95}

#######################################################
# Get and set stage position (initial pos)
#######################################################
Zen.Devices.Focus.MoveTo(8750.000)
Zen.Devices.Stage.MoveTo(15639.000,11570.000) # (position of A1)
well_names = [r'{}{}'.format(chr(65 + i // 12),i % 12 + 1) for i in range(96)]
posX = Zen.Devices.Stage.ActualPositionX
posY = Zen.Devices.Stage.ActualPositionY
listx = [i*9000+posX for i in range(0,12)]  # List with positions of x
listy = [i*9000+posY for i in range(0,8)]   # List with positions of y
well_positions = {well_name: [listx[i % 12], listy[i // 12]] for i, well_name in enumerate(well_names)} # Dictionary with well positions and the xy positions
time_dict = {
    '1': 0,
    '2': 1,
    '3': 2,
    '4': 3,
    '5': 4,
    '6': 5,
    '7': 6,
    '8': 7,
    '9': 8,
    '10': 9,
    '11': 10,
    '12': 11,
    'D1': 12,
    'E1': 12,
    'F1': 12,
    'D2': 13,
    'E2': 13,
    'F2': 13,
    'D3': 14,
    'E3': 14,
    'F3': 14,
    'D4': 15,
    'E4': 15,
    'F4': 15
}


def photo_loop_pos(well_name):
    pos = 0
    def photo():
        try:
            image = Zen.Acquisition.AcquireImage()
            Zen.Application.Documents.Add(image)
            well_image_count = image_counts[well_name_entry]  # Get the image count for the well
           if well_name[0] in ('A', 'B', 'C'):
                time_key = well_name[1:]
            elif well_name[0] in ('D', 'E', 'F'):
                time_key = well_name[0:]
            else:
                time_key = None
                
            if time_key is not None:
                time = time_dict.get(time_key, None)
            else:
                time = None
            image_name = "{}.{}_{}_{}".format(well_name_entry, well_image_count, zymo_str, time)
            image_counts[well_name_entry] += 1  # Increment the image count
            Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
            Zen.Application.Documents.RemoveAll()
        except Exception as e:
            print(r"Error in taking a photo: {}".format(str(e)))

    while time.time() < t_end or pos < pocillos:
        image_counts = {well_name_entry: 0 for well_name_entry in well_name}
        
        for well, well_name_entry in enumerate(wells):  # Iterate with index and value
                Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0], well_positions[well_name_entry][1])
                Zen.Application.Pause("Adjust focus")
                photo()
                # Moved to a specific position
                Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0] + random.randint(-100, 100), well_positions[well_name_entry][1] + random.randint(-100, 100))
                photo()
                Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0]+ random.randint(-100, 100), well_positions[well_name_entry][1] + random.randint(-100, 100))
                photo()
                Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0] + random.randint(-100, 100), well_positions[well_name_entry][1] + random.randint(-100, 100))
                photo()
                pos = well + 1


#######################################################
## Create a camera setting
#######################################################
##
## Remove all open images
## Define experiment
exp = Zen.Acquisition.Experiments.GetByName('Xisca_setup.czexp')
img = Zen.Acquisition.Execute(exp)
#fullPath = path + '\\' + immg.Name
#image.Save(fullPath)
## Set camera parameters to default
#Zen.Acquisition.ActiveCamera.SetDefaultSetting()
## Apply camera setting
#Zen.Acquisition.ActiveCamera.ApplyCameraSetting(camerasetting1)

#######################################################
## Microscope settings
# Get and set lamp intensity
#######################################################
## Get current lamp intensity and lamp mode
## Show current lamp intensity 
lampint = Zen.Devices.Lamp.ActualIntensity
lampmode = Zen.Devices.Lamp.ActualMode
Zen.Devices.Lamp.TargetMode = ZenLampMode.Set3200K
Zen.Devices.Lamp.Apply()

## Set new lamp intensity
## Show new current lamp intensity 
Zen.Devices.Lamp.TargetIntensity = intensities[objpos] #Objectives: 20x, 40x and 63x -> Lamp intensity: 60, 80, 95, respectively
Zen.Devices.Lamp.Apply()
lampint = Zen.Devices.Lamp.ActualIntensity

#######################################################
# Get and set objective position
#######################################################

Zen.Devices.ObjectiveChanger.TargetPosition = objpos
Zen.Devices.ObjectiveChanger.Apply()

#######################################################
# Get and set reflector position
#######################################################

Zen.Devices.Reflector.TargetPosition = refpos
Zen.Devices.Reflector.Apply()


#######################################################
# Introduce parameters and start the loop
#######################################################

Zen.Application.Pause("Stage: Speed - 20%, Acceleration - 5%")
Zen.Application.Pause("Camera: Exposure time - 30 ms, Acquisition ROI - 1920 x 1216, Gain - 4x")
Zen.Application.Pause("Acquisition - Auto Save - Close CZI Image After Acquisition")
Zen.Acquisition.StartLive()

# Run the photo_loop_pos function
photo_loop_pos(minutos, wells)

