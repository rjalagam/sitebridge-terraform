import json
import os
import sys
import pystache
import yaml

import file_utils

INPUT_CLUSTER_YAML_FILE = "cluster_info.yaml"
TEMPLATE_PREFIX = 'sb-subnet-cluster'
CONFIG_DIR = ''
CONFIG_EXTENSION = ".tf"

CLUSTER_NAME = 'cluster_name'
REGION = 'region'
AMI_TYPE = 'ami_type'
INSTANCE_TYPE = 'instance_type'
CLOUD_INIT = 'cloud_init'
NUM_INSTANCES = 'num_instances'
CLOUD_INIT_PROVIDER = 'cloud_init_provider'

DEFAULT_AWS_REGION = 'us-west-2'
DEFAULT_AMI_TYPE = 'ami-02f059d9e8bb5d532'
DEFAULT_NUM_INSTANCES = '3'
DEFAULT_INSTANCE_TYPE = 'c5.8xlarge'
DEFAULT_CLOUD_INIT_PROVIDER = 'current'

def generate_per_cluster_terraform(cluster_name, region, ami_type, instance_type, num_instances, cloud_init_provider):
	template_name = TEMPLATE_PREFIX + CONFIG_EXTENSION
	template_conf_mustache = template_name + ".mustache"
	context = {CLUSTER_NAME: cluster_name,
                   AMI_TYPE: ami_type,
                   INSTANCE_TYPE: instance_type,
                   NUM_INSTANCES: num_instances,
                   CLOUD_INIT_PROVIDER: cloud_init_provider,
                   }
	template = pystache.TemplateSpec()
	template.template_name = template_name
	renderer = pystache.Renderer()
	output = renderer.render(template, context)
	cfg_dir_path = os.path.join(os.getcwd(), region)
	terraform_filename = TEMPLATE_PREFIX + "-" + cluster_name + CONFIG_EXTENSION
	cfg_file_path = os.path.join(cfg_dir_path, terraform_filename)
	save_terraform_config(cfg_file_path, output)

def save_terraform_config(cfg_file_path, cfg_data):
	file_utils.create_dir(os.path.dirname(cfg_file_path))
	with open(cfg_file_path, 'w') as fh:
		fh.write(cfg_data)

with open(INPUT_CLUSTER_YAML_FILE, 'r') as stream:
    list_of_clusters = []
    try:
        list_of_clusters = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

    for cluster_info in list_of_clusters:
        for cluster, cluster_values in cluster_info.items():
            print(cluster, cluster_values)
            if REGION in cluster_values:
                region = cluster_values[REGION]
            else:
                region = DEFAULT_AWS_REGION

            if AMI_TYPE in cluster_values:
                ami_type = cluster_values[AMI_TYPE]
            else:
                ami_type = DEFAULT_AMI_TYPE

            if NUM_INSTANCES in cluster_values:
                num_instances = cluster_values[NUM_INSTANCES]
            else:
                num_instances = DEFAULT_NUM_INSTANCE

            if INSTANCE_TYPE in cluster_values:
                instance_type = cluster_values[INSTANCE_TYPE]
            else:
                instance_type = DEFAULT_INSTANCE_TYPE

            if CLOUD_INIT_PROVIDER in cluster_values:
                cloud_init_provider = cluster_values[CLOUD_INIT_PROVIDER]
            else:
                cloud_init_provider = DEFAULT_CLOUD_INIT_PROVIDER
            generate_per_cluster_terraform(cluster, region, ami_type, instance_type, num_instances, cloud_init_provider)
