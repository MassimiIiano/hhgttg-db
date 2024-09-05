# Introduction to Databases Project

The project aims to be a simplified version of the The Hitchhiker's Guide to the Galaxy

The project was build starting from prof. Cavaleses [project requirements](https://www.inf.unibz.it/~calvanese/teaching/23-24-idb/#project).

## application domain

### The HHGTTG in universe Lore Repository 
We are interested in the Guide that contains entries helpful for navigating the universe, such entries have to be divided in the entries regarding persons of interest, entries regarding planets, entries regarding species and general entries. Only approved Authors may add entries to the Guide. People of interest may be given a score, to quickly identify how important they are. It is also of interest witch organisations they may lead. In addition we are interessed in the travelers using our guide, wich may rate planets they visited on a scale form 0 to 100. We want to know the planet of origin of the travelers, the species they belong to, witch planets they visited, when they visited it and the spacecraft they used to do so.

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

### diagram of the conceptual schema
![ER-Diagramm](er-diagramm.svg)

### data dictionary

#### Main Entities:

### table of volumes and table of operations according to the foreseen application load
