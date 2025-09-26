## Mexican VMS data (2007 - 2025 [partial])

### Raw sources

- [Datos abiertos](https://datos.gob.mx/busca/dataset/localizacion-y-monitoreo-satelital-de-embarcaciones-pesqueras): These data are collected and curated by Mexico's [`SISMEP`](https://www.gob.mx/conapesca/acciones-y-programas/sistema-de-monitoreo-satelital-de-embarcaciones-pesqueras) (Sistema de Monitoreo Satelital de Embarcaciones Pesqueras). It reports the geolocation and timestamp of mexican fishing vessels that comply with [Mexico's fisheries regulation](https://www.dof.gob.mx/nota_detalle.php?codigo=5399371&fecha=03/07/2015#gsc.tab=0) on the matter. Simply put, vessels larger than 10.5m in length overall, with an on-board engine > 80hp, and with a roof must carry a transponder.

### "Clean" data vailability, with two different levels of processing

- L1 data (not recommended): Monthly CSV files are available in the `data/clean/` and on Google Cloud storage at: `gs://mex_fisheries/MEX_VMS/*`
- L1 and L2 data (recommended): On Google BigQuery at: `mex-fisheries.mex_vms.mex_vms_latest`, as a partitioned table (by year) and some level of processing with added features.

Note that BigQuery data use a standard versioning system every time the tables undergo a major change, like fixing bugs, adding data, or modifying the underlying cleaning code. Past versions include:

- `mex-fisheries.mex_vms.mex_vms_processed_v_20250623` <-- This is the current version, viewed by `mex-fisheries.mex_vms.mex_vms_latest`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20250613`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20250319`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20240615`
- `mex-fisheries.mex_vms.mex_vms_processed_v_20240515`

You should be able to access the entire date set using BigQuery (SQL) or R. The following code snippet shows how you might connect to the database:

```
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
                 billing = "your-billing-id-here", # And this is the blling. You will need to use yours here.
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

_NOTE: For details on the data cleaning, next steps, and know issues, see the dedicated [README](/scripts). File may not be up to date_
