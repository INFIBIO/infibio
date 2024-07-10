import torch
import torch.optim as optim
from torch.utils.data import DataLoader
from yeaz.unet.model_pytorch import UNet  # Absolute import
from yeaz.unet.custom_dataset import CustomDataset  # Relative import
from torchvision import transforms


# Hyperparameters
num_epochs = 25
learning_rate = 0.001
batch_size = 4

# Device configuration
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Data transformation
transform = transforms.Compose([
    transforms.Resize((256, 256)),
    transforms.ToTensor()
])

# Load dataset
train_dataset = CustomDataset('C:/Users/uib/Desktop/NN training/segmentation/masks/images/temp', 'C:/Users/uib/Desktop/NN training/segmentation/masks/temp', transform=transform)
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)

# Initialize model, loss function, and optimizer
model = UNet().to(device)
criterion = torch.nn.BCEWithLogitsLoss()  # Modify according to your problem
optimizer = optim.Adam(model.parameters(), lr=learning_rate)

# Load pre-trained weights
pretrained_weights = 'C:/Users/uib/Desktop/YeaZ/YeaZ-GUI/yeaz/unet/weights/weights_budding_PhC_multilab_0_1.pth'
model.load_state_dict(torch.load(pretrained_weights, map_location=device))

# Training loop
def train(model, dataloader, criterion, optimizer, num_epochs):
    model.train()
    for epoch in range(num_epochs):
        running_loss = 0.0
        for inputs, labels in dataloader:
            inputs, labels = inputs.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item() * inputs.size(0)

        epoch_loss = running_loss / len(dataloader.dataset)
        print(f'Epoch {epoch}/{num_epochs - 1}, Loss: {epoch_loss:.4f}')

    return model

# Train the model
model = train(model, train_loader, criterion, optimizer, num_epochs)

# Save the retrained model
torch.save(model.state_dict(), 'C:/Users/uib/Desktop/YeaZ/YeaZ-GUI/yeaz/unet/weights/retrained_model_v2.pth')
