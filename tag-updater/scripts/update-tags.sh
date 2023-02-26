#!/usr/bin/env bash

BUCKET_NAME=$1
FILE_NAME=$2

bq query --max_rows=100000 --nouse_legacy_sql --format=csv "SELECT tag_name FROM bigquery-public-data.stackoverflow.tags order by tag_name" > $FILE_NAME
echo "Number of tags in generated file:"
wc -l $FILE_NAME

gsutil cp $FILE_NAME gs://$BUCKET_NAME/$FILE_NAME
echo "Uploaded $2 to $1"
echo "Number of tags in uploaded file:"
gsutil cat gs://$BUCKET_NAME/$FILE_NAME | wc -l
