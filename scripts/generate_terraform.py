import json
import os
import sys
import pymustache
import yaml

import file_utils

YAML_KEY_CLUSTERS = "clusters"
YAML_KEY_GLOBAL_CONFIG = "global_config"
YAML_KEY_AMI_TYPE = 'ami'
YAML_KEY_INSTANCE_TYPE = 'instance_type'
YAML_KEY_NUM_INSTANCES = 'num_instances'
YAML_KEY_CLOUD_INIT_PROVIDER = 'cloud_init_provider'
YAML_KEY_REGION = 'region'

INPUT_CLUSTER_YAML_FILE = "cluster_info.yaml"
TEMPLATE_PREFIX = 'sb-subnet-cluster'
CONFIG_DIR = ''
CONFIG_EXTENSION = ".tf"

CLUSTER_NAME = 'cluster_name'
REGION = 'region'
AMI_LIST = 'ami_list'
INSTANCE_TYPE = 'instance_type'
CLOUD_INIT = 'cloud_init'
NUM_INSTANCES = 'num_instances'
CLOUD_INIT_PROVIDER = 'cloud_init_provider'

DEFAULT_AWS_REGION = 'us-west-2'
DEFAULT_AMI_TYPE = 'ami-02f059d9e8bb5d532'
DEFAULT_NUM_INSTANCES = '3'
DEFAULT_INSTANCE_TYPE = 'c5.8xlarge'
DEFAULT_CLOUD_INIT_PROVIDER = 'current'

def generate_per_cluster_terraform(cluster_name, region, ami_list, instance_type_list, num_instances, cloud_init_provider_list):
	template_name = TEMPLATE_PREFIX + CONFIG_EXTENSION
	template_conf_mustache = template_name + ".mustache"
	with open(template_conf_mustache, 'r') as file:
		template_text = file.read()
	print(ami_list)
	context = {CLUSTER_NAME: cluster_name,
                   AMI_LIST: ami_list,
                   INSTANCE_TYPE: instance_type_list,
                   NUM_INSTANCES: num_instances,
                   CLOUD_INIT_PROVIDER: cloud_init_provider_list,
                   }
	output = pymustache.render(template_text, context)
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
        yaml_cluster_data = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        print(exc)

    global_config = yaml_cluster_data[YAML_KEY_GLOBAL_CONFIG]
    if NUM_INSTANCES in global_config:
        num_instances = global_config[NUM_INSTANCES]
    else:
        num_instances = DEFAULT_NUM_INSTANCE

    if YAML_KEY_AMI_TYPE in global_config:
        ami_list = global_config[YAML_KEY_AMI_TYPE]
    else:
        ami_list = [DEFAULT_AMI_TYPE] * num_instances

    if YAML_KEY_INSTANCE_TYPE in global_config:
        instance_type = global_config[YAML_KEY_INSTANCE_TYPE]
    else:
        instance_type = DEFAULT_INSTANCE_TYPE
     
    if YAML_KEY_CLOUD_INIT_PROVIDER in global_config:
        cloud_init_provider = global_configs[YAML_KEY_CLOUD_INIT_PROVIDER]
    else:
        cloud_init_provider = DEFAULT_CLOUD_INIT_PROVIDER

    list_of_clusters= yaml_cluster_data[YAML_KEY_CLUSTERS]
    for cluster_info in list_of_clusters:
        for cluster, cluster_values in cluster_info.items():
            print(cluster, cluster_values)
            if YAML_KEY_REGION in cluster_values:
                region = cluster_values[YAML_KEY_REGION]
            else:
                region = DEFAULT_AWS_REGION

            if YAML_KEY_NUM_INSTANCES in cluster_values:
                num_instances = cluster_values[YAML_KEY_NUM_INSTANCES]

            if YAML_KEY_AMI_TYPE in cluster_values:
                ami_list = cluster_values[YAML_KEY_AMI_TYPE]
                #print(ami_type)

            ami_list = ami_list[:num_instances]


            if YAML_KEY_INSTANCE_TYPE in cluster_values:
                instance_type = cluster_values[YAML_KEY_INSTANCE_TYPE]

            instance_type_list = [instance_type] * num_instances

            if YAML_KEY_CLOUD_INIT_PROVIDER in cluster_values:
                cloud_init_provider = cluster_values[YAML_KEY_CLOUD_INIT_PROVIDER]
            cloud_init_provider_list = [cloud_init_provider] * num_instances
            generate_per_cluster_terraform(cluster, region, ami_list, instance_type_list, num_instances, cloud_init_provider_list)
