Cluster basado en: https://github.com/big-data-europe/docker-hadoop

Codigo del Global Project

ALUMNO: Victor Alfonso Prato De Leon

PROGRAMA: 
MÁSTER EN DATA SCIENCE Y BIG DATA

NOMBRE DEL PROYECTO: Recolección y Análisis de datos como estrategia para mejorar el rendimiento en Natación. (https://docs.google.com/document/d/1XH4fGuRF3aa45tkiqXhCxlEoLr7J6Em4/edit?usp=sharing&ouid=115069301435667729990&rtpof=true&sd=true).

El fichero "modeloPredictivoMasterClass.ipynb", tiene el entrenamiento y validacion de la red neuronal seleccionada para el calculo de "Power Points", su salida es el modelo en format *.pkl


Pasos para configurar el entorno.

1.- Ejecutar "docker-compose up -d"

2.- Conectarse al contenedor de NiFi y cargar el template que esta en el directorio "nifi/nifi-template".

3.- Conectarse al contenedor Hive-server a la interfaz beeline y crear la tabla con el siguiente comando:
create external table if not exists swimrankings(id int, competition_date string, competition_city string, competition_name string, event_category string, event_style string, event_distance int, event_distance_measure string, event_name string, event_date string, atlete_position string, atlete_name string, atlete_yob int, atlete_age int, atlete_country string, atlete_time string, atlete_fina21_points int, atlete_power_points int)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile
location 'hdfs://namenode:9001/home/datalake/swimrankings'
TBLPROPERTIES ("skip.header.line.count"="1");

4.- Conectarse al contenedor de Hive y ejecutar los siguientes comandos:
      	superset superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin
              
       superset superset db upgrade
       
       superset superset init
5.- Logearse en superset navegando a http://localhost:8080/login/ -- u/p: [admin/admin]

6.- Dentro de superset agregar Hive como base de datos. Uri de conexion: "hive://hive@hive-server:10000/default"

