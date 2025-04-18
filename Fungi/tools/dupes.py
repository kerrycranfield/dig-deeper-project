import csv

with open("/mnt/beegfs/home/kerry.hathway/soil_microbiome/data/ITS/guilds_feature.tsv", "r", encoding="utf-8") as guilds:
    guild_reader = csv.reader(guilds, delimiter="\t")

    guild_dict = {}

    for row in guild_reader:
        if row[0] not in guild_dict:
            guild_dict[row[0]] = row
        else:
            temp_list = guild_dict[row[0]]  # get value using key
            # loop over list items doing the addition
            for i in range(1, len(row)):
                count = float(row[i])
                temp_list[i] = float(temp_list[i]) + count
            #assign it back to the dict using the key
            guild_dict[row[0]] = temp_list

with open("/mnt/beegfs/home/kerry.hathway/soil_microbiome/data/ITS/guilds_feature_dedupe.tsv", "w", newline="") as dedupe_file:
    dedupe_writer = csv.writer(dedupe_file, delimiter="\t")
    
    for item in guild_dict.values():
        dedupe_writer.writerow(item)
