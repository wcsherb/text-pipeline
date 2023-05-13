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

all_sentences <- tibble::tibble(file=character(), paragraph=integer(), text=character())
# Tokenize into sentences ----
for ( i in 1:nrow(all_tokens) ) {
  if ( i %% 100 == 0 ) message("Tokenize ", i, " of ", nrow(all_tokens))
  tokens <- tokenizers::tokenize_sentences(all_tokens$text[i])
  this_df <- tibble::tibble(file=all_tokens$file[i], paragraph=i, text=tokens[[1]])
  all_sentences <- rbind(all_sentences, this_df)
}

# Write Text ----
setwd('../data')
write.csv(all_tokens, 'oig_paragraphs.csv')
write.csv(all_sentences, 'oig_sentences.csv')
rm(list=ls())

# Try https://github.com/trinker/stansent
# if (!require("pacman")) install.packages("pacman")
# pacman::p_load_gh('wcsherb/coreNLPsetup')
# pacman::p_load_gh("trinker/sentimentr")
# pacman::p_load_gh("trinker/stansent")

require(stansent)
dat <- read.csv('data/oig_paragraphs.csv')
stansent::check_setup()

