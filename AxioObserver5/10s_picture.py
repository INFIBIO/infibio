from System.IO import File, Directory, FileInfo, Path
import os
import datetime
import time
import sys
from System import ApplicationException
from System import TimeoutException

XX = 'trialXX' # Needs to be changed at the start of a new experiment
refpos = 2 # DIC_TL
objpos = 4 # 63x objective  
userPath = ('D:\Xisca\Experiments')
wgPath = ('D:\Xisca\Experiments')
path = r'D:\Xisca\Experiments\{}'.format(XX) 
os.mkdir(path)
intensities = {2:60, 3:80, 4:95}
minutos = 0
wait = 0

def photo_seconds(minutos, wait):
    # With this loop we can set an amount of minutes for the loop to continue. 
    # Its parameters are: Minutos -> amount of minutes for the loop to continue
    # Wait -> number of seconds to wait until the next picture.
    t_end = time.time() + 60 * minutos
    start_time=time.time()
    while time.time() < t_end:
        Zen.Acquisition.FindAutofocus()
        image = Zen.Acquisition.AcquireImage()
        Zen.Application.Documents.Add(image)
        current_time = int(time.time() - start_time)
        current_time_str = str(current_time).zfill(4)
        image_name = "{}.czi".format(well_name[i], current_time_str)
        Zen.Application.Save(image, r'{}\{}\{}.czi'.format(userPath, XX, image_name))
        time.sleep(wait)


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
Zen.Acquisition.ActiveCamera.SetDefaultSetting()
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
Zen.Application.Pause("Ajusta parámetros de autofoco y aceleración según la necesidad del experimento!")
Zen.Application.Pause("Software Autofocus: Mode - Auto, Quality - Low Signal, Search - Smart, Sampling - Fine, Relative Range - Range of 50 microns")
Zen.Application.Pause("Stage: Speed - 20%, Acceleration - 5%")
Zen.Acquisition.StartLive()
Zen.Application.Pause("Search field of interest and focus image!")
photo_seconds(minutos, wait)
