# Getting setup for Google Coral USB Accelerator development  
Kyle D. Ross  
Updated 03 May 2024

## Introduction
This document outlines the steps and tools necessary to begin development with the Google Coral USB Accelerator. The steps are for the USB Accelerator in particular, but may be largely the same (except for hardware and driver installation) for other Coral accelerators.  
The steps here were mostly gleaned from the [coral.ai](http://coral.ai) website, and tweaked (and in some cases modernized) accordingly.
## Requirements

### Hardware

Google Coral USB Accelerator  
The USB cable it came with

### Software

Debian-based Linux distribution (these steps have been validated on Debian 12, Linux Mint Debian Edition 6, and Ubuntu 24.04 LTS)  
JetBrains PyCharm 2024 or later (steps may be slightly different for earlier versions, but the concepts remain the same)  
_In addition, we will retrieve and configure the following in the steps that follow._

PyEnv  
Python 3.9.0 via PyEnv  
Coral TPU driver  
TensorFlow Lite and PyCoral libraries  
Other required packages
## Setup
_Ensure the Coral USB Accelerator is not connected before starting!_
Open a terminal window as a standard user.

### Installing PyEnv
#### Why do we need PyEnv?
PyEnv is used to download other versions of Python than your system version. The PyCoral software has a dependency on Python 3.9 or earlier. Some Linux distributions (such as Linux Mint Debian Edition) have moved to later versions (such as Python 3.11). Because of this, we need to download an earlier version of Python to use in our PyCharm virtual environment. PyEnv can do this.<sup><sup>[\[1\]](#footnote-0)</sup></sup>

#### Retrieving and installing PyEnv
##### Get PyEnv Prerequisites
```commandline
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl
```
##### Install PyEnv
```commandline
curl https://pyenv.run | bash
```
**_After installing PyEnv, there are recommended changes to some bash scripts that will be displayed in the terminal window. Follow the on-screen directions to complete the installation._**

### Install the Coral Edge TPU driver
#### Adding the Google source to your software manager
We must add the Google repository to our software manager in order to install the drivers for the Coral USB Accelerator.
```commandline
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /tmp/google-cloud-key.gpg
```
```commandline
sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/google-cloud.gpg /tmp/google-cloud-key.gpg
```
```commandline
rm /tmp/google-cloud-key.gpg
```
```commandline
echo "deb [arch=amd64] https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
```
```commandline
sudo apt update
```

#### Installing the driver
Standard-speed driver, suitable for ambient temperatures of 35C or less:
```commandline
sudo apt install libedgetpu1-std
```
Or
Maximum-speed driver, suitable for ambient temperatures of 25C or less:
```commandline
sudo apt install libedgetpu1-max
```

Later, if you wish to change from standard to max, or vice-versa, use
###### sudo apt remove
followed by the installed package’s name, then install the driver you wish to change to.  
For example, to switch from the standard to the max driver, use:
```commandline
sudo apt remove libedgetpu1-std
```
```commandline
sudo apt install libedgetpu1-max
```

#### Preparing hardware
Connect the Google Coral USB Accelerator. **If the accelerator was already connected, disconnect it and reconnect it.** This allows Linux to recognize it.

### Other prerequisites
The Pycoral project has Python package dependencies that have further dependencies on some apt packages that must be installed. Install these before loading the project and installing Python packages in requirements.txt.
```commandline
sudo apt install libcairo2-dev pkg-config python3-dev
```
```commandline
sudo apt install python3-gi gobject-introspection libgirepository1.0-dev
```

## Configuring development environment
### Retrieving Python 3.9.0
```commandline
pyenv install 3.9.0
```
This will download the source to Python 3.9.0, compile it, and place it in ~/.pyenv/versions/3.9.0/bin

### Retrieving TensorFlow Lite and PyCoral packages##### Download TensorFlow Lite wheel
#### <https://github.com/google-coral/pycoral/releases/download/v2.0.0/tflite_runtime-2.5.0.post1-cp39-cp39-linux_x86_64.whl>

#### Download PyCoral wheel
#### <https://github.com/google-coral/pycoral/releases/download/v2.0.0/pycoral-2.0.0-cp39-cp39-linux_x86_64.whl>

### Setting up the PyCharm environment
_Remember, if you can’t locate something in PyCharm, use double-tap-shift to bring up universal search._

#### Cloning PyCoral repo
1. Start PyCharm
2. Click **Get from VCS** (if this is your first time)
3. Version control: **Git**
4. Url: **<https://github.com/google-coral/pycoral.git>**
5. Directory: take the default
6. Click **Clone**

#### Installing requirements
There are a number of requirements that are not part of the repo, such as pre-built TensorFlow Lite models and labels. These reside in the ./test_data directory once they are downloaded. To download these (if you don’t already have them):
```commandline
cd ./examples
```
```commandline
./install_requirements.sh
```

#### Configuring Python interpreter
When you have a Python script from the ./examples directory open (such as classify_image.py), PyCharm (at the top of the code window) will complain about an invalid Python interpreter. To fix this:
1. Click **Configure Python interpreter**.
2. Click **Add new interpreter** and choose **Add local interpreter**
3. On left, choose **VirtualEnv Environment**
4. Environment: **New**
5. Location: **~/PycharmProjects/pycoral/.venv (**This is where PyEnv downloaded the Python version earlier.)
6. Base interpreter: **~/.pyenv/versions/3.9.0/bin/python3**
7. Click **OK**

#### Installing TensorFlow Lite and PyCoral software into the virtual environment
_Make sure the Python 3.9 (PyCoral) virtual environment is the current one in PyCharm. When we install wheels below, they will go into our virtual environment, not at the system level. That’s where we want them, because they require Python 3.10 or earlier, and our system-level Python interpreter is likely much later._

1. Go to **Python packages**
2. Click **Add Package**
3. Choose **From Disk**
4. Choose the **tflite_runtime** wheel that you downloaded earlier, and install it
5. Click **Add Package**, again
6. Choose **From Disk**
7. Choose the **pycoral** wheel that you downloaded earlier, and install it

#### Package requirements
You will likely get warnings at the top about other package requirements (such as beautifulsoup4, pygobject, and setuptools). Install these by clicking the **Install requirements** link provided in the IDE.

#### Fixing PyCoral issue
The fact that the PyCoral namespace is the same as a PyCoral directory causes runtime errors in edgetpu.py. To fix this, you can do one of the following:  
1. Delete pycoral/\__init.py__
2. Edit setup.py, change line that references it to just ‘2.0.0’

or

1. In project, click pycoral namespace to choose it
2. Then right-click and choose Refactor/Rename
3. Name: pycoral_ (or anything other than pycoral)
4. Uncheck search for references
5. Uncheck search comments and strings
6. Scope: Selected directory

## Debugging
#### Configuring debug configuration
1. At the top gutter, choose **Edit configurations**
2. Click **Add new run configuration**
3. Choose **Python**
4. Name: **classify_image**
5. script: **examples/classify_image.py**
6. Script parameters:  
**\--model test_data/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite --labels test_data/inat_bird_labels.txt --input test_data/parrot.jpg**

#### Running
1. Choose the **classify_image** debug configuration
2. Click **Debug.**

You should see this output in the PyCharm console:

###### /home/yourname/.pyenv/versions/3.9.0/bin/python3 -X pycache_prefix=/home/yourname/.cache/JetBrains/PyCharm2024.1/cpython-cache /home/yourname/.local/share/JetBrains/Toolbox/apps/pycharm-professional/plugins/python/helpers/pydev/pydevd.py --multiprocess --qt-support=auto --client 127.0.0.1 --port 42513 --file /home/yourname/PycharmProjects/pycoral/examples/classify_image.py --model test_data/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite --labels test_data/inat_bird_labels.txt --input test_data/parrot.jpg
###### Connected to pydev debugger (build 241.14494.241)
###### \----INFERENCE TIME----
###### Note: The first inference on Edge TPU is slow because it includes loading the model into Edge TPU memory
###### 13.3ms
###### 4.6ms
###### 4.5ms
###### 4.6ms
###### 4.7ms
###### \-------RESULTS--------
###### Ara macao (Scarlet Macaw): 0.75781
######
###### Process finished with exit code 0

------------------

1. The directions for this came from <https://realpython.com/intro-to-pyenv> [↑](#footnote-ref-0)

2. These steps to install the key to the keyring are newer directions than on the official Google site for the accelerator. Their method using apt-key is deprecated. [↑](#footnote-ref-1)

3. If installing from the backed-up packages, use sudo dpkg -i /path/to/libedgetpu1-std.deb [↑](#footnote-ref-2)
