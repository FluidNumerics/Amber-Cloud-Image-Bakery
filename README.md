# Amber Cloud Image Bakery
Copyright 2020 Fluid Numerics LLC

This repository contains scripts for creating VM images on Microsoft Azure and Google Cloud with Packer.
The build scripts provided under `scripts/` build Amber with GPU acceleration enabled and without MPI. GPU acceleration requires installation of Nvidia's CUDA-Toolkit. Use of the resulting image requires you agree to the terms and condition in the [CUDA-Toolkit EULA](https://docs.nvidia.com/cuda/eula/index.html)

## Getting Started
1. [Download and install Packer](https://www.packer.io/downloads)
2. Visit the [Amber Project website](https://ambermd.org/GetAmber.php) to download AmberTools20 and Amber20. For Amber20, you will need to purchase a site-license.
3. Once you have downloaded the `AmberTools20.tar.bz` and `Amber20.tar.bz` files from the Amber Project, move these files to the AmberDownloads directory in this repository.

## Create a VM image for Azure

The instructions in this section are based on the Azure documentation ["How to use Packer to create Linux virtual machine images in Azure"](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer).

1. Navigate to the azure subdirectory 
```
cd azure/
```
2. Create a resource group. In this example, the resource group is named "amber". The name you choose here will be passed to the "resource_group" variable in Step 5. 
```
az group create -n amber -l westus
```
3. Create service principal credentials. The output of this command will provide you with the `client_id`, `client_secret`, and `tenant_id` needed when running packer in Step 5.
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"`.
```
4. Obtain your subscription id. This will provide the `subscription_id` needed when running packer in Step 5. 
```
az account show --query "{ subscription_id: id }"
```
5. Run packer using the appropriate variable substitutions. The resulting image name will be called "amber20".
```
packer build -force -var client_id="CLIENT ID" \
                    -var client_secret="CLIENT SECRET"\
                    -var tenant_id="TENANT ID"\
                    -var subscription_id="SUBSCRIPTION ID"\
                    -var resource_group="RESOURCE GROUP"\
                    ./packer.json
```

This build process installs AmberTools20, Amber20, and Amber dependencies (including CUDA Toolkit). Amber is installed under /apps/amber20. Amber binaries are made available to all user's search path upon login through the addition of `amber.sh` to `/etc/profile.d`.

### Testing you Amber VM Image on Azure
You can create an instance with a GPU attached (1x V100 in this case) using the following command :
```
az vm create \
    --resource-group "RESOURCE GROUP" \
    --name "amberVM" \
    --image "amber20" \
    --admin-username azureuser \
    --size "NC6s_v3" \
    --generate-ssh-keys
```

Once you SSH into the instance, navigate to `/apps/amber20` and run `make test.cuda_serial` to verify the installation of Amber20 on this image 
