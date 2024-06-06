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
XX = 'Exps_fluor_DClFDA_NB_t0_20240606' # Needs to be changed at the start of a new experiment
refpos = 1 # DIC_TL
objpos = 3 # 40x objective  
pocillos = 96 # number of pocillos with sample (change at the start of a new experiment)
#minutos = 200 # When the entire plate has been covered.
wells = ['F5','F6','F7','F8'] #wells filled with sample
dilution = '800' # Set the dilution applied to samples
sample1 = 'SK1'
sample2 = 'SK1'
samples = 'SK1'
brightfield = 'TL10'
light_source1 = 'NBred'
light_source2 = 'DClFDAblue'
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
    'F5': 1, 'F6': 2, 'F7': 3, 'F8': 4
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
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samples_str, TL_str, time_dict[well_name_entry[0:]]-1)
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
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samp1_str, light1_str, time_dict[well_name_entry[0:]]-1)
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
            image_name = "{}.{}_{}_{}_{}_{}".format(well_name_entry, well_image_count, dil_str, samp2_str, light2_str, time_dict[well_name_entry[0:]]-1)
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
Zen.Application.Pause("Light sources (B/R): 50 and TL: 10")
photo_loop_pos(wells)