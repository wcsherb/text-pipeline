import pandas as pd
file = 'data/oig_tokens.csv'
df = pd.read_csv(file)
df.drop(df.columns[0], axis=1, inplace=True)
df['length'] = df['text'].str.len()
