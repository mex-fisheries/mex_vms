#!/bin/bash
# Set path
# export PROJECT_PATH="/Users/jcvd/GitHub/mex_vms/data/"

# Upload all local csv files to GCS Bucket
gsutil cp data/clean/*202{3,4,5}*.csv gs://mex_vms/MEX_VMS

# If I need to delete it, this is the command:
#bq rm -f -t mex-fisheries:mex_vms.mex_vms_v_20260409

# Create a partitioned table in Big Query
bq mk --table \
--schema src:STRING,name:STRING,vessel_rnpa:STRING,port:STRING,economic_unit:STRING,datetime:DATETIME,lat:DECIMAL,lon:DECIMAL,speed:FLOAT,course:FLOAT,year:INTEGER,month:INTEGER \
--time_partitioning_field datetime \
--time_partitioning_type YEAR \
--description "Mexican VMS data" \
mex-fisheries:mex_vms.mex_vms_v_20260409

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
mex-fisheries:mex_vms.mex_vms_v_20260409 \
"gs://mex_vms/MEX_VMS/MEX_VMS*.csv"


