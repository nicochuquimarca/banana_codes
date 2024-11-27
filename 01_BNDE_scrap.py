                        # Banana Papers - Web Scrapping for Biblioteca Nacional Digital del Ecuador
# Objective: Scrap the BNDE's website for a list of newspapers with information about infraestructure

# Author: Nicolas Chuquimarca (USFQ & QMUL)
# version 0.1, 2024-11-27: Create the first scrapper

# 0. Packages
import requests, os
from bs4 import BeautifulSoup
import pandas as pd

# 0. Function list
# Fn01: repo_bne_scrapper = Scrap the BNDE's website given a url
# Fn02 get_bnde_df = Get the BNDE's dataframe for a range of urls

# 1. Working directory
wd_path = "C:\\Users\\nicoc\\Dropbox\\Pre_OneDrive_USFQ\\PCNICOLAS_HP_PAVILION\\Masters\\USFQ\\USFQ_EconReview\\Author"
os.chdir(wd_path)

# 2. Function definitions
# Fn01: repo_bne_scrapper = Scrap the BNDE's website given a url
def repo_bnde_scrapper(url):
    # 1. Send the Request and parse the html page
    response = requests.get(url)                          # Send a GET request to the web page
    soup = BeautifulSoup(response.content, 'html.parser') # Parse the HTML content of the page
    
    # 2. Find all the artifact items (each element is a newspaper article)
    items = soup.find_all('li', class_='ds-artifact-item')

    # 3. Store all the items in a df
    data = []          # Initialize a list to store the data
    for item in items: # Loop over each item and extract the relevant information
        id_url = item.find('div', class_='artifact-title').a['href']
        title = item.find('div', class_='artifact-title').a.get_text(strip=True)
        info = item.find('div', class_='artifact-info').get_text(strip=True)
        date = item.find('span', class_='date').get_text(strip=True)
        abstract = item.find('div', class_='artifact-abstract').get_text(strip=True)
        # Append the extracted information to the data list
        data.append({'id': id_url,'title': title,'info': info,'date': date,'abstract': abstract})
    
    # 4. Return a dataframe
    df = pd.DataFrame(data)
    return df
# Fn02 get_bnde_df = Get the BNDE's dataframe for a range of urls
def get_bnde_df(num_pages):
    # 1. Define the static part of the url
    url_p1 = "https://repositorio.bne.gob.ec/xmlui/handle/BNEE/19716/browse?rpp=20&sort_by=2&type=dateissued&offset="
    url_p3 = "&etal=-1&order=ASC"
    # 2. Create an empty DataFrame
    data = pd.DataFrame()
    # 3. Scrap using the num_pages parameter
    for i in range(14):
        # 3.1 Complete the url
        url_p2 = (i * 20)    
        url = url_p1 + str(url_p2) + url_p3
        # 3.2 Scrap the data
        print("Currently scrapping page ", i+1, "of" , num_pages)
        df = repo_bnde_scrapper(url = url)
        # 3.3 Concatenate the data to the main DataFrame
        data = pd.concat([data, df], ignore_index=True)
    # 4. Return the final DataFrame
    return data

# 3. Call functions
num_pages = 14 # Ex-ante number of pages (known after a manual inspection)
data = get_bnde_df(num_pages = num_pages) # Get the newspaper data

# 4. Save the data
# data.to_csv("data\\raw\\bnde_newspapers.csv", index = False) # Save the data in a csv file