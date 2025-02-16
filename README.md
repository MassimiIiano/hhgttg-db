# Introduction to Databases Project

The project aims to be a simplified version of the The Hitchhiker's Guide to the Galaxy

The project was build starting from prof. Cavaleses [project requirements](https://www.inf.unibz.it/~calvanese/teaching/24-25-idb/#project).

### Specification: The HHGTTG Repository 
We are interested in the Guide that contains entries helpful for navigating the universe, such entries have to be divided in the entries regarding VIPs (Arthur Dent: A confused Earthman who found himself rather unexpectedly thrust into galactic adventures. Entry notes: “Mostly in search of tea and a decent sandwich.”), entries regarding planets ("Earth: Mostly harmless. Except for the moments when it isn’t. Known for its bizarre obsession with paperwork and reality TV."), entries regarding species (Vogon Poetry: The third worst poetry in the universe. Exposure to it can cause extreme nausea, loss of will to live, and in extreme cases, spontaneous self-combustion) and general entries (Towel: The single most massively useful thing an interstellar hitchhiker can carry. It can be used for warmth, defense, signaling, or even as a makeshift flotation device. Most importantly, it makes you look like you know what you're doing). Only approved Authors with a high enough reputation, may add entries to the Guide. Authors. VIPs, who are generally famous persons and not only authors may be given a score, to quickly identify how important they are eg. the president of the galaxy scould have a high score. In addition, we are interested in the travelers using our guide, which may rate the location they visited on a scale from 0 to 100, can rate a location more then once providet at least one 30 standard days passed since the last visit. We need also the time  We are also interested in the Spacecraft they use to travel, in particular how many people it transportred, the amenities of the veichle, and the name of the organizations that produce such spacecraft. We want to know the planet of origin of the travelers, the species they belong to and which planets they visited,

### Structured and organized requirements

1. **Guide Entries Management**  
   - The system must manage a repository of entries that provide useful information for navigating the universe.  
   - The system must classify each entry into one of the following categories:  
     - VIP entries (for important or famous persons)  
     - Planet entries  
     - Species entries  
     - General entries  

2. **Authorship and Approval**  
   - The system must restrict the ability to add new entries to approved authors only.  
   - Approval must be based on criteria ensuring the author’s suitability to contribute to the Guide.

3. **VIPs**  
   - The system must identify VIPs as persons who hold a notable status (e.g., public figures, high-ranking officials, etc.).  
   - The system must allow for a measure of importance or significance to be assigned to VIPs.

4. **Travelers and Visits**  
   - The system must keep track of travelers who make use of the Guide.  
   - The system must record each traveler’s visits to various locations across the universe.

5. **Ratings and Constraints**  
   - The system must allow travelers to evaluate or rate a location after visiting it.  
   - The system must ensure that a traveler can submit multiple ratings for the same location only if certain temporal conditions are met.

6. **Spacecraft**  
   - The system must keep track of the spacecraft used by travelers for their journeys.  
   - The system must record details about the organizations responsible for producing these spacecraft.

7. **Species and Origin**  
   - The system must record the species to which each traveler belongs.  
   - The system must track the planet of origin for each traveler.

8. **Planetary Information**  
   - The system must maintain information about the planets in the universe.  
   - The system must track which travelers have visited which planets.

9. **Temporal Tracking**  
   - The system must handle the notion of time and ensure time-related rules (e.g., intervals between ratings) are enforced.  


### requirements

1. It should be based on a domain containing between 6 and 10 main conceptual entities (i.e., without counting sub-entities that appear in ISAs or generalizations).
2. There should be some structure in the set of entities, i.e., the ER schema should in addition contain at least one ISA and at least one generalization.
3. There should be sufficient structure in the relationships, which usually means that the representation of the ER schema as a graph (where the nodes are given by the entities and relationships, and the edges are given by the participation of entities in relationships) should contain some cycles.
4. The schema should contain cardinality constraints on the participation of entities to relationships that are different from the default (0,n).
5. The schema should contain some identifiers made of multiple attributes, and at least one external identification for some entity.
6. The schema should contain at least one optional attribute and at least one multi-valued attribute.
7. There should be some external constraints, that cannot be represented in the ER model.
8. The specification should include an indication about the volumes for the various entities and relationships (pay attention to the coherence between the volumes and the cardinality constraints of the ER schema).
9. The specification should include a workload of the most common queries and operations (between 5 and 10) that are of interest in the modeled domain, with an indication of their frequency.

### glossary 
| term   | description | synonym | connections |
| ------ | ----------- | ------- | ----------- |
| person | persons travel, write articles andor are VIPs | individual | spicies, location, spacecraft |
| location | planets, stars, space stations | place | person, organisation |
| spicies | spicies of persons | race | person, location |
| organisation | organisations that produce spacecraft | company | spacecraft |
| spacecraft | spacecraft used by persons | ship | person, organisation, location |
| entry | entries in the guide | article | author |
| author | authors of entries | writer | entry, person |
| vip | very important person | important person | person, person_entry |
| person_entry | rating of a person | rating | vip, entry |
| location_entry | rating of a location | rating | location, entry |
| spiceis_entry | rating of a spicies | rating | spicies, entry |
| planet | planets in the universe | world | location |
| space_station | space stations in the universe | station | location |

### diagram of the conceptual schema
![ER-Diagramm](hhgttg-diagramm.drawio.png)

### data dictionary
<!-- TODO -->

### table of volumes and table of operations according to the foreseen application load


### Restructured conceptual scema

![Restructured ER-Diagramm](hhgttg-restructured.drawio.png)

### external constraints

1. Each instance of Entry partecipates to at most one of the relationships ISA-L-E or ISA-P-E or ISA-S-E
2. Each instance of Location partecipates to exactly one of the relationships ISA-S-L, ISA-P-L

### translation

Entry(<u>ied</u>, title, text)

Person(<u>pid</u>, name)

Location(<u>name</u>, sector, rating)
Organisation(<u>name</u>)

Spacecraft(<u>name</u>, capacity, amenities, speed)

Species(<u>sid</u>, name, traits, avrage_lifespan)


Trip(<u>startDate</u>, <u>endDate</u>, <u>person</u>, score) \
Foreign key: Trip[person] $\subseteq$ Person[pid] \
Foreign key: Trip[location] $\subseteq$ Location[name]

Author(<u>id</u>, reputation) \
Foreign key: Author[id] $\subseteq$ Person[pid]

Vip(<u>id</u>, importance) 
Foreign key: Vip[id] $\subseteq$ Person[pid]

PersonEntry(<u>entry</u>) \
Foreign key: PersonEntry[entry] $\subseteq$ Entry[ied]

LocationEntry(<u>entry</u>) \
Foreign key: LocationEntry[entry] $\subseteq$ Entry[ied]

SpeciesEntry(<u>entry</u>) \
Foreign key: SpeciesEntry[entry] $\subseteq$ Entry[ied]

Planet(<u>name</u>, population) \
Foreign key: Planet[name] $\subseteq$ Location[name]

SpaceStation(<u>name</u>, purpose, speed*) \
Foreign key: SpaceStation[name] $\subseteq$ Location[name]

about(<u>entry</u>, species) \
Foreign key: about[entry] $\subseteq$ Entry[ied] \
Foreign key: about[species] $\subseteq$ Species[sid] \

writes(<u>entry</u>, author) \
Foreign key: writes[entry] $\subseteq$ Entry[ied] \
Foreign key: writes[author] $\subseteq$ Author[id]

references(<u>entry</u>, vip) \
Foreign key: references[entry] $\subseteq$ Entry[ied] \
Foreign key: references[vip] $\subseteq$ Vip[id]

relatingTo(<u>entry</u>, location) \
Foreign key: relatingTo[entry] $\subseteq$ Entry[ied] \
Foreign key: relatingTo[location] $\subseteq$ Location[name]

belongsTo(<u>person</u>, species) \
Foreign key: belongsTo[person] $\subseteq$ Person[pid] \
Foreign key: belongsTo[species] $\subseteq$ Species[sid]

goesOn(<u>person</u>, <u>startDate</u>, <u>endDate</u>) \
Foreign key: goesOn[person] $\subseteq$ Person[pid] \
Foreign key: goesOn[startDate] $\subseteq$ Trip[startDate] \
Foreign key: goesOn[endDate] $\subseteq$ Trip[endDate]

uses(<u>person</u>, <u>spacecraft</u>, <u>startDate, endDate</u>) \
Foreign key: uses[person] $\subseteq$ Trip[person] \
Foreign key: uses[spacecraft] $\subseteq$ Spacecraft[name] \
Foreign key: uses[startDate] $\subseteq$ Trip[startDate] \
Foreign key: uses[endDate] $\subseteq$ Trip[endDate]

to(<u>person</u>, location, <u>startDate, endDate</u>) \
Foreign key: to[person] $\subseteq$ Trip[person] \
Foreign key: to[location] $\subseteq$ Trip[startDate] \
Foreign key: to[endDate] $\subseteq$ Trip[endDate]

bornOn(<u>person</u>, planet) \
Foreign key: bornOn[person] $\subseteq$ Person[pid] \
Foreign key: bornOn[planet] $\subseteq$ Planet[name]

manufactured(<u>spacecraft</u>, organisation) \
Foreign key: manufactured[spacecraft] $\subseteq$ Spacecraft[name] \
Foreign key: manufactured[organisation] $\subseteq$ Organisation[name]

### external constraints
- Spacestation[name] $\cap$ Planet[name] = $\emptyset$ 
- Location[name] $\subseteq$ Planet[name] $\cup$ Spacestation[name]
- LocationEntry[entry] $\cap$ SpeciesEntry[entry] $\cap$ PersonEntry[entry]= $\emptyset$ 
- Trip[startDate] $<$ Trip[endDate]




#### restructuring of the relation schema

Entry(<u>ied</u>, title, text, author) \
FK: Entry[author] $\subseteq$ Author[id]

Person(<u>pid</u>, name, species, bornon) \
FK: Person[species] $\subseteq$ Species[sid], Person[bornon] $\subseteq$ Location[name]

Location(<u>name</u>, sector, rating)

Organisation(<u>name</u>)

Spacecraft(<u>name</u>, capacity, amenities, organisation)
FK: Spacecraft[organisation] $\subseteq$ Organisation[name]

Species(<u>sid</u>, name, traits, avrage_lifespan)


Trip(<u>startDate</u>, <u>endDate</u>, <u>person</u>, location, score) \
Foreign key: Trip[person] $\subseteq$ Person[pid] \
Foreign key: Trip[location] $\subseteq$ Location[name]

Author(<u>id</u>, reputation) \
Foreign key: Author[id] $\subseteq$ Person[pid]

Vip(<u>id</u>, importance) 
Foreign key: Vip[id] $\subseteq$ Person[pid]

PersonEntry(<u>entry</u>, vip) \
Foreign key: PersonEntry[entry] $\subseteq$ Entry[ied], PersonEntry[vip] $\subseteq$ Vip[id]

LocationEntry(<u>entry</u>, location) \
Foreign key: LocationEntry[entry] $\subseteq$ Entry[ied], LocationEntry[location] $\subseteq$ Location[name]

SpeciesEntry(<u>entry</u>, species) \
Foreign key: SpeciesEntry[entry] $\subseteq$ Entry[ied], SpeciesEntry[species] $\subseteq$ Species[sid]

Planet(<u>name</u>, population) \
Foreign key: Planet[name] $\subseteq$ Location[name]

SpaceStation(<u>name</u>, purpose, speed*) \
Foreign key: SpaceStation[name] $\subseteq$ Location[name]

uses(<u>person</u>, <u>spacecraft</u>, <u>startDate, endDate</u>) \
Foreign key: uses[person] $\subseteq$ Trip[person] \
Foreign key: uses[spacecraft] $\subseteq$ Spacecraft[name] \
Foreign key: uses[startDate] $\subseteq$ Trip[startDate] \
Foreign key: uses[endDate] $\subseteq$ Trip[endDate]


### external constraints
- Spacestation[name] $\cap$ Planet[name] = $\emptyset$ 
- Location[name] $\subseteq$ Planet[name] $\cup$ Spacestation[name]
- LocationEntry[entry] $\cap$ SpeciesEntry[entry] $\cap$ PersonEntry[entry]= $\emptyset$ 
- Trip[startDate] $<$ Trip[endDate]