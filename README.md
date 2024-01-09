Per Beacon Data Specfication
==================

This is the specfication of the data that each beacon may contain, and the data that mPulse stores for each beacon received.

1. [Structure of Spec ](#StructureofSpec)
   1. [JSON Lines ](#JSONLines)
   1. [Google Sheet ](#GoogleSheet)
   1. [Spec Formats Relationships ](#SpecFormatsRelationships)
1. [Querying Spec ](#QueryingSpec)
1. [Query Examples ](#QueryExamples)
   1. [JQuery Examples ](#JQueryExamples)
      1. [Find row for S3 ak.ed ](#FindrowforS3ak)
      1. [Find row for S3 ak.ed and get MetricGroup and Field](#FindrowforS3ak)
      1. [Find all rows with key Field](#Findallrowswithkey)
      1. [List the keys for a member of group Akamai ](#Listthekeysfora)
      1. [List all keys for all rows](#Listallkeysforall)
      1. [Count all rows](#Countallrows0)
      1. [List all keys for all members of group Akamai ](#Listallkeysforall)
      1. [List all Query String Param values for all members of group Akamai ](#ListallQueryStringParam)
      1. [List all Query String Param values for all members of group Akamai ](#ListallQueryStringParam1)
      1. [Count all Query String Param values ](#CountallQueryStringParam)
      1. [Count all rows that have no Query String Param value](#Countallrowsthathave)
      1. [Print whole spec as CSV](#PrintwholespecasCSV)
   1. [Query Convenience Functions](#QueryConenvienceFunctions)
1. [Source of Spec ](#SourceofSpec)
1. [Compilation of Spec ](#CompilationofSpec)
   1. [Compilation Procedure ](#CompilationProcedure)

# Structure of Spec <a name="StructureofSpec"></a>

## JSON Lines <a name="JSONLines"></a>
The specfication is in JSON documents, each document describing a datum that mPulse may store for any beacon mPulse receives.  
The datum may arrive in the beacon or may be calculated from the data in the beacon.  

## Google Sheet <a name="GoogleSheet"></a>

The JSON docs were compiled into a CSV, uploaded to
[Google Sheet version of spec](https://docs.google.com/spreadsheets/d/1-piYmWI5cVZJk-bxNuSWmVh0ijpNmxd2jJ8EOb8l9ek/edit?usp=sharing).

The procedure to compile JSON to CSV is the section _Query Examples_ below.  

## Spec Formats Relationships <a name="SpecFormatsRelationships"></a>

This is the dataflow between the spec formats, originating with the HTML pages, which are then 
compiled by _compile.sh_, which generates JSON that can be converted to CSV.

```
                                                             ┌────────────┐   ┌──────┐
                                                             │Markdwn tabl├──►│HTML  │
┌─────────────────┐                                          ├────────────┤   └──────┘
│WhatsInBeacon.htm│        ┌───────────┐   ┌────┐    ┌───┐   │SQL         │
├─────────────────┼──────► │compile.sh ├──►│json├───►│csv├──►├────────────┤                
├─────────────────┤        └───────────┘   └────┘    └───┘   │spreadsheet │
│metrics2023.html │                                          └────────────┘
└─────────────────┘
```


# Querying Spec <a name="QueryingSpec"></a>

The spec can be queried as a JSON doc using any JSON query tool.  The examples below use [jq](https://jqlang.github.io/jq/manual/v1.7/). 

# Query Examples <a name="QueryExamples"></a>

## JQuery Examples <a name="JQueryExamples"></a>

Each query below is a commandline arguments for _jq_, executed at the Bash prompt.
For example, to run the query `.[] |select(.S3=="ak.ed")`, do the following:

```
cat beaconspec.json |\
jq '
    .[] | select(.S3=="ak.ed")
'
```

### Find row for S3 ak.ed <a name="FindrowforS3ak"></a>

```
    .[] | select(.S3=="ak.ed") 
```

### Find row for S3 ak.ed and get MetricGroup and Field<a name="FindrowforS3ak"></a>

```
    .[] | select(.S3=="ak.ed") | 
    {group:.MetricGroup, field:.Field, s3:.S3}
``` 

### Find all rows with key Field<a name="Findallrowswithkey"></a>

```
    .[] | select(.Field) 
```

### List the keys for a member of group Akamai <a name="Listthekeysfora"></a>

```
    map(
        select(.MetricGroup=="Akamai")
    )[0] |
    keys
``` 

### List all keys for all rows<a name="Listallkeysforall"></a>

```
    map(keys) |
    add |
    unique
```

### Count all rows <a name="Countallrows0"></a>

```
    length
```

### List all keys for all members of group Akamai <a name="Listallkeysforall"></a>

```
    map(
        select(.MetricGroup=="Akamai")
    ) |
    map(keys) |
    add |
    unique
```


### List all Query String Param values for all members of group Akamai <a name="ListallQueryStringParam"></a>

```
    map(
        select(.MetricGroup=="Akamai")
    ) |
    .["Query String Param"]) |
    unique
```

### List all Query String Param values for all members of group Akamai <a name="ListallQueryStringParam1"></a>

```
    map(
      select(.MetricGroup=="Akamai") |
      .["Query String Param"]
    ) |
    unique |
    .[]
```


### Count all Query String Param values <a name="CountallQueryStringParam"></a>

```
    map(
      .["Query String Param"]
    ) |
    unique | 
    length
```

### Count all rows that have no Query String Param value<a name="Countallrowsthathave"></a>

```
    map(
        select(.["Query String Param"] == null)
    ) |
    length
```

### Print whole spec as CSV<a name="PrintwholespecasCSV"></a>

Derived from [Stack Overflow answer](https://stackoverflow.com/a/32965227)

This was used to generate [Google Sheet version of spec](https://docs.google.com/spreadsheets/d/1w2B29h6tVf2UmXvmRpp5HtN9OePzemWG-iIQhCLu_ow/edit?usp=sharing).

```
    (map(keys) |
        add | 
        unique
    ) as $cols |
    map(. as $row |
         $cols |
         map(
            $row[.]
        )
    ) as $rows |
    $cols, $rows[] |
    @csv
```

## Query Convenience Functions <a name="QueryConenvienceFunctions"></a>

These are Bash function definitions that take a JQ query string argument, such as those in [JQuery Examples ](#JQueryExamples).
To use, either paste these in the shell or add to _~/.bash\_profile_.

```
spec () {
  curl -s 'https://raw.githubusercontent.com/EricJLarson/per-beacon-data-spec/master/beaconspec.json' |\
  jq "${1}";
}
```

```
csv () {
 jq -sr '
    (map(keys) |
        add |
        unique
    ) as $cols |
    map(. as $row |
         $cols |
         map(
            $row[.]
        )
    ) as $rows |
    $cols, $rows[] |
    @csv';
}
```

```
specpretty () {
  spec "${1}" | csv | column -t -s,;
}
```

To use, pass a JQ query as a command line argument to either `spec` or `speccvs`, e.g.

```
specpretty '
    .[] |select(.S3=="ak.ed") |
    {group:.MetricGroup, field:.Field, s3:.S3}
'
```

# Source of Spec <a name="SourceofSpec"></a>

* [Metrics 2023](https://collaborate.akamai.com/confluence/pages/viewpage.action?spaceKey=PERFAN&title=Metrics+2023)
   * Edited as [what's in a beacon & metrics2023, tab:metrics2023 stripped](https://docs.google.com/spreadsheets/d/1lXJ0L_zMmC6z07EfW1nKqRSDfiXiOd8wFOQRDu1iLOQ/edit?usp=sharing)
   * Stored in this repo as _src/downloaded/metrics2023.csv_ 
* [What's in a Beacon](https://techdocs.akamai.com/mpulse-boomerang/docs/whats-in-an-mpulse-beacon#whats-in-a-mpulse-beacon)
   * Stored in this repo as _src/downloaded/whats-in-an-mpulse-beacon.html_ 


# Compilation of Spec <a name="CompilationofSpec"></a>

The sources contained data in two forms: 
* _Metrics 2023_ was bullet points 
* _What's in a Beacon_ was 32 Markdown tables with varying collumn headers
   * Each row represents a type of datum, e.g. a row for the field "pid" contains values for field name, an S3 key, an Asgard column name, and example, etc.

The compilation normallizes the information from the two source documents by generating a JSON object for each type of datum.  
Each member of the object corresponds to a column name the tables in _What's in a Beacon_, or a description in  _Metrics 2023_.
This all allows the objects to be joined on common member names. 

The compilation procedure and original sources are stored in _src/_ in this repo.

## Compilation Procedure <a name="CompilationProcedure"></a>

This requires Bash utillities _jq_ and _mlr_. 

This has been tested only on Mac OS.

In a terminal, change working directory to  _src/_ of this repo, then execute _compile.sh_.

```
pushd src/;
./compile.sh;
popd;
```

The result will be _../beaconspec.json_. 
