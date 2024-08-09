import torch

class TimeSeriesDataset(torch.utils.data.Dataset):
    def __init__(self, data, num_steps, last_price_index):
        self.data = data
        self.num_steps = num_steps
        self.last_price_index = last_price_index
        self.num_features = data.shape[-1] - 1  # Exclude the last_price column

    def __len__(self):
        return len(self.data) - self.num_steps

    def __getitem__(self, idx):
        x = torch.tensor(self.data[idx:idx + self.num_steps, :, 1:], dtype=torch.float32)  # Exclude the last_price column (column 0)
        y = torch.tensor(self.data[idx:idx + self.num_steps, :, self.last_price_index], dtype=torch.float32)
        return x, y