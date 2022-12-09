#!/bin/bash

for (( i=0; i< $PT_machines_count; i++ ))
do 
    puppet node purge $PT_name$i.$PT_domain
done
