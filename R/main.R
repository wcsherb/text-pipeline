require(tidyverse)
require(rtika)
require(tokenizers)

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

# Tika Audits ----
batch <- list.files()
html <- rtika::tika_html(batch)

# Tokenize into paragraphs ----
all_tokens <- tibble::tibble(file=character(), text=character())
for ( i in 1:length(batch) ) {
  message('Tokenize ', i)
  file_name <- read_html(html[i]) %>% html_elements(xpath = "//meta[@name='resourceName']") %>%
    html_attr('content')
  body_text <- read_html(html[i]) %>% html_element('body') %>% html_text2()
  tokens <- tokenizers::tokenize_paragraphs(body_text)
  tokens <- tokens[[1]]
  this_df <- tibble::tibble(file=file_name, text=tokens)
  all_tokens <- rbind(all_tokens, this_df)
}

# Write Text ----
setwd('../data')
write.csv(all_tokens, 'oig_tokens.csv')