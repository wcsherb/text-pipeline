import os
import pandas as pd
import regex as re
import torch
from textacy.preprocessing.replace import urls
from transformers import BertConfig, BertTokenizer, BertForSequenceClassification
from sklearn.model_selection import train_test_split

# test PyTorch
x = torch.rand(5, 3)
print(x)

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
  
# PREPARE TEXT

# Read the paragraph tokens from the OIG final reports
cwd = os.getcwd()
if cwd != '/home/wcs/projects/text-pipeline/data':
  os.chdir('data')

file = 'oig_sentences.csv'
df = pd.read_csv(file)
# Remove column with row nums
df.drop(df.columns[0], axis=1, inplace=True)
# Exclude rows without meaningful words
contains_letters = df['text'].map(keep_rows)
df = df[contains_letters]
# Clean the text that was kept
df['text'] = df['text'].map(clean)

# CONFIG MODEL

config = BertConfig.from_pretrained('bert-base-uncased', finetuningtask='binary')
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
model = BertForSequenceClassification.from_pretrained('bert-base-uncased')

# Page 314
def get_tokens(text, tokenizer, max_seq_length, add_special_tokens=True):
  input_ids = tokenizer.encode(text, add_special_tokens=add_special_tokens, max_length=max_seq_length, pad_to_max_length=True)
  attention_mask = [int(id > 0) for id in input_ids]
  assert len(input_ids) == max_seq_length
  assert len(attention_mask) == max_seq_length
  return(input_ids, attention_mask)

text = "Here is the sentence I want embeddings for."
input_ids, attention_mask = get_tokens(text, tokenizer, max_seq_length=30, add_special_tokens=True)
input_tokens = tokenizer.convert_ids_to_tokens(input_ids)
print(text)
print(input_tokens)
print(input_ids)
print(attention_mask)

