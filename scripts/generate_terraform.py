import json
import os
import sys

import pystache

import file_utils

TEMPLATE_PREFIX = 'sb-subnet-cluster'
CONFIG_DIR = ''
CONFIG_EXTENSION = ".tf"

CLUSTER_NAME = 'cluster_name'

AMI_TYPE = 'ami_type'
INSTANCE_TYPE = 'instance_type'
CLOUD_INIT = 'cloud_init'
NUM_INSTANCES = 'num_instances'

KMS_KEY_NAME = 'sitebridge/ipsec'
KMS_KEY_ID = 'c578f283-a45b-417a-b565-b252d32ff2f1'

DEFAULT_AWS_REGION = 'us-west-2'


def generate_customer_tunnel(region, cluster_name, ami_type, instance_type, num_instances):
	template_name = TEMPLATE_PREFIX + CONFIG_EXTENSION
	template_conf_mustache = template_name + ".mustache"
	context = {CLUSTER_NAME: cluster_name,
                   AMI_TYPE: ami_type,
                   INSTANCE_TYPE: instance_type,
                   NUM_INSTANCES: num_instances
                   }
	template = pystache.TemplateSpec()
	template.template_name = template_name
	#renderer = pystache.Renderer(search_dirs=artifact_location, escape=lambda u: u, missing_tags='strict')
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

generate_customer_tunnel(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
