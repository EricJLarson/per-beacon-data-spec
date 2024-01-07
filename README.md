Per Beacon Data Specfication
==================

This is the specfication of the data that each beacon may contain, and the data that mPulse stores for each beacon received.


# Structure of Spec

The specfication is in JSON documents, each document describing a datum that mPulse may store for any beacon mPulse receives.  
The datum may arrive in the beacon or may be calculated from the data in the beacon.  


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


