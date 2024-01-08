Per Beacon Data Specfication
==================

This is the specfication of the data that each beacon may contain, and the data that mPulse stores for each beacon received.

# Structure of Spec

## JSON Lines
The specfication is in JSON documents, each document describing a datum that mPulse may store for any beacon mPulse receives.  
The datum may arrive in the beacon or may be calculated from the data in the beacon.  

## Google Sheet

The JSON docs were compiled into a CSV, uploaded to
[Google Sheet version of spec](https://docs.google.com/spreadsheets/d/1-piYmWI5cVZJk-bxNuSWmVh0ijpNmxd2jJ8EOb8l9ek/edit?usp=sharing).

The procedure to compile JSON to CSV is the section _Query Examples_ below.  

# Querying Spec

The spec can be queried as a JSON lines doc using any JSON query tool.  The examples below use [jq](https://jqlang.github.io/jq/manual/v1.7/). 

## Query Examples

### Find row for S3 "ak.ed" 

```
cat beaconspec.jsonl |\
 jq '.|select(.S3=="ak.ed") | 
 {group:.MetricGroup, field:.Field, s3:.S3}' 
```

### Print whole spec as CSV

Derived from [Stack Overflow answer](https://stackoverflow.com/a/32965227)

This was used to generate [Google Sheet version of spec](https://docs.google.com/spreadsheets/d/1w2B29h6tVf2UmXvmRpp5HtN9OePzemWG-iIQhCLu_ow/edit?usp=sharing).

```
cat beaconspec.jsonl |\
jq -sr '(map(keys) | add | unique) as $cols |
 map(. as $row | $cols | map($row[.])) as $rows |
 $cols, $rows[] | 
 @csv' |\
column -t -s,;
```

### Simplified conversion to CSV

Print as CSV, simplified -- only keys of first object.
Useful for printing results from similar groups 

```
cat beaconspec.jsonl |\
 jq -sr '(.[0] | keys_unsorted) as $keys |
 $keys, map([.[ $keys[] ]])[] |
 @csv'
```

### Find all rows with "Field"

Find all rows with key "Field".
Print as CSV.
Prettify  with tabs.

```
cat beaconspec.jsonl |\
 jq '.|select(.Field) |
 {
    group:.MetricGroup, 
    field:.Field, 
    s3:.S3
 }' |\
 jq -sr '(.[0] | keys_unsorted) as $keys |
 $keys, map([.[ $keys[] ]])[] |
 @csv' |\
column -t -s,;
```


# Source of Spec

* [Metrics 2023](https://collaborate.akamai.com/confluence/pages/viewpage.action?spaceKey=PERFAN&title=Metrics+2023)
   * Edited as [what's in a beacon & metrics2023, tab:metrics2023 stripped](https://docs.google.com/spreadsheets/d/1lXJ0L_zMmC6z07EfW1nKqRSDfiXiOd8wFOQRDu1iLOQ/edit?usp=sharing)
   * Stored in this repo as _src/downloaded/metrics2023.csv_ 
* [What's in a Beacon](https://techdocs.akamai.com/mpulse-boomerang/docs/whats-in-an-mpulse-beacon#whats-in-a-mpulse-beacon)
   * Stored in this repo as _src/downloaded/whats-in-an-mpulse-beacon.html_ 


# Compilation of Spec

The sources contained data in two forms: 
* _Metrics 2023_ was bullet points 
* _What's in a Beacon_ was 32 Markdown tables with varying collumn headers
   * Each row represents a type of datum, e.g. a row for the field "pid" contains values for field name, an S3 key, an Asgard column name, and example, etc.

The compilation normallizes the information from the two source documents by generating a JSON object for each type of datum.  
Each member of the object corresponds to a column name the tables in _What's in a Beacon_, or a description in  _Metrics 2023_.
This all allows the objects to be joined on common member names. 

The compilation procedure and original sources are stored in _src/_ in this repo.

## Compilation Procedure

This requires Bash utillities _jq_ and _mlr_. 

This has been tested only on Mac OS.

In a terminal, change working directory to  _src/_ of this repo, then execute _compile.sh_.

```
pushd src/;
./compile.sh;
popd;
```

The result will be _../beaconspec.jsonl_. 
