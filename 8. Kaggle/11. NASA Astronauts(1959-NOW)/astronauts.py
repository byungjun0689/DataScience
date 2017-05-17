# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import re

df = pd.read_csv("astronauts.csv")

df['Group'] = df['Group'].astype(object)
sns.boxplot(df['Year'],)

df.describe()
len(df['Group'].unique())

df.head()

sns.factorplot('Military Rank',kind='count',data= df)
plt.xticks(rotation=90)

sns.factorplot('Status', kind='count', data=df)
plt.xticks(rotation=45)

sns.factorplot('Military Branch', kind='count', data=df, size=8)
plt.xticks(rotation=90)

df2 = df.copy()
df2['Military Branch'].apply(lambda x:replace(x," (Retired)"))

Temp_df = df[["Space Flights","Space Flight (hr)"]]
Temp_df.head()
Temp_df[["Space Flights","Space Flight (hr)"]].head(2).apply(lambda x:x[1]/x[0], axis=1)