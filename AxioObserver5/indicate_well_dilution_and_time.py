###SCRIPT FOR 96 WELL-PLATE MANAGING ON THE MICROSCOPE####
##


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
XX = 'Exp_Hom_1' # Needs to be changed at the start of a new experiment
refpos = 2 # DIC_TL
objpos = 2 # 63x objective   
minutos = 3 # number of minutes to run the experiment (change at the start of a new experiment)
wells = ['A3','A4','A5','A6','A7','A8','A9','A10','B3','B4','B5','B6','B7','B8','B9','B10','C3','C4','C5','C6','C7','C8','C9','C10','D3','D4','D5','D6','D7','D8','D9','D10',
'E3','E4','E5','E6','E7','E8','E9','E10','F3','F4','F5','F6','F7','F8','F9','F10','G3','G4','G5','G6','G7','G8','G9','G10','H3','H4','H5','H6','H7','H8','H9','H10'] #wells filled with sample

## fixed variables: 
userPath = ('D:\Xisca\Experiments')
wgPath = ('D:\Xisca\Experiments')
path = r'D:\Xisca\Experiments\{}'.format(XX) 
os.mkdir(path)
intensities = {2:60, 3:80, 4:95}
#######################################################
# Get and set stage position (initial pos)
#######################################################
Zen.Devices.Focus.MoveTo(7200.000)
Zen.Devices.Stage.MoveTo(15000.000,11720.000)
well_names = [r'{}{}'.format(chr(65 + i // 12),i % 12 + 1) for i in range(96)]# (e.g. 1st well)
posX = Zen.Devices.Stage.ActualPositionX
posY = Zen.Devices.Stage.ActualPositionY 
listx = [i*9000+posX for i in range(0,12)]
# List with positions of x
listy = [i*9000+posY for i in range(0,8)]
well_positions = {well_name: [listx[i % 12], listy[i // 12]] for i, well_name in enumerate(well_names)}# Dictionary with well positions and the xy positions
dilution_dict = {
    'A': 200,
    'B': 200,
    'C': 500,
    'D': 500,
    'E': 1000,
    'F': 1000,
    'G': 5000,
    'H': 5000
}


def photo_loop_pos(well_name):
    pos = 0
    listax = {}
    listay = {}
    z = 0
    def photo():
        
            
        try:
            time = 0
            count = 0
            if count <= 16:
                dilution = 100
            elif count <=32 and count > 16:
                dilution = 200
            elif count <= 48 and count > 32:
                dilution = 500
            else:
                dilution = 1000
            Zen.Acquisition.FindAutofocus()
            image = Zen.Acquisition.AcquireImage()
            Zen.Application.Documents.Add(image)
            well_image_count = image_counts[well_name_entry]  # Get the image count for the well
            image_name = "{}_{}_{}_{}".format(well_name_entry, well_image_count, dilution_dict[well_name_entry[0]], int(int(well_name_entry[1:2])-3))
            image_counts[well_name_entry] += 1  # Increment the image count
            Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
            Zen.Application.Documents.RemoveAll()
            count+=1
            if time < 8:
                time += 1
            else:
                time = 0
            
        except Exception as e:
            print(r"Error in taking a photo: {}".format(str(e)))
        

    
        
    image_counts = {well_name_entry: 0 for well_name_entry in well_name}
    
    for well, well_name_entry in enumerate(wells):
        
        
        try:
            Zen.Devices.Stage.MoveTo(listax[well_name_entry+str(.0)], listay[well_name_entry+str(.0)])
            Zen.Devices.Focus.MoveTo(z)
            photo()
            Zen.Devices.Stage.MoveTo(listax[well_name_entry+str(.1)], listay[well_name_entry+str(.1)])
            photo()
            Zen.Devices.Stage.MoveTo(listax[well_name_entry+str(.2)], listay[well_name_entry+str(.2)])
            photo()
            Zen.Devices.Stage.MoveTo(listax[well_name_entry+str(.3)], listay[well_name_entry+str(.3)])
            photo()
        except:
            if z == 0:
                z=Zen.Devices.Focus.ActualPosition
            else:
                Zen.Devices.Focus.MoveTo(z)
            Zen.Acquisition.FindAutofocus()
            Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0], well_positions[well_name_entry][1])
            photo()
            listax[well_name_entry+str(.0)] = Zen.Devices.Stage.ActualPositionX 
            listay[well_name_entry+str(.0)] = Zen.Devices.Stage.ActualPositionY
            
            # Moved to a specific position
            Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0] + random.randint(-1000, 1000), well_positions[well_name_entry][1] + random.randint(-1000, 1000))
            photo()
            listax[well_name_entry+str(.1)] = Zen.Devices.Stage.ActualPositionX 
            listay[well_name_entry+str(.1)] = Zen.Devices.Stage.ActualPositionY
            Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0]+ random.randint(-1000, 1000), well_positions[well_name_entry][1] + random.randint(-1000, 1000))
            photo()
            listax[well_name_entry+str(.2)] = Zen.Devices.Stage.ActualPositionX 
            listay[well_name_entry+str(.2)] = Zen.Devices.Stage.ActualPositionY
            Zen.Devices.Stage.MoveTo(well_positions[well_name_entry][0] + random.randint(-1000, 1000), well_positions[well_name_entry][1] + random.randint(-1000, 1000))
            photo()
            listax[well_name_entry+str(.3)] = Zen.Devices.Stage.ActualPositionX 
            listay[well_name_entry+str(.3)] = Zen.Devices.Stage.ActualPositionY
            pos = well + 1
            


#######################################################
## Create a camera setting
#######################################################
##
## Remove all open images
Zen.Application.Documents.RemoveAll()

## Create new camera settings
camerasetting1 = ZenCameraSetting()
## Set camera frame to 1920 x 1216 and center
camerasetting1.SetParameter('Frame', '0, 0, 1920, 1216')
## Set exposure time to 3 ms
camerasetting1.SetParameter('ExposureTime', '3.0')
## Set gain to 4x (opt)
camerasetting1.SetParameter('AnalogGainModeList', '2')
## Save the setting
camerasetting1.SaveAs("MyCameraSetting.czcs", ZenSettingDirectory.Workgroup)

## Set camera parameters to default
# Zen.Acquisition.ActiveCamera.SetDefaultSetting()
## Apply camera setting
Zen.Acquisition.ActiveCamera.ApplyCameraSetting(camerasetting1)

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
Zen.Devices.Lamp.TargetIntensity = intensities[objpos]      ### Objectives: 20x, 40x and 63x -> Lamp intensity: 60, 80, 95, respectively
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
# Get and set stage position (initial pos)
#######################################################
Zen.Devices.Stage.MoveTo(15000,11720) # (e.g. 1st well)

#######################################################
# Introduce parameters and start the loop
#######################################################
Zen.Application.Pause("Check camera, autofocus and stage settings!")
Zen.Application.Pause("Software Autofocus: Mode - Auto, Quality - Low Signal, Search - Smart, Sampling - Fine, Relative Range - Range of 50 microns")
Zen.Application.Pause("Stage: Speed - 20%, Acceleration - 5%")
Zen.Application.Pause("Camera: Exposure time - 3 ms, Acquisition ROI - 1920 x 1216, Gain - 4x")
Zen.Acquisition.StartLive()

# Run the photo_loop_pos function
photo_loop_pos(wells)
