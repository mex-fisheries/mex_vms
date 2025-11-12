# Vessel Tracking Data from Mexico's Vessel Monitoring System (VMS)

[![DOI](https://zenodo.org/badge/1046400826.svg)](https://doi.org/10.5281/zenodo.17592443)

## About

The raw data come from [Datos abiertos](https://datos.gob.mx/busca/dataset/localizacion-y-monitoreo-satelital-de-embarcaciones-pesqueras).
These data are collected and curated by Mexico's [`SISMEP`](https://www.gob.mx/conapesca/acciones-y-programas/sistema-de-monitoreo-satelital-de-embarcaciones-pesqueras)
(Sistema de Monitoreo Satelital de Embarcaciones Pesqueras). They reports the
identity, coordinates, and timestamp of Mexican fishing vessels that comply with
[Mexico's fisheries regulation](https://www.dof.gob.mx/nota_detalle.php?codigo=5399371&fecha=03/07/2015#gsc.tab=0) on the matter.
Simply put, vessels larger than 10.5m in length overall, with an on-board engine > 80hp, and with a roof must carry a transponder.

The data available require some wrangling to get them into a usable format. This
repository attempts to do that. It then makes the data available for others to use.

## Clean data vailability, with two different levels of processing

### L1 data (not recommended)

Monthly `.csv` files are available in the [`data/clean/`  folder](data/clean/)
here and in a Google Cloud Bucket at at: `gs://mex_vms/MEX_VMS/*`. Files follow 
a standard file naming pattern of `MEX_VMS_yyyy_mm.csv`, where `yyyy` indicate\
the year and `mm` the month.

### L1 and L2 data (recommended)

On Google BigQuery at `mex-fisheries.mex_vms.mex_vms_latest` for the same data 
as in the Google Cloud Bucket, some with level of processing with added features
(segmentation, spatial covariates) at `mex-fisheries.mex_vms.mex_vms_latest`. Both
are partitioned by year.

Note that BigQuery data use a standard versioning system every time the tables undergo a major change, like fixing bugs, adding data, or modifying the underlying cleaning code. Past versions include:

- `mex-fisheries.mex_vms.mex_vms_processed_v_20250623` <-- This is the current version, viewed by `mex-fisheries.mex_vms.mex_vms_procssed_latest`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20250613`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20250319`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20240615`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20240515`

Available columns are:

- **vessel_rnpa**: Character. Vessel RNPA - Unique 8-digit identifier for the vessel.
- **name**: Character. Vessel name - Name of the vessel, as reported in the VMS data.
- **port**: Character. Port - Port of registration of the vessel, as reported in the VMS data.
- **economic_unit**: Character. Economic unit RNPA - Unique 8-digit identifier for the economic unit associated with the vessel, as per the latest available vessel registry.
- **src**: Character. Source file - Name of the source file from which the data point was extracted.
- **seg_id**: Integer. Segment ID - Identifier for the segment to which the data point belongs, based on speed and time thresholds.
- **point_in_seg**: Integer. Point in segment - Position of the data point within its segment.
- **datetime**: Timestamp. Date and time - Timestamp of the data point, in UTC.
- **lat**: Numeric. Latitude - Latitude of the vessel at the time of the data point.
- **lon**: Numeric. Longitude - Longitude of the vessel at the time of the data point.
- **sea**: Character. Sea - Name of the sea where the vessel was located at the time of the data point.
- **eez**: Character. Exclusive Economic Zone - Name of the EEZ where the vessel was located at the time of the data point.
- **mpa**: Character. Marine Protected Area - Name of the MPA where the vessel was located at the time of the data point, if applicable.
- **fishing_region**: Character. Fishing region - Name of the fishing region where the vessel was located at the time of the data point.
- **distance_from_port_m**: Numeric. Distance from port (meters) - Distance of the vessel from the nearest port at the time of the data point.
- **distance_from_shore_m**: Numeric. Distance from shore (meters) - Distance of the vessel from the nearest shore at the time of the data point.
- **depth_m**: Numeric. Depth (meters) - Depth of the water at the vessel's location at the time of the data point.
- **reported_speed**: Numeric. Reported speed (knots) - Speed of the vessel as reported in the VMS data.
- **course**: Numeric. Course (degrees) - Course of the vessel as reported in the VMS data.
- **year**: Numeric. Year - Year of the data point.
- **month**: Numeric. Month - Month of the data point.
- **distance_to_last_m**: Numeric. Distance to last point (meters) - Distance from the previous data point in the segment.
- **hours**: Numeric. Hours - Time difference from the previous data point in the segment, in hours.
- **implied_speed_knots**: Numeric. Implied speed (knots) - Speed calculated based on the distance to the last point and the time difference.


## Accessing the data via R

You should be able to access the entire date set using BigQuery (SQL) or R.
The following code snippet shows how you might connect to the database:

```r
# Load packages ----------------------------------------------------------------
pacman::p_load(
  bigrquery,
  DBI,
  tidyverse
)

bq_auth("juancarlos.villader@gmail.com") # You'll need to authenticate using your own email

# Establish a connection -------------------------------------------------------
con <- dbConnect(bigquery(),
                 project = "mex-fisheries", # This is the name of the project, leave it as-is
                 dataset = "mex_vms",       # This is the name of the dataset, leave it as-is
                 use_legacy_sql = FALSE, 
                 allowLargeResults = TRUE)
  
mex_vms <- tbl(con, "mex_vms_processed_latest") # This object now contains a tbl that points at mex_vms_processed_v_20250319

# That's it, you can now use dplyr verbs to work with the data.
# For example, get latitude, longitude, and vessel id for the first 1000 rows in the data
mex_vms |> 
    select(vessel_rnpa, lat, lon) |> 
    head(1000) |> 
    collect()
```

## Known issues

### Raw data issues
- Multiple files (`01-10-FEB-2018.xlsx`, `11-20-FEB-2018.xlsx`, and all August - Dec, 2022) are provided as excel files, instead of csv files.
- Additionally, file `12. DICIEMBRE/12 - 01 -15 DIC  2022.xlsx` is corrupt. (still corrupt as of March 19, 2025)
- Three files (`21-31-AGO-2014.csv`, `11-20-ENE-2018.csv`, `16-31 OCT 2020.csv`) have either corrupted or incorrect datetime values in the `Fecha` field.

### Clean data issues
- For data from `21-31-AGO-2014.csv`, `11-20-ENE-2018.csv`, `16-31 OCT 2020.csv`, there is no datetime available. There is, however, year and month data available, extracted from the file names (included as an `src` variable).
- Vessel names have not been normalized yet. But, the vessel names in the vessel registry are already normalized, and matching on `vessel_rnpa` is recommended instead.

## Other resources


Regulation governing the use of VMS on boats: Norma Oficial Mexicana
NOM-062-PESC-2007, Para la utilización del sistema de localización y monitoreo
satelital de embarcaciones pesqueras, SECRETARIA DE AGRICULTURA, GANADERIA,
DESARROLLO RURAL, PESCA Y ALIMENTACION, Estados Unidos Mexicanos; DOF, 24 de
abril 2008, [citado el 21-04-2021]; Disponible en versión HTML en internet:
[http://sidof.segob.gob.mx/notas/5033406](http://sidof.segob.gob.mx/notas/5033406)












