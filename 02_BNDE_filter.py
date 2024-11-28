                        # Banana Papers - Web Scrapping for Biblioteca Nacional Digital del Ecuador
# Objective: Filter the newspapers with information about infraestructure

# Author: Nicolas Chuquimarca (USFQ & QMUL)
# version 0.1, 2024-11-27: Create the first scrapper

# 0. Packages
import os, pandas as pd 

# 1. Working directory
wd_path = "C:\\Users\\nicoc\\Dropbox\\Pre_OneDrive_USFQ\\PCNICOLAS_HP_PAVILION\\Masters\\USFQ\\USFQ_EconReview\\Author"
os.chdir(wd_path)

# 2. Open the csv file
fpath = wd_path + "\\data\\raw\\bnde_newspapers.csv"
df = pd.read_csv(fpath)

# 3. Filter the newspapers articles based on keywords
keywords = ['banano', 'Banano', 'Plátano','Carretera','Camino']

# Filter the DataFrame
filtered_df = df[df['abstract'].str.contains('|'.join(keywords), case=False, na=False)]


filtered_df

# 4. Save the filtered DataFrame as an excel file
fpath = wd_path + "\\data\\raw\\bnde_newspapers_filtered.xlsx"
filtered_df.to_excel(fpath, index=False)

# Ssave the raw thing as an excel
fpath = wd_path + "\\data\\raw\\bnde_newspapers.xlsx"
df.to_excel(fpath, index=False)

