#!/bin/bash
packer build -force -var project_id="badger-974810" \
                    -var source_image="fluid-slurm-gcp-compute-centos-rc2-4-1-d"\
                    -var source_image_project_id="fluid-cluster-ops"\
                    ./packer.json
