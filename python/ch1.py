import pandas as pd
import regex as re
from textacy.preprocessing.replace import urls

def keep_rows(text):
  this_bool = True
  # Match all Unicode letters
  this_bool = bool(re.search(r'\p{L}', text)) & this_bool
  # Drop Page numbers
  this_bool = not bool(re.search(r'^Page [0-9]+$', text)) & this_bool
  # Weird http debris
  this_bool = not bool(re.search(r'http:[a-z]+\.[0-9]+', text)) & this_bool
  return this_bool

def clean(text):
  # Mask URLs with _URL_
  return urls(text)
  
# Read the paragraph tokens from the OIG final reports
file = 'data/oig_tokens.csv'
df = pd.read_csv(file)
# Remove column with row nums
df.drop(df.columns[0], axis=1, inplace=True)
# Exclude rows without meaningful words
contains_letters = df['text'].map(keep_rows)
df = df[contains_letters]
# Clean the text that was kept
df['text'] = df['text'].map(clean)

