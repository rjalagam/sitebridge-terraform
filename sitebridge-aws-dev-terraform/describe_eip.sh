#!/bin/bash

# Script does two different functionalities:
# 1) When the set_tags is enabled, script gets the eip ID based on
#    Public IP and adds tags to it (Hostname, public IP, private IP)
# 2) When the set_tags is not passed, script gets all the public IP and private IP
#     info based on hostname tag and return to the caller of the script in a ","
#     separated values in the json format.


private_ip_tag_name="PrivateIp"
public_ip_tag_name="PublicIp"
null="Null"

parse_ips()
{
    fields=$#

    if [ $fields -gt 4 -o $fields -eq 0 ]; then
        echo $null
        return
    fi

    private_ip=""
    public_ip=""

    i=0
    shopt -s nocasematch

    while [ $i -lt $fields ]; do
        # remove trailing and leading \"
        tag_name=$1
        tag_name=${tag_name:1:${#tag_name}-2}
        if [[ $private_ip_tag_name == $tag_name ]]; then
            shift
            i=$(( $i + 1 ))
            private_ip=$1
            private_ip=${private_ip:1:${#private_ip}-2}
        elif [[ $public_ip_tag_name == $tag_name ]]; then
            shift
            i=$(( $i + 1 ))
            public_ip=$1
            public_ip=${public_ip:1:${#public_ip}-2}
        fi

        shift
        i=$(( $i + 1 ))
    done

    shopt -u nocasematch
    echo "$public_ip $private_ip"
}

get_tagged_ips_from_aws()
{
    array_count=${#public_ips_array[@]}
    aws_tagged_public_ips=""
    aws_tagged_private_ips=""
    declare -a missed_hosts

    # If IPs provided return them
    if [[ $public_ips != null && $array_count == $count ]]; then
        jq -n --arg public_ip "$public_ip" --arg private_ip "$private_ip" '{"private_ip":$private_ip, "public_ip":$public_ip}'
        exit 0
    fi

    # Loop through the instance count and get the list of eips attached based on the filter name
    for (( i=1; i<=$((count+0)); i++ )); do
        host_name="$prefix_name-$i$suffix_name"

        desc_addresses_cmd="aws ec2 describe-addresses --region $region"
        desc_addresses_cmd+=" --filters Name=tag:Name,Values=$host_name --output json | jq '.Addresses[] | "
        desc_addresses_cmd+="(.Tags[] | select(.Key==\"$public_ip_tag_name\",.Key==\"$private_ip_tag_name\")|.Key,.Value)'"
        desc_addresses_cmd_output=$(eval $desc_addresses_cmd)

        retval=`parse_ips $desc_addresses_cmd_output`
        set $retval

        if [ $1 != $null ]; then
            public_ip=$1
            private_ip=$2

            aws_tagged_public_ips="${aws_tagged_public_ips},${public_ip}"
            aws_tagged_private_ips="${aws_tagged_private_ips},${private_ip}"
        else
            # adding missed host_name so that these will be allocated at the end of the loop
            missed_hosts+=($host_name)
        fi
    done

    if [ ${#missed_hosts[@]} -ne 0 ]; then
        desc_addresses_cmd="aws ec2 describe-addresses --region $region"
        desc_addresses_cmd+=" --query 'Addresses[?AssociationId==\"null\"]' --output json |"
        desc_addresses_cmd+=" jq '.[] | .PublicIp'"
        desc_addresses_cmd_output=$(eval $desc_addresses_cmd)
        IFS=$' \r\n'
        eip_available_array=( $desc_addresses_cmd_output )

        for index in "${!missed_hosts[@]}"; do
            # Get a new public IP for the missed hosts
            # Trim the trailing and leading \"
            aws_tagged_public_ips="${aws_tagged_public_ips},${eip_available_array[$index]:1:${#eip_available_array[$index]}-2}"
        done
    fi
    
    # Remove the starting ,
    aws_tagged_public_ips="${aws_tagged_public_ips:1}"
    aws_tagged_private_ips="${aws_tagged_private_ips:1}"

    jq -n --arg public_ips "$aws_tagged_public_ips" --arg private_ips "$aws_tagged_private_ips" '{"private_ips":$private_ips, "public_ips":$public_ips}'
    exit 0
}

set_tags_eip()
{
    IFS=","
    public_ips_array=( $public_ips )
    private_ips_array=( $private_ips )
    array_count=${#public_ips_array[@]}

    for (( i=1; i<=$((count+0)); i++ )); do
        host_name="$prefix_name-$i$suffix_name"
        desc_addresses_cmd="aws ec2 describe-addresses --region $region"
        desc_addresses_cmd+=" --public-ips ${public_ips_array[$((i - 1))]}"
        desc_addresses_cmd_output=$(eval $desc_addresses_cmd | jq '.Addresses[] | (.PublicIp,.PrivateIpAddress,.AllocationId)')
        # Replace \n with space
        desc_addresses_cmd_output=${desc_addresses_cmd_output//$'\n'/ }
        # Remove \"
        desc_addresses_cmd_output=${desc_addresses_cmd_output//$'\"'}
        IFS=" "
        # array has 0: public-ip, 1: private-ip, 2: eip-alloc-id
        eip_array=( $desc_addresses_cmd_output )

        # For first run, private ip will be null, replace with input
        if [[ ${eip_array[1]} != null ]]; then
            private_ip=(${eip_array[1]})
        else
            private_ip=(${private_ips_array[$((i - 1))]})
        fi

        # create tag for the resource eip
        create_tag_cmd="aws ec2 create-tags --region $region"
        create_tag_cmd+=" --resources ${eip_array[2]} --tags Key=$public_ip_tag_name,Value=${eip_array[0]} "
        create_tag_cmd+="Key=$private_ip_tag_name,Value=$private_ip "
        create_tag_cmd+="Key=Name,Value=$host_name"
        eval $create_tag_cmd
    done

    jq -n --arg public_ips "${public_ips_array[*]}" --arg private_ips "${private_ips_array[*]}" '{"private_ips":$private_ips, "public_ips":$public_ips}' | sed -e 's/  */ /g' -e 's/^ *\(.*\) *$/\1/'
    exit 0
}

function check_deps() {
  test -f $(which jq) || error_exit "jq command not detected in path, please install it"
}

# Extract the arguments from the shell variables.
# jq will ensure the values are properly quoted and escaped for consumption

# EIP tagging is of the form
# "PrivateIp": "10.0.10.149"
# "PublicIp": "54.69.226.18"
# Input parameters:
# count - No. of instances that should have been tagged with a eip
# public_ips - , separated string of public IPs
# private_ips - , separated string of private IPs
# prefix_name - Prefix of the hostname
# suffix_name - Suffix of the hostname
# region - region of the public cloud account
# set_tags - (Optional) used to differentiate the script usage to either get or set eip tags

# example of a json input:
# {"public_ips":"54.69.226.18","private_ips":"10.0.10.170,10.0.10.149","count":"12","prefix_name":"ops0-stage1customer1","suffix_name":"-usw2.awssb.sfdcsb.net-eip","region":"us-west-2","set_tags":"1"}

# example of json output:
# {"public_ips":"54.69.226.18,3.23.45.125","private_ips":"10.0.10.170,10.0.10.149"}


# example local usage
# echo '{"public_ips":"54.69.226.18","private_ips":"10.0.10.170,10.0.10.149","count":"12","prefix_name":"ops0-stage1customer1","suffix_name":"-usw2.awssb.sfdcsb.net-eip","region":"us-west-2","set_tags":"1"}' | sh ~/tag_eip.sh



set_tags=""
check_deps && \
eval "$(jq -r '@sh "count=\(.count) public_ips=\(.public_ips) private_ips=\(.private_ips) prefix_name=\(.prefix_name) suffix_name=\(.suffix_name) region=\(.region) set_tags=\(.set_tags)"')"

if [ ${set_tags} = "1" ]; then
    set_tags_eip
else
    get_tagged_ips_from_aws
fi



