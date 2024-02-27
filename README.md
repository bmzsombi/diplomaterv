# Diplomaterv

## 1. Onos

### Cél

* brown field &rarr; green field
* georedundancia
* ISP-knek kifejezetten
* SD-WAN
* **JAVA**

![onos-architecture](kepek/onos-architecture.png)

### Modularitás

* eszközök ki/be csatlakoztatása, miközben fut a kontroller

### Skálázhatóság

* Vízszintes skálázhatóságra tervezték
* Atomix datastore konzisztenciát biztosít controllerek között
* Hamar leterhelődik, sok hostot nem bír el
* natív BGP

### Interfészek

* Déli: OpenFlow, P4, NETCONF, TL1, SNMP, BGP, RESTCONF and PCEP
* Északi: gRPC, RESTful APIs
* Van GUI
* Intent based framework
* YANG

### Hiba tolerancia

* Egyszerű cluster kezelés
* HA átállás

### Support

* Linux Foundation Networking

## Opendaylight

## Cél

* SD-LAN
* Felhő integráció
* Nagy skálázhatóság és automatizáció

![odl-architecture](kepek/OxygenDiagrams_031218.png)

