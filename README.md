# Vessel Tracking Data from Mexico's Vessel Monitoring System (VMS)

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

- **vessel_rnpa**: Descriptions to be added
- **name**: Descriptions to be added
- **port**: Descriptions to be added
- **economic_unit**: Descriptions to be added
- **src**: Descriptions to be added
- **seg_id**: Descriptions to be added
- **point_in_seg**: Descriptions to be added
- **datetime**: Descriptions to be added
- **lat**: Descriptions to be added
- **lon**: Descriptions to be added
- **sea**: Descriptions to be added
- **eez**: Descriptions to be added
- **mpa**: Descriptions to be added
- **fishing_region**: Descriptions to be added
- **distance_from_port_m**: Descriptions to be added
- **distance_from_shore_m**: Descriptions to be added
- **depth_m**: Descriptions to be added
- **reported_speed**: Descriptions to be added
- **course**: Descriptions to be added
- **year**: Descriptions to be added
- **month**: Descriptions to be added
- **distance_to_last_m**: Descriptions to be added
- **hours**: Descriptions to be added
- **implied_speed_knots**: Descriptions to be added


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












