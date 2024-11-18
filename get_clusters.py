import numpy as np
from scipy.stats import norm
from sklearn.cluster import DBSCAN
from sklearn.metrics.pairwise import haversine_distances
from math import radians
from openStreetMapQueries import get_reverse_location

def get_clusters(data, eps=0.00001, min_samples=10):
    # eps -> maximum distance between two samples in the same neighborhood

    # Convert latitude and longitude to radians for haversine distance calculation
    data_rad = np.radians(data)
    
    db = DBSCAN(eps=eps, min_samples=min_samples, metric='haversine').fit(data_rad)

    # cluster labels
    labels = db.labels_

    clusters = {}
    for label in set(labels):
        if label == -1: # noise points
            continue  
        cluster_points = data[labels == label]
        avg_lat = cluster_points[:, 0].mean()
        avg_lon = cluster_points[:, 1].mean()
        clusters[label] = (avg_lat, avg_lon, cluster_points)

    return clusters


# For debugging purposes: generates random data along a sum of gaussians to create clusters
def gaussian_mixture_pdf(x, means, std_devs, weights):

    k = len(means)

    # Calculate the PDF as the weighted sum of each Gaussian PDF
    pdf = sum(w * norm.pdf(x, mean, std_dev) for w, mean, std_dev in zip(weights, means, std_devs))
    
    return pdf

def sample_from_mixture(n, means, std_devs, weights, x_min, x_max):
    samples = []
    threshold = 1e-20 
    # rough approx of maximum of pdf, try sum of weights
    i = 0
    while len(samples) < n:
        x_proposal = np.random.uniform(x_min, x_max)
        
        # Compute the PDF at the proposal point
        y_proposal = np.random.uniform(0, threshold)
        if y_proposal <= gaussian_mixture_pdf(x_proposal, means, std_devs, weights):
            samples.append(x_proposal)
        i += 1
    # print(i)
    
    return np.array(samples)

def generate_geodata(n):
    means_lat = np.random.uniform(-90, 90, 5)
    means_lon = np.random.uniform(-180, 180, 3)
    std_devs_lat = np.random.uniform(0, 0.1, 5)
    std_devs_lon = np.random.uniform(0, 0.1, 3)
    weights_lat = np.random.uniform(1, 1.5, 5)
    weights_lon = np.random.uniform(1, 1.5, 3)

    data_lat = sample_from_mixture(n, means_lat, std_devs_lat, weights_lat, -90, 90)
    data_lon = sample_from_mixture(n, means_lon, std_devs_lon, weights_lon, -180, 180)

    data = np.stack([data_lat, data_lon], axis=1)
    return data

