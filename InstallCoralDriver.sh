# This script assumes you have already installed PyEnv as part of the computer setup.

# Add Google repository for the Coral TPU driver
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /tmp/google-cloud-key.gpg
sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/google-cloud.gpg /tmp/google-cloud-key.gpg
rm /tmp/google-cloud-key.gpg
echo "deb [arch=amd64] https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
sudo apt-get update

# Install the Coral TPU driver
sudo apt install libedgetpu1-max
# or libedgetpu1-std for the slower, cooler version

# Install PyCoral prerequisites
sudo apt install libcairo2-dev pkg-config python3-dev
sudo apt install python3-gi gobject-introspection libgirepository1.0-dev

# Get Python 3.9, because PyCoral requires it
pyenv install 3.9.0

# download the wheels to use in the Python virtual environment
wget https://github.com/google-coral/pycoral/releases/download/v2.0.0/tflite_runtime-2.5.0.post1-cp39-cp39-linux_x86_64.whl
wget https://github.com/google-coral/pycoral/releases/download/v2.0.0/pycoral-2.0.0-cp39-cp39-linux_x86_64.whl
