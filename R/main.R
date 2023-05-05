require(dplyr)
require(rvest)
require(stringr)
require(rtika)
require(tokenizers)

setwd('audits')

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

all_tokens <- all_tokens %>% mutate(text = trimws(text)) %>%
  filter(!is.na(text)) %>% filter(nchar(text) > 0)

# Write Text ----
setwd('../data')
write.csv(all_tokens, 'oig_tokens.csv')