import sqlite3
import pandas as pd

conn = sqlite3.connect('agriculture.db')

# Yield Summary
df = pd.read_csv('data/yield_summery.csv')
df.to_sql('yield_summary', conn, if_exists='replace', index=False)

# Area Summary
df = pd.read_csv('data/area_summary.csv')
df.to_sql('area_summary', conn, if_exists='replace', index=False)

# Wheat
df = pd.read_csv('data/crops/major_cereals/varieties/wheat/wheat_estimates_district.csv')
df.to_sql('wheat_data', conn, if_exists='replace', index=False)

# Rice Data - Aus
df_local = pd.read_csv('data/crops/major_cereals/varieties/aus/aus_local_by_district.csv')
df_local['variety'] = 'Local'
df_hyv = pd.read_csv('data/crops/major_cereals/varieties/aus/aus_hyv_by_district.csv')
df_hyv['variety'] = 'HYV'
df_hybrid = pd.read_csv('data/crops/major_cereals/varieties/aus/aus_hybrid_by_district.csv')
df_hybrid['variety'] = 'Hybrid'
df_total = pd.read_csv('data/crops/major_cereals/varieties/aus/aus_total_by_district.csv')
df_total['variety'] = 'Total'
df = pd.concat([df_local, df_hyv, df_hybrid, df_total])
df['crop'] = 'Aus Rice'
df.to_sql('rice_data', conn, if_exists='replace', index=False)

# Aman
df_broadcast = pd.read_csv('data/crops/major_cereals/varieties/aman/aman_broadcast_by_district.csv')
df_broadcast['variety'] = 'Broadcast'
df_local_trans = pd.read_csv('data/crops/major_cereals/varieties/aman/aman_local_trans_by_district.csv')
df_local_trans['variety'] = 'Local Transplant'
df_hyv = pd.read_csv('data/crops/major_cereals/varieties/aman/aman_hyv_by_district.csv')
df_hyv['variety'] = 'HYV'
df_hybrid = pd.read_csv('data/crops/major_cereals/varieties/aman/aman_hybrid_by_district.csv')
df_hybrid['variety'] = 'Hybrid'
df_total = pd.read_csv('data/crops/major_cereals/varieties/aman/aman_total_by_district.csv')
df_total['variety'] = 'Total'
df = pd.concat([df_broadcast, df_local_trans, df_hyv, df_hybrid, df_total])
df['crop'] = 'Aman Rice'
df.to_sql('rice_data', conn, if_exists='append', index=False)

# Boro
df_local = pd.read_csv('data/crops/major_cereals/varieties/boro/boro_local_by_district.csv')
df_local['variety'] = 'Local'
df_hyv = pd.read_csv('data/crops/major_cereals/varieties/boro/boro_hyv_by_district.csv')
df_hyv['variety'] = 'HYV'
df_hybrid = pd.read_csv('data/crops/major_cereals/varieties/boro/boro_hybrid_by_district.csv')
df_hybrid['variety'] = 'Hybrid'
df_total = pd.read_csv('data/crops/major_cereals/varieties/boro/boro_total_by_district.csv')
df_total['variety'] = 'Total'
df = pd.concat([df_local, df_hyv, df_hybrid, df_total])
df['crop'] = 'Boro Rice'
df.to_sql('rice_data', conn, if_exists='append', index=False)

conn.close()
