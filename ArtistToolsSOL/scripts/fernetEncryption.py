from wsgiref import headers
import requests
import json
from cryptography.fernet import Fernet


def old():
    url = "https://api.spotify.com/v1/me/top/artists?limit=10&time_range=medium_term"
    access_token = "BQCG-8DSGh7WU-ANW2KCnyavEEjtJjH1g1kj2YM6qUEwRhjxB8nUbSKPzyaUOBHJD3QuBwiEWh0lsj24D3i3e5an2V6quB1QDvK4jjUQWSjuKQ0yp62QJerawyAeyFHEMI8zGRrsi6HFNrIvrItJUDB3BA"
    headers = {
        "Authorization": "Bearer " + access_token,
        "Accept": "application/json",
    }
    try:
        response = requests.get(url, headers=headers)
        data = response.json()
        artistInfo = list()
        # now grab top 10 artists and put into array
        for i in range(0, len(data["items"])):
            artistInfo.append(data["items"][i]["id"])  # //to pass to mintBatch
            # print(data[[i])
            i = i + 1
        print(artistInfo)
    except Exception as e:
        print(e)


def main():
    LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"
    LETTERS += LETTERS.lower()
    LETTERS += "1234567890_-"
    key = Fernet.generate_key()
    access_token_encoded = ""
    access_token_decoded = ""
    access_token = "BQAb1TiGzJEbH5anbGy9Lp4YdE_wRj7wkEck3iLJczCG08GAm_meLLjSGtkw3JWaHSI6PpuwHGY-7ot5nDsQ-EBG-T-p9AtKYpXY2tWmwuRAGmPRHVnEJ65G8FuuiJlkHRV0SXMfzZCYTOVU6uufKSjswg"

    ##apparnetly it's never safe to encrypt in the browser, which makes sense. https://github.com/csquared/fernet.js/blob/master/README.md
    fernet = Fernet(b"lARsuqVb__9EQZpp8J_Mt7-GrXNrCH-1PWrG29OTEzU=")
    print(f"key {key}")
    access2 = access_token.encode(encoding="ascii")
    print(f"Accesstoken in ascii: {access2}")
    access_token_encoded = fernet.encrypt(access_token.encode(encoding="ascii"))
    print(f"Access token encoded: {access_token_encoded}")
    access_token_decoded = fernet.decrypt(access_token_encoded).decode(encoding="ascii")

    print(f"Access token decoded: {access_token_decoded}")
    print(f"Access token origina: {access_token}")
