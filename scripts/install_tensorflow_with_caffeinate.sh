#!/bin/bash

# Prevent sleep
caffeinate &

# Store the process ID of caffeinate
CAFFEINATE_PID=$!

# Initialize conda for the current shell session
conda init bash

# Source the Bash profile to apply changes
source ~/.bash_profile

# Function to retry conda install
retry_conda_install() {
    local package=$1
    local retries=5
    local count=0
    until [ $count -ge $retries ]
    do
        conda install -c conda-forge $package -y && break
        count=$((count+1))
        echo "Retrying conda install for $package ($count/$retries)..."
        sleep 2
    done

    if [ $count -ge $retries ]; then
        echo "Failed to install $package after $retries attempts."
        exit 1
    fi
}

# Check if the environment exists
if conda env list | grep -q "tf_m1"; then
    echo "Environment tf_m1 already exists. Skipping creation."
else
    # Create the Conda environment from environment.yml if it doesn't exist
    conda env create -f environment.yml
fi

# Activate the Conda environment
conda activate tf_m1

# Install Jupyter Notebook with retry logic
retry_conda_install "jupyter"

# Create requirements.txt if it doesn't exist
if [ ! -f requirements.txt ]; then
    cat <<EOL > requirements.txt
pandas
matplotlib
scikit-learn
# Add more libraries here
EOL
fi

# Install packages from requirements.txt
while IFS= read -r package || [[ -n "$package" ]]; do
    retry_conda_install "$package"
done < requirements.txt

# Start Jupyter Notebook
/Users/michaelzhou/miniforge3/envs/tf_m1/bin/jupyter notebook

# Kill caffeinate process
kill $CAFFEINATE_PID