#!/bin/bash
bq query --use_legacy_sql=false < scripts/pipeline_1_segmenter.sql
bq query --use_legacy_sql=false < scripts/pipeline_2_segment_info.sql

