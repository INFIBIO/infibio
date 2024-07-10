import torch
import torch.nn as nn
import torch
import torch.optim as optim
from torch.utils.data import Dataset
from torch.utils.data import DataLoader
from yeaz.unet.model_pytorch import UNet  # Absolute import
from yeaz.unet.custom_dataset import CustomDataset  # Relative import
from torchvision import transforms
import os
from PIL import Image



class UNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv2d = nn.Conv2d(1, 64, kernel_size=3, padding='same', padding_mode='zeros')
        self.conv2d_1 = nn.Conv2d(64, 64, kernel_size=3, padding='same')
        self.conv2d_2 = nn.Conv2d(64, 128, kernel_size=3, padding='same')
        self.conv2d_3 = nn.Conv2d(128, 128, kernel_size=3, padding='same')
        self.conv2d_4 = nn.Conv2d(128, 256, kernel_size=3, padding='same')
        self.conv2d_5 = nn.Conv2d(256, 256, kernel_size=3, padding='same')
        self.conv2d_6 = nn.Conv2d(256, 512, kernel_size=3, padding='same')
        self.conv2d_7 = nn.Conv2d(512, 512, kernel_size=3, padding='same')
        self.conv2d_8 = nn.Conv2d(512, 1024, kernel_size=3, padding='same')
        self.conv2d_9 = nn.Conv2d(1024, 1024, kernel_size=3, padding='same')
        self.conv2d_10 = nn.Conv2d(1024, 512, kernel_size=2, padding='same')
        self.conv2d_11 = nn.Conv2d(1024, 512, kernel_size=3, padding='same')
        self.conv2d_12 = nn.Conv2d(512, 512, kernel_size=3, padding='same')
        self.conv2d_13 = nn.Conv2d(512, 256, kernel_size=2, padding='same')
        self.conv2d_14 = nn.Conv2d(512, 256, kernel_size=3, padding='same')
        self.conv2d_15 = nn.Conv2d(256, 256, kernel_size=3, padding='same')
        self.conv2d_16 = nn.Conv2d(256, 128, kernel_size=2, padding='same')
        self.conv2d_17 = nn.Conv2d(256, 128, kernel_size=3, padding='same')
        self.conv2d_18 = nn.Conv2d(128, 128, kernel_size=3, padding='same')
        self.conv2d_19 = nn.Conv2d(128, 64, kernel_size=2, padding='same')
        self.conv2d_20 = nn.Conv2d(128, 64, kernel_size=3, padding='same')
        self.conv2d_21 = nn.Conv2d(64, 64, kernel_size=3, padding='same')
        self.conv2d_22 = nn.Conv2d(64, 2, kernel_size=3, padding='same')
        self.conv2d_23 = nn.Conv2d(2, 1, kernel_size=1, padding='same')

        # Other stuff
        self.relu = nn.ReLU()
        self.maxpool = nn.MaxPool2d((2,2), stride=(2,2))
        self.dropout = nn.Dropout(0.5)
        self.upsample =  nn.Upsample(scale_factor=2, mode='nearest')
        self.sigmoid = nn.Sigmoid()

    def forward(self, inputs):
        """ Encoder """
        conv1 = self.conv2d(inputs)
        conv1 = self.relu(conv1)
        conv1 = self.conv2d_1(conv1)
        conv1 = self.relu(conv1)
        pool1 = self.maxpool(conv1)

        conv2 = self.conv2d_2(pool1)
        conv2 = self.relu(conv2)
        conv2 = self.conv2d_3(conv2)
        conv2= self.relu(conv2)
        pool2 = self.maxpool(conv2)

        conv3 = self.conv2d_4(pool2)
        conv3 = self.relu(conv3)
        conv3 = self.conv2d_5(conv3)
        conv3 = self.relu(conv3)
        pool3 = self.maxpool(conv3)

        conv4 = self.conv2d_6(pool3)
        conv4 = self.relu(conv4)
        conv4 = self.conv2d_7(conv4)
        conv4 = self.relu(conv4)
        drop4 = self.dropout(conv4)
        pool4 = self.maxpool(drop4)

        
        """ Bottleneck """
        conv5 = self.conv2d_8(pool4)
        conv5 = self.relu(conv5)
        conv5 = self.conv2d_9(conv5)
        conv5 = self.relu(conv5)
        drop5 = self.dropout(conv5)

        """ Decoder """
        up6 = self.upsample(drop5)
        up6 = self.conv2d_10(up6)
        up6 = self.relu(up6)
        merg6 = torch.cat((drop4,up6), dim=1)
        conv6 = self.conv2d_11(merg6)
        conv6 = self.relu(conv6)
        conv6 = self.conv2d_12(conv6)
        conv6 = self.relu(conv6)

        up7 = self.upsample(conv6)
        up7 = self.conv2d_13(up7)
        up7 = self.relu(up7)
        merg7 = torch.cat((conv3,up7), dim=1)
        conv7 = self.conv2d_14(merg7)
        conv7 = self.relu(conv7)
        conv7 = self.conv2d_15(conv7)
        conv7 = self.relu(conv7)

        up8 = self.upsample(conv7)
        up8 = self.conv2d_16(up8)
        up8 = self.relu(up8)
        merg8 = torch.cat((conv2,up8), dim=1)
        conv8 = self.conv2d_17(merg8)
        conv8 = self.relu(conv8)
        conv8 = self.conv2d_18(conv8)
        conv8 = self.relu(conv8)

        up9 = self.upsample(conv8)
        up9 = self.conv2d_19(up9)
        up9 = self.relu(up9)
        merg9 = torch.cat((conv1,up9), dim=1)
        conv9 = self.conv2d_20(merg9)
        conv9 = self.relu(conv9)
        conv9 = self.conv2d_21(conv9)
        conv9 = self.relu(conv9)

        """ Classifier """
        conv9 = self.conv2d_22(conv9)
        conv9 = self.relu(conv9)
        conv10 = self.conv2d_23(conv9)
        conv10 = self.sigmoid(conv10)
        
        
        return conv10

class CustomDataset(Dataset):
    def __init__(self, image_dir, mask_dir, transform=None):
        self.image_dir = image_dir
        self.mask_dir = mask_dir
        self.transform = transform
        self.image_filenames = sorted(os.listdir(image_dir))
        self.mask_filenames = sorted(os.listdir(mask_dir))

    def __len__(self):
        return len(self.image_filenames)

    def __getitem__(self, idx):
        img_path = os.path.join(self.image_dir, self.image_filenames[idx])
        mask_path = os.path.join(self.mask_dir, self.mask_filenames[idx])
        image = Image.open(img_path).convert('L')
        mask = Image.open(mask_path).convert('L')

        if self.transform:
            image = self.transform(image)
            mask = self.transform(mask)
            mask = mask.float() / 255.0
        return image, mask

# Transformación para las imágenes y máscaras
# Example transform
transform = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.ToTensor()
])


# Instanciamos el modelo y cargamos los pesos preentrenados
# Parámetros de entrenamiento
batch_size = 1 
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = UNet().to(device)
pretrained_weights = 'C:/Users/uib/Desktop/YeaZ/YeaZ-GUI/yeaz/unet/weights/weights_budding_PhC_multilab_0_1.pth'
model.load_state_dict(torch.load(pretrained_weights, map_location=device))
# Si necesitas congelar ciertas capas, por ejemplo:
for param in model.conv2d.parameters():
    param.requires_grad = False

# También puedes congelar otras capas según tus necesidades

# Load dataset
train_dataset = CustomDataset('C:/Users/uib/Desktop/NN training/segmentation/masks/images/temp', 'C:/Users/uib/Desktop/NN training/segmentation/masks/temp', transform=transform)
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)

# Definir el optimizador y la función de pérdida
optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=0.001)
criterion = nn.BCELoss()

# Bucle de entrenamiento
num_epochs = 10
model.train()  # Establece el modo del modelo a 'train'

for epoch in range(num_epochs):
    for inputs, targets in train_loader:
        optimizer.zero_grad()  # Resetear los gradientes

        outputs = model(inputs)  # Forward pass
        loss = criterion(outputs, targets)  # Calcular la pérdida

        loss.backward()  # Backpropagation
        optimizer.step()  # Actualizar los pesos

    print(f"Epoch {epoch+1}/{num_epochs}, Loss: {loss.item()}")

# Guardar el modelo entrenado si es necesario
torch.save(model.state_dict(), 'fine_tuned_model_v2.pth')