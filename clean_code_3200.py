'''
File: clean_code_3200.py

Description: This is where I matched the ISO code for emdat with the Country Code for wb df's
this file can be used to do additional cleaning if necessary 
'''
import pandas as pd
# gdp, urban pop, literacy rate, life expectancy, tourism
def clean_emdat(file):
    file = pd.read_csv(file)
    df = pd.DataFrame(file)
    return df

def clean_wb2(file):
    file = pd.read_csv(file, skiprows=4)
    df = pd.DataFrame(file)
    df = df.drop(columns=['Country Name'])
    return df

def match_data(file1, file2):
    df1 = clean_emdat(file1)
    df2 = clean_wb2(file2)
    code1 = set(sorted(df1['ISO'].unique()))
    code2 = set(sorted(df2['Country Code'].unique()))
    matching_codes = code1 & code2
    df1 = df1[df1['ISO'].isin(matching_codes)].reset_index(drop=True)
    df2 = df2[df2['Country Code'].isin(matching_codes)].reset_index(drop=True)

    return df1, df2




def main():
    gdp = 'gdp_fp.csv'
    emdat = 'emdat_fp.csv'
    urban_pop = 'urban_population_wb.csv'
    lit_rate = 'lit_rates_wb.csv'
    tourism = 'tourism_wb.csv'
    life_exp = 'life_exp_wb.csv'
    #emdat, urban_pop = match_data(emdat, urban_pop)
    # emdat, lit_rate = match_data(emdat, lit_rate)
    #emdat, tourism = match_data(emdat, tourism)
    #emdat, life_exp = match_data(emdat, life_exp)

    # print(len(emdat4['ISO'].unique()))
    # print(len(life_exp['Country Code'].unique()))

    # emdat, gdp = match_data(emdat, gdp)
    # print(gdp.columns)
    # print(emdat.columns)
    #life_exp.to_csv('matched_life_exp.csv', index=False)
    # emdat.to_csv('matched_emdat.csv', index=False)



main()


