import numpy as np
import matplotlib.pyplot as plt
import openStreetMapQueries as osmq
import get_clusters as gc
import time

if __name__ == "__main__":
    file_loc = "GeoLingo_Location2.csv" # geolocation data from phone
    with open(file_loc, 'r') as file:
        data = file.readlines()
    data = sorted(data[1:], key=lambda x: x.split(',')[0])

    data = data[::400] # roughly one location every second

    lat_lon_pairs = np.array([[float(line.split(',')[1]), float(line.split(',')[2])] for line in data[1:]])
    
    latitudes = lat_lon_pairs[:, 0]
    longitudes = lat_lon_pairs[:, 1]

    # DBSCAN is in O(n^2) so if data gets too large, run small point chunks at a time to detect clusters
    start_time = time.time()
    radius = 10/6371000 # 20m in haversine distance from radians
    clusters = gc.get_clusters(lat_lon_pairs, eps=radius , min_samples=20) #120 samples is 5 minutes
    print("Time taken to cluster: ", time.time() - start_time)
    geodata = osmq.get_cluster_details(clusters)

    for cluster in geodata:
        print(cluster["type"], cluster["name"])
    
    # For debugging purposes:
    # for cluster in clusters.values():
    #     print(len(cluster[2]))
    # print(len(data))

    # Plot lat/lon evolution
    plt.figure(figsize=(10, 6))
    plt.scatter(longitudes, latitudes, c='blue', marker='o')
    plt.scatter([cluster[1] for cluster in clusters.values()], [cluster[0] for cluster in clusters.values()], c='red', marker='x')
    plt.title('Geographical Locations')
    plt.xlabel('Longitude')
    plt.ylabel('Latitude')
    plt.grid(True)
    plt.show()