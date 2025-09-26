# Functions

source(here::here("scripts", "helpers", "helpers_clean_dates.R"))
source(here::here("scripts", "helpers", "helpers_clean_eu_names.R"))
source(here::here("scripts", "helpers", "helpers_fix_rnpa.R"))
# String-fixing function
str_fix <- function(x) {
  x <- str_to_upper(x)        # String to upper
  x <-
    str_trim(x)            # Trim leading and trailing whites paces
  x <- str_squish(x)          # Squish repeated white spaces
  return(x)                   # Return clean string
}
