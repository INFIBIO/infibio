###SCRIPT FOR 96 WELL-PLATE MANAGING ON THE MICROSCOPE####
##

## Considering 16 time points (t0-t15), collecting sample in duplicates, 80uL/well

## 1/2 plate will be used for each experiment (from A5 to H8 and from A9 to H12): t0 -> A5-A6 or A9-A10, ...

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
XX = 'SPORES_GERMINATION_XXX' # Needs to be changed at the start of a new experiment, specifying the dyes used and the date of experiment
refpos = 1
objpos = 3 # 40x objective  
pocillos = 96 # number of wells with sample (change at the start of a new experiment)
wells = ['A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B12','B11','B10','B9','B8','B7','B6','B5','B4','B3','B2','B1',
         'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D12','D11','D10','D9','D8','D7','D6','D5','D4','D3','D2','D1',
         'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F12','F11','F10','F9','F8','F7','F6','F5','F4','F3','F2','F1',
         'G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H12','H11','H10','H9','H8','H7','H6','H5','H4','H3','H2','H1'] #wells filled with sample
dilution = '1000x' # Set the dilution applied to samples
sample1 = 'SK1'
sample2 = 'SK1'
samples = 'SK1'
brightfield = 'TL10'
light_source1 = 'NBred'
light_source2 = 'FDAblue'
dil_str = str(dilution)
samp1_str = str(sample1)
samp2_str = str(sample2)
samples_str = str(samples)
TL_str = str(brightfield)
light1_str = str(light_source1)
light2_str = str(light_source2)

## fixed variables: 
userPath = ('D:\Xisca\Experiments')
wgPath = ('D:\Xisca\Experiments')
path = r'D:\Xisca\Experiments\{}'.format(XX) 
os.mkdir(path)
intensities = {2:30, 3:80, 4:95}
wait = 1            #Time to wait between wells
wait_turnoff = 1    #Seconds to wait to turn off the light after snap
wait_turnon = 1     #Seconds to wait after turn on the light before snap
hardwaresetting1 = ZenHardwareSetting()

#######################################################
# Get and set stage position (initial pos)
#######################################################
Zen.Devices.Focus.MoveTo(7660.000)
Zen.Devices.Stage.MoveTo(15000.000,11720.000) # (position of A1)
well_names = [r'{}{}'.format(chr(65 + i // 12),i % 12 + 1) for i in range(96)]
posX = Zen.Devices.Stage.ActualPositionX
posY = Zen.Devices.Stage.ActualPositionY
listx = [i*9000+posX for i in range(0,12)]  # List with positions of x
listy = [i*9000+posY for i in range(0,8)]   # List with positions of y
well_positions = {well_name: [listx[i % 12], listy[i // 12]] for i, well_name in enumerate(well_names)} # Dictionary with well positions and the xy positions
time_dict = {
    'A1': 0, 'A2': 0, 'A3': 0, 'A4': 1, 'A5': 1, 'A6': 1, 'A7': 2, 'A8': 2, 'A9': 2, 'A10': 3, 'A11': 3, 'A12': 3,
    'B1': 4, 'B2': 4, 'B3': 4, 'B4': 5, 'B5': 5, 'B6': 5, 'B7': 6, 'B8': 6, 'B9': 6, 'B10': 7, 'B11': 7, 'B12': 7,
    'C1': 8, 'C2': 8, 'C3': 8, 'C4': 9, 'C5': 9, 'C6': 9, 'C7': 10, 'C8': 10, 'C9': 10, 'C10': 11, 'C11': 11, 'C12': 11,
    'D1': 12, 'D2': 12, 'D3': 12, 'D4': 13, 'D5': 13, 'D6': 13, 'D7': 14, 'D8': 14, 'D9': 14, 'D10': 15, 'D11': 15, 'D12': 15,
    'E1': 0, 'E2': 0, 'E3': 0, 'E4': 1, 'E5': 1, 'E6': 1, 'E7': 2, 'E8': 2, 'E9': 2, 'E10': 3, 'E11': 3, 'E12': 3,
    'F1': 4, 'F2': 4, 'F3': 4, 'F4': 5, 'F5': 5, 'F6': 5, 'F7': 6, 'F8': 6, 'F9': 6, 'F10': 7, 'F11': 7, 'F12': 7,
    'G1': 8, 'G2': 8, 'G3': 8, 'G4': 9, 'G5': 9, 'G6': 9, 'G7': 10, 'G8': 10, 'G9': 10, 'G10': 11, 'G11': 11, 'G12': 11,
    'H1': 12, 'H2': 12, 'H3': 12, 'H4': 13, 'H5': 13, 'H6': 13, 'H7': 14, 'H8': 14, 'H9': 14, 'H10': 15, 'H11': 15, 'H12': 15
}

def photo_loop_pos(well_name):
    #t_end = time.time() + 60 * minutos
    #start_time = time.time()
    pos = 0
    def photo():
    # With this loop we can set an amount of minutes for the loop to continue. 
    # Its parameters are: Minutos -> amount of minutes for the loop to continue
    # Wait -> number of seconds to wait until the next picture.
        try:
            image = Zen.Acquisition.AcquireImage()
            Zen.Application.Documents.Add(image)
            well_image_count = image_counts[well_name_entry]
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samples_str, TL_str, time_dict[well_name_entry[0:]])
            Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
            Zen.Devices.Lamp.TargetIntensity = 0
            Zen.Devices.Lamp.Apply()
            Zen.Application.Documents.RemoveAll()
            time.sleep(wait)
            hardwaresetting1 = ZenHardwareSetting()
            hardwaresetting1.SetParameter('MTBLED6', 'IsEnabled', 'true')
            Zen.Devices.ApplyHardwareSetting(hardwaresetting1)
            time.sleep(wait_turnon)
            image = Zen.Acquisition.AcquireImage()
            Zen.Application.Documents.Add(image)
            well_image_count = image_counts[well_name_entry]
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samp1_str, light1_str, time_dict[well_name_entry[0:]])
            Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
            Zen.Application.Documents.RemoveAll()
            time.sleep(wait_turnoff)
            hardwaresetting1 = ZenHardwareSetting()
            hardwaresetting1.SetParameter('MTBLED6', 'IsEnabled', 'false')
            Zen.Devices.ApplyHardwareSetting(hardwaresetting1)
            time.sleep(wait)
            hardwaresetting1 = ZenHardwareSetting()
            hardwaresetting1.SetParameter('MTBLED3', 'IsEnabled', 'true')
            Zen.Devices.ApplyHardwareSetting(hardwaresetting1)
            time.sleep(wait_turnon)
            image = Zen.Acquisition.AcquireImage()
            Zen.Application.Documents.Add(image)
            well_image_count = image_counts[well_name_entry]
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samp2_str, light2_str, time_dict[well_name_entry[0:]])
            Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
            Zen.Application.Documents.RemoveAll()
            time.sleep(wait_turnoff)
            hardwaresetting1 = ZenHardwareSetting()
            hardwaresetting1.SetParameter('MTBLED3', 'IsEnabled', 'false')
            Zen.Devices.ApplyHardwareSetting(hardwaresetting1)
            time.sleep(wait)
            image_counts[well_name_entry] += 1
        except Exception as e:
            print(r"Error in taking a photo: {}".format(str(e)))

    
    image_counts = {well_name_entry: 0 for well_name_entry in well_name}
        
    for well, well_name_entry in enumerate(wells):  # Iterate with index and value
        Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0], well_positions[well_name_entry][1])
        Zen.Devices.Lamp.TargetIntensity = 10
        Zen.Devices.Lamp.Apply()
        Zen.Acquisition.StartLive()
        Zen.Application.Pause("Adjust focus")
        photo()
        # Moved to a specific position
        Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0]+500,well_positions[well_name_entry][1])
        Zen.Devices.Lamp.TargetIntensity = 10
        Zen.Devices.Lamp.Apply()
        Zen.Acquisition.StartLive()
        Zen.Application.Pause("Adjust focus")
        photo()
        Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0],well_positions[well_name_entry][1]+500)
        Zen.Devices.Lamp.TargetIntensity = 10
        Zen.Devices.Lamp.Apply()
        Zen.Acquisition.StartLive()
        Zen.Application.Pause("Adjust focus")
        photo()
        Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0]-500,well_positions[well_name_entry][1])
        Zen.Devices.Lamp.TargetIntensity = 10
        Zen.Devices.Lamp.Apply()
        Zen.Acquisition.StartLive()
        Zen.Application.Pause("Adjust focus")
        photo()
        pos = well + 1

                
#######################################################
## Create a camera setting
#######################################################
##
## Remove all open images
## Define experiment
exp = Zen.Acquisition.Experiments.GetByName('Xisca_setup_fluorescence.czexp')
img = Zen.Acquisition.Execute(exp)

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
Zen.Acquisition.StartLive()
Zen.Application.Pause("Stage: Speed - 10%, Acceleration - 3%")
Zen.Application.Pause("Camera: Exposure time - 30 ms, Acquisition ROI - 3200 x 3200, Gain - Standard")
Zen.Application.Pause("Acquisition - Auto Save - Close CZI Image After Acquisition")
Zen.Application.Pause("Light sources (B/R): 30 and TL: 10. Set up directly in the microscope before starting the experiment!")
photo_loop_pos(wells)