# 🔐 Constraints & Indexes – Music Streaming Graph

Este arquivo define as **constraints de unicidade** e **índices** utilizados no grafo de streaming musical.

O objetivo é garantir:
- Identificação única dos nós
- Integridade dos dados
- Melhor performance nas consultas Cypher

---

## 🎵 Track
Cada música é identificada de forma única.

```cypher
CREATE CONSTRAINT track_id_unique IF NOT EXISTS
FOR (t:Track)
REQUIRE t.trackId IS UNIQUE;

CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.userId IS UNIQUE;

CREATE CONSTRAINT artist_name_unique IF NOT EXISTS
FOR (a:Artist)
REQUIRE a.name IS UNIQUE;

CREATE CONSTRAINT album_name_unique IF NOT EXISTS
FOR (a:Album)
REQUIRE a.name IS UNIQUE;

CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (g:Genre)
REQUIRE g.name IS UNIQUE;


