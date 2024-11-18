import requests

def get_location_details(place_name):
    url = "https://nominatim.openstreetmap.org/search"
    params = {
        'q': place_name,  # The place to search for
        'format': 'json',  # The format of the response
        'limit': 1,  # Limit to one result
        'addressdetails': 1  # Include address details in the response
    }
    
    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    response = requests.get(url, params=params, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        if data:
            return data[0]  # Return the first match
        else:
            return "No location found"
    else:
        return f"Error: {response.status_code}"

def get_reverse_location(lat, lon):
    url = "https://nominatim.openstreetmap.org/reverse"
    params = {
        'lat': lat,
        'lon': lon,
        'format': 'json',
        'addressdetails': 1
    }

    headers = {
        'User-Agent': 'Mozilla/5.0'
    }

    response = requests.get(url, params=params, headers=headers)
    
    if response.status_code == 200:
        return response.json()  # The result will contain address details
    else:
        return f"Error: {response.status_code}"
    
def get_cluster_details(clusters):
    cluster_details = []
    for i in range(len(clusters)):
        lat, lon = clusters[i][0], clusters[i][1]
        location_info = get_reverse_location(lat, lon)
        cluster_details.append(location_info)
    return cluster_details



# try out a location
if __name__ == "__main__":
    latitude, longitude = 43.662235, -79.379345
    location_info = get_reverse_location(latitude, longitude)
    print(location_info)