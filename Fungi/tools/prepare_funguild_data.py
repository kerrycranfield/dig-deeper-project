import csv

header_list = ["OTU ID", "Whitelands_2018_19", "Castle_Field_West_(W)", "Toposcope_Field_-_1980s", "Bradenham_post-1986_b", "Lardon_Chase_The_Holies_motorcycle", "Stonehenge_2000_2017a", "Stonehenge_2003_2017b", "Stonehenge_2009", "Stonehenge_2007_2016", "Stonehenge_2005", "Stonehenge_2002_2017", "Stonehenge_2010", "Stonehenge_2011", "Stonehenge_-_Luxenborough_BankB", "Watlington_natural_reversion", "St_Catherines_A3", "HARLEY_FARMS_Chittern", "HARLEY_FARMS_New1", "HARLEY_FARMS_new2b", "WINDMILL_farm", "DRUIDS", "Stratton_Wood", "WESTMEAD_FARM", "RSPB_orig_green", "RSPB_churchil", "RSPB_junction", "RSPB_Mainline", "Baltic_farm_1", "Baltic_farm_2", "WestEndFarm", "HorntonHouseFarm_1_parallel", "TownsendFarm_1", "TownsendFarm_2", "TownsendFarm_3_big", "ChurchFarm", "StowellFarms_1_adj", "MannorFmAltonBarnes", "HommingtonFarm", "ThropeManor_1", "ThropeManor_2", "ThropeManor_3", "MannorFmBroadChalke", "BigleyFm_1", "BigleyFm_2", "NorringtonMannorFm_1", "NorringtonMannorFm_2", "ManorFmBerwickStJohn_1", "ManorFmBerwickStJohn_3", "Jemma_1", "Jemma_2", "Jemma_7", "Jemma_4", "Jemma_5", "Jemma_6", "Jemma_9", "HomeFarm_WoodlandTrust_Hampshire_good_1c", "Crux_easton_70b1", "Crux_easton_70b2", "Martin_Down_arabel_reversion", "Parsonage_down_reversion", "TARGET_MartinDown", "TARGET_St_Catherines", "TARGET_ParsonageDown", "TARGET_KNEPP_A New_Barn_Field", "Knepp_Pond_field", "Knepp_Benton_field"]

with open("/mnt/beegfs/home/kerry.hathway/soil_microbiome/data/ITS/funguild_input_guilds.txt", mode='r', encoding="utf-8") as funguild:
    funguild_reader = csv.DictReader(funguild, delimiter="\t")

    guild_list = []

    for row in funguild_reader:
        guild_list.append([row["Guild"], row["Whitelands_2018_19"], row["Castle_Field_West_(W)"], row["Toposcope_Field_-_1980s"], row["Bradenham_post-1986_b"], row["Lardon_Chase_The_Holies_motorcycle"], row["Stonehenge_2000_2017a"], row["Stonehenge_2003_2017b"], row["Stonehenge_2009"], row["Stonehenge_2007_2016"], row["Stonehenge_2005"], row["Stonehenge_2002_2017"], row["Stonehenge_2010"], row["Stonehenge_2011"], row["Stonehenge_-_Luxenborough_BankB"], row["Watlington_natural_reversion"], row["St_Catherines_A3"], row["HARLEY_FARMS_Chittern"], row["HARLEY_FARMS_New1"], row["HARLEY_FARMS_new2b"], row["WINDMILL_farm"], row["DRUIDS"], row["Stratton_Wood"], row["WESTMEAD_FARM"], row["RSPB_orig_green"], row["RSPB_churchil"], row["RSPB_junction"], row["RSPB_Mainline"], row["Baltic_farm_1"], row["Baltic_farm_2"], row["WestEndFarm"], row["HorntonHouseFarm_1_parallel"],
                          row["TownsendFarm_1"], row["TownsendFarm_2"], row["TownsendFarm_3_big"], row["ChurchFarm"], row["StowellFarms_1_adj"], row["MannorFmAltonBarnes"], row["HommingtonFarm"], row["ThropeManor_1"], row["ThropeManor_2"], row["ThropeManor_3"], row["MannorFmBroadChalke"], row["BigleyFm_1"], row["BigleyFm_2"], row["NorringtonMannorFm_1"], row["NorringtonMannorFm_2"], row["ManorFmBerwickStJohn_1"], row["ManorFmBerwickStJohn_3"], row["Jemma_1"], row["Jemma_2"], row["Jemma_7"], row["Jemma_4"], row["Jemma_5"], row["Jemma_6"], row["Jemma_9"], row["HomeFarm_WoodlandTrust_Hampshire_good_1c"], row["Crux_easton_70b1"], row["Crux_easton_70b2"], row["Martin_Down_arabel_reversion"], row["Parsonage_down_reversion"], row["TARGET_MartinDown"], row["TARGET_St_Catherines"], row["TARGET_ParsonageDown"], row["TARGET_KNEPP_A New_Barn_Field"], row["Knepp_Pond_field"], row["Knepp_Benton_field"]])


with open("/mnt/beegfs/home/kerry.hathway/soil_microbiome/data/ITS/guilds_feature.tsv", "w", newline="") as guilds:
    guild_writer = csv.writer(guilds, delimiter="\t")
    guild_writer.writerow(header_list)

    for item in guild_list:
        guild_writer.writerow(item)

