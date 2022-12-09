#!/bin/bash

if [ ! -d '$PT_dir/$PT_name' ]; then
    mkdir $PT_dir/$PT_name 
    cat <<EOF
{"result" : "true"}
EOF
else
    echo 'This environment has already been created. Terraform will update the configuration of this environment'
    cat <<EOF
{"result" : "false"}
EOF
fi

cat > $PT_dir/$PT_name/$PT_name.tfvars << EOF
instance_type = "${PT_instance_type}"
os = "${PT_os}"
name = "${PT_name}"
machines_count = ${PT_machines_count}
region = "${PT_region}"
role = "${PT_role}"
challengepassword = "${PT_challengepassword}"
EOF
