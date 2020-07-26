#!/bin/bash


# Install GNU compilers and CMake
apt -y update
apt-get install -y build-essential \
                   gfortran \
                   cmake \
                   tcsh \
                   make \
                   gcc \
                   gfortran \
                   flex \
                   bison \
                   patch \
                   bc \
                   xorg-dev \
                   libbz2-dev \
                   wget

# Install CUDA toolkit
curl -O https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"

apt update -y
apt install -y cuda

mkdir -p /tmp/amber-build
cd /tmp && \
tar -xvf /tmp/AmberDownloads/Amber20.tar.bz2 -C /tmp/amber-build && \
tar -xvf /tmp/AmberDownloads/AmberTools20.tar.bz2 -C /tmp/amber-build

AMBER_PREFIX=/tmp/amber-build
cd /tmp/amber-build/amber20_src/build && \

# Permit builds with CUDA 11.0 #
sed -i 's/10.2/11.0/g' /tmp/amber-build/amber20_src/cmake/CudaConfig.cmake
# Remove sm_30 spec and replace with sm_35, sm_37
sed -i 's/\${SM30FLAGS}/\${SM35FLAGS} \${SM37FLAGS}/g' /tmp/amber-build/amber20_src/cmake/CudaConfig.cmake
cmake $AMBER_PREFIX/amber20_src \
    -DCMAKE_INSTALL_PREFIX=/apps/amber20 \
    -DCOMPILER=GNU  \
    -DMPI=FALSE -DCUDA=TRUE -DINSTALL_TESTS=TRUE \
    -DDOWNLOAD_MINICONDA=TRUE -DMINICONDA_USE_PY3=TRUE \
    2>&1 | tee  cmake.log
make install

# Move amber.sh to profile.d so that user environment variables are automatically loaded on login
cp /apps/amber20/amber.sh /etc/profile.d


