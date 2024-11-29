                        # Banana Papers - Web Scrapping for Biblioteca Nacional Digital del Ecuador
# Objective: Scrap the BNDE's website for a list of newspapers with information about infraestructure

# Author: Nicolas Chuquimarca (USFQ & QMUL)
# version 0.1, 2024-11-27: Create the first scrapper
# version 0.2, 2024-11-29: Produce a headlines files (from script to functions)

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
# Fn02: get_bnde_df = Get the BNDE's dataframe for a range of urls
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
        'id'       : [id]        * len(headlines),
        'newspaper': [newspaper] * len(headlines),
        'date'     : [date]      * len(headlines),
        'headline' : headlines,
        'url'      : [url]       * len(headlines),
    }
    # 6. Return the DataFrame
    df = pd.DataFrame(data)
    return df
# Fn04: get_bnde_complete_df = Get the complete headlines in order to perform keyword filtering
def get_bnde_complete_df(df):
    # 0. Get the issue id and create a list to loop forward
    df['issue_id'] = df['id'].astype(str).str[-5:]
    issue_id = df['issue_id']
    # 1. Create an empty DataFrame to store the data
    data = pd.DataFrame()
    # 2. Iterate over all the issues ids to get the headlines
    for id in issue_id:
        id_text = str(id)
        df = get_single_issue_bnde_df(id = id_text)
        data = pd.concat([data, df], ignore_index=True)
    # 3. Return the final DataFrame
    return data
# Fn05: filter_bnde_df = Filter the newspapers articles based on keywords 
def filter_bnde_df(df, keywords):
    # 1. Filter the DataFrame
    filtered_df = df[df['headline'].str.contains('|'.join(keywords), case=False, na=False)]
    # 2. Return the filtered DataFrame
    return filtered_df
# Fn06: save_filtered_df = Save the filtered DataFrame as an excel file
def save_filtered_df(df,wd_path,name):
    # 1. Define the file path
    fpath = wd_path + "\\data\\raw\\bnde_newspapers\\bnde_newspapers_"+name+".xlsx"
    # 2. Save the DataFrame as an excel file
    df.to_excel(fpath, index=False)



# 3. Get a list of all the newspaper articles under a certain search criteria
num_pages = 14 # Ex-ante number of pages (known after a manual inspection)
art_data = get_bnde_df(num_pages = num_pages) # Get the newspaper data
file_path = wd_path + "\\data\\raw\\bnde_newspapers\\bnde_newspapers.csv" # Define the file path
# art_data.to_csv(file_path, index = False) # Save the data in a csv file

# 4. Get the complete headlines in order to perform keyword filtering (Scrapper)
# df = pd.read_csv(file_path) # Read the csv file
# df_headlines = get_bnde_complete_df(df = df) # Get the headlines
# fpath = wd_path + "\\data\\raw\\bnde_newspapers\\bnde_newspapers_headlines.csv"
# df_headlines.to_csv(fpath, index = False) # Save the data

# 5. Filter the newspapers articles based on tematic keywords
# 5.1 Open the headlines file
fpath = wd_path + "\\data\\raw\\bnde_newspapers\\bnde_newspapers_headlines.csv"
df_headlines = pd.read_csv(fpath) # Read the csv file
# 5.2 Filter based on keywords
# 5.2.1 Roads and Railways
roads_and_rail_keys = ['Autopista','autopista','Camino','Carretera','carretera','carretero','Carretero',
                       'Vía','vía','Vias','vias','Vialidad','vialidad','Ferrocarril','ferrocarril',
                       'ferrocarriles','Transporte','transporte','puente','Puente','locomotora',
                       'Locomotora','ferroviario','Ferroviario','ferrocarriles','Ferrocarriles','vial',
                       'Vial','Pavimentación','pavimentación','Pavimentacion','pavimentacion',
                       'automovilístico','Tránsito','tránsito','transito','Transito','vialidad','Ruta',
                       'ruta','ferrocarrilero','trafico','Trafico','tráfico','Tráfico','automotriz',
                       'vehículos','Vehículos']
randr_df = filter_bnde_df(df = df_headlines, keywords = roads_and_rail_keys) # Filter the data
save_filtered_df(df=randr_df,wd_path = wd_path,name="roads_and_rail") # Save the data
# 5.2.2 Export products
products_keys = ['Plátano', 'plátano','Cacao','cacao','Banano','banano','bananos','Bananos',
                 'Café','café','Cafe','cafe']
products_df = filter_bnde_df(df = df_headlines, keywords = products_keys) # Filter the data
save_filtered_df(df=products_df,wd_path = wd_path,name="products") # Save the data
# 5.2.3 Ships and Planes
ships_and_planes_keys = ['Puerto','Aeropuerto','aeropuerto','Navieras','navieras','naviera','Naviera',
                         'fletes','Fletes','aérea','Aérea','aerea','Aerea','Buque','buque','buques',
                         'Buques','aviación','Avión','Aduana','aduana','aduanas','Aduanas','aviadores',
                         'presupuesto','Barcos','barcos','barco','Barco','Marina','marina']
ships_and_planes_df = filter_bnde_df(df = df_headlines, keywords = ships_and_planes_keys) # Filter the data
save_filtered_df(df=ships_and_planes_df,wd_path = wd_path,name="ships_and_planes") # Save the data
# 5.2.4 All Keywords
all_keys = ['Plátano', 'plátano', 'Autopista','autopista','Camino','Carretera','carretera','carretero',
            'carretera','puerto','Puerto','infraestructura','Infraestructura','Carretero',
            'Cacao','cacao','Banano','banano','bananos','Bananos','Aeropuerto','aeropuerto',
            'Tren','tren','Vía','vía','Vias','vias','Vialidad','vialidad',
            'Ferrocarril','ferrocarril','ferrocarriles','Transporte','transporte','Obras','obras',
            'Construcción','construcción','Construccion','construccion',
            'carretero','Carretero','puente','Puente','locomotora','Locomotora',
            'inauguración','Inauguración','inauguracion','Inauguracion','Navieras',
            'navieras','naviera','Naviera','fletes','Fletes','aérea','Aérea','aerea','Aerea',
            'Tarifa','tarifa','tarifas','Tarifas','Esmeraldas','Guayas','Manabí','Los Ríos',
            'Loja','exportación','Exportación','exportacion','Exportacion','importación',
            'ferroviario','Ferroviario','ferrocarriles','Ferrocarriles','vial','Vial',
            'Buque','buque','buques','Buques','urbanización','Pavimentación',
            'automovilístico','aviación','Avión','Aduana','aduana','aduanas','Aduanas',
            'Tránsito','tránsito','transito','Transito','embarque','aviadores','presupuesto',
            'vialidad','Ruta','ruta','primas','ferrocarrilero','Presupuesto','presupuesto',
            'Barcos','barcos','barco','Barco','Marina','marina','Café','café','Cafe','cafe',
            'trafico','Trafico','tráfico','Tráfico','automotriz','vehículos','Vehículos',
            'inaugura']
all_keys_df = filter_bnde_df(df = df_headlines, keywords = all_keys) # Filter the data
save_filtered_df(df=all_keys_df,wd_path = wd_path,name="all_keywords") # Save the data