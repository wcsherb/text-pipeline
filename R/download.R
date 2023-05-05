require(rvest)

# Download Audits ----
oig_url <- 'https://www.oig.dhs.gov/reports/audits-inspections-and-evaluations?field_dhs_agency_target_id=2&field_fy_value=All'
oig_audits <- read_html(oig_url) %>% html_elements('tbody') %>% html_elements('a') %>% html_attr('href')
setwd('audits')
for ( this_url in oig_audits ) {
  file_name <- str_extract(this_url, '[A-Za-z0-9-]+\\.pdf$')
  message('Downloading ', file_name)
  this_url <- paste0('https://www.oig.dhs.gov', this_url)
  download.file(this_url, file_name)
}