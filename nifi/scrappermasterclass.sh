#!/usr/bin/python3

"""**Instalar Librerias**"""

from bs4 import BeautifulSoup
import requests
import json
import pandas as pd

"""**Scrapper a Usa Swimming**"""

def getPowerPoints(data):
  powerPointUrl="https://www.usaswimming.org/api/Times_PowerPointCalculator/CalculatePowerPoints"
  genderMapper={"Women":"W", "Men":"M"}
  styleMapper={"Freestyle":1}
  minutes=0
  seconds=0
  milliseconds=0
  if(len(data['atlete-time'].split(':')) == 1):
    seconds=data['atlete-time'].split('.')[0]
    milliseconds=data['atlete-time'].split('.')[1]
  else:
    time=data['atlete-time'].split(':')
    minutes=time[0]
    seconds=time[1].split('.')[0]
    milliseconds=time[1].split('.')[1]
  page=requests.post(powerPointUrl, data={'DSC[DistanceID]': data['event-distance'], 'DSC[StrokeID]': styleMapper[data['event-style']], 'DSC[CourseID]': 3, 'Gender':genderMapper[data['event-category']], 'Age': data['atlete-age'], 'Minutes': minutes, 'Seconds': seconds, 'Milliseconds': milliseconds})
  data['atlete-power-points']=int(page.text)
  return data

"""**Codigo Scrapping a SwimRankings**"""

def getDataset():
  competitionArr=[7450054]
  eventsArr=[1]
  genderArr=[1]
  urlBase="https://www.swimrankings.net/index.php"
  competitionBase=urlBase+"?page=meetSelect&selectPage=BYTYPE&nationId=0&meetType="
  dataset=[]

  for x in competitionArr:
    print(['competition', x])
    competitionUrl=competitionBase+str(x)
    page = requests.get(competitionUrl)
    soup = BeautifulSoup(page.text, 'html')
    table = soup.find("table", {"class": "meetSearch"})
    if(table != None):
      for row in table.find_all("tr", {"class": ["meetSearch0", "meetSearch1"]}):
        date = row.find("td", {"class": "date"}).text
        course = row.find("td", {"class": "course"}).text
        city = row.find("td", {"class": "city"}).find("a").text
        competition = row.find_all("td", {"class": "name"})[1].find("a").text
        competitionDetailUrl=urlBase+row.find_all("td", {"class": "name"})[1].find("a").get('href')
        for event in eventsArr:
          print(['event', event])
          for gender in genderArr:
            print(['gender', gender])
            competitionDetailEventUrl=competitionDetailUrl+"&gender="+str(gender)+"&styleId="+str(event)
            eventPage = requests.get(competitionDetailEventUrl)
            eventSoup = BeautifulSoup(eventPage.text, 'html')
            for tableEvent in eventSoup.find_all("table", {"class": "meetResult"}):
              headRow= tableEvent.find("tr",{"class": "meetResultHead"})
              eventData = headRow.find_all("th", {"class": "event"})[0].text
              eventData=eventData.replace(" ", "")
              eventDataRow=eventData.split(",")
              eventDataGender=eventDataRow[0]
              eventDataDistance=eventDataRow[1].split("m")[0]
              eventDataStyle=eventDataRow[1].split("m")[1]
              eventDataRace=eventDataRow[2]
              eventDate=headRow.find_all("th", {"class": "event"})[1].text
              if(len(eventDataDistance.split("x"))==1):
                for eventRow in tableEvent.find_all("tr",{"class": ["meetResult0", "meetResult1"]}):
                  eventRowPosition= eventRow.find_all("td", {"class": "meetPlace"})[0].text 
                  eventRowPosition= eventRowPosition.replace(" ", "").replace(".", "")
                  eventRowName= eventRow.find_all("td", {"class": "name"})[0].text 
                  eventRowYob= eventRow.find("td", {"class": "yob"}).text 
                  eventRowCountryCode= eventRow.find("td", {"class": "code"}).text 
                  eventRowCountryName= eventRow.find_all("td", {"class": "name"})[1].text
                  eventRowSwimTime= eventRow.find("td", {"class": "swimtime"}).text
                  eventRowFinaPoints= eventRow.find_all("td", {"class": "meetPlace"})[1].text
                  if(eventRowFinaPoints != "-"):
                    data = {}
                    data['competition-date'] = str(date.encode('ascii', 'ignore')).split("'")[1]
                    data['competition-city'] = str(city.encode('ascii', 'ignore')).split("'")[1]
                    data['competition-name'] = competition
                    if(gender==1):
                      data['event-category']= 'Men'
                    else:
                      data['event-category']= 'Women'
                    data['event-style']=eventDataStyle
                    data['event-distance']=int(eventDataDistance)
                    data['event-distance-measure']='m'
                    data['event-name']=eventDataRace
                    data['event-date']=eventDate
                    data['atlete-position']=eventRowPosition
                    data['atlete-name']=str(eventRowName.encode('ascii', 'ignore'))
                    data['atlete-yob']=int(eventRowYob)
                    data['atlete-age']= int(eventDate.split(" ")[2]) - int(eventRowYob)
                    data['atlete-country']=eventRowCountryName
                    data['atlete-time']=eventRowSwimTime
                    data['atlete-fina21-points']=int(eventRowFinaPoints)
                    data= getPowerPoints(data)
                    dataset.append(data)

  return json.dumps(dataset)

"""**Creacion de archivo CSV**"""

dataset= pd.read_json(getDataset())
dataset.to_csv('/opt/nifi_conf/dataset.csv')
