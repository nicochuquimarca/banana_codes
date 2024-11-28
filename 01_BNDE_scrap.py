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
# Fn03: get_single_issuee_bnde_df = Get the BNDE's newspaper, date and headlines for an individual newspaper issue
def get_single_issue_bnde_df(id):
    # 0. Call the web page
    url = "https://repositorio.bne.gob.ec/xmlui/handle/34000/" + id
    response = requests.get(url)                          # Send a GET request to the web page
    soup = BeautifulSoup(response.content, 'html.parser') # Parse the HTML content of the page
    meta_tags = soup.find_all('meta') # Find all meta tags
    # 1. Extract specific meta tags
    abstract    = None
    newspaper   = None
    date        = None
    # 3. Get the information in vectors
    for tag in meta_tags:
        if tag.get('name') == 'DCTERMS.abstract':
            abstract = tag.get('content')
        elif tag.get('name') == 'DC.title':
            newspaper = tag.get('content')
        elif tag.get('name') == 'citation_date':
            date = tag.get('content')
    # 4. Split the abstract string into a list of headlines
    headlines = abstract.split(" -- ")
    # 5. Create a DataFrame with url, newspaper, date, and headlines
    data = {
        'id'       : [id01]      * len(headlines),
        'newspaper': [newspaper] * len(headlines),
        'date'     : [date]      * len(headlines),
        'headline' : headlines,
        'url'      : [url]       * len(headlines),
    }
    # 6. Return the DataFrame
    df = pd.DataFrame(data)
    return df


# 3. Get a list of all the newspaper articles under a certain search criteria
num_pages = 14 # Ex-ante number of pages (known after a manual inspection)
art_data = get_bnde_df(num_pages = num_pages) # Get the newspaper data
file_path = wd_path + "\\data\\raw\\bnde_newspapers.csv" # Define the file path
# art_data.to_csv(file_path, index = False) # Save the data in a csv file



# 4. Get the complete headlines in order to perform keyword filtering
df = pd.read_csv(file_path) # Read the csv file
df['issue_id'] = df['id'].astype(str).str[-5:] # Get the issue id
issue_id = df['issue_id']


# Create a single dataframe with all the headlines
data = pd.DataFrame()
# Iterate over all the issues ids
for id in issue_id:
    id_text = str(id)
    df = get_single_issue_bnde_df(id = id_text)
    data = pd.concat([data, df], ignore_index=True)

data.columns


# Filter the newspapers articles based on keywords
keywords = ['Plátano', 'plátano', 'Autopista','autopista','Camino','Carretera',
            'carretera','puerto','Puerto','infraestructura','Infraestructura',
            'Cacao','cacao','Banano','banano','Aeropuerto','aeropuerto',
            'Tren','tren','Vía','vía','Vias','vias','Vialidad','vialidad',
            'Ferrocarril','ferrocarril','Transporte','transporte','Obras','obras',
            'Construcción','construcción','Construccion','construccion',
            'carretero','Carretero','puente','Puente','locomotora','Locomotora']

# Filter the DataFrame
filtered_df = data[data['headline'].str.contains('|'.join(keywords), case=False, na=False)]


filtered_df

fpath = wd_path + "\\data\\raw\\bnde_newspapers_filtered.xlsx"
filtered_df.to_excel(fpath, index=False)



# Ssave the raw thing as an excel
fpath = wd_path + "\\data\\raw\\bnde_newspapers.xlsx"
data.to_excel(fpath, index=False)
