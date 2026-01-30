// =========================
// queries.cypher — Music Graph (Aura)
// =========================

// Q0) Sanity check: contagem por label
MATCH (n)
RETURN labels(n) AS label, count(*) AS total
ORDER BY total DESC;


// Q1) Quantas relações LISTENED existem?
MATCH ()-[r:LISTENED]->()
RETURN count(r) AS totalListened;


// Q2) Overlap entre usuários (base da recomendação colaborativa)
MATCH (u1:User)-[:LISTENED]->(t:Track)<-[:LISTENED]-(u2:User)
WHERE u1 <> u2
RETURN u1.userId AS userA, u2.userId AS userB, count(DISTINCT t) AS sharedTracks
ORDER BY sharedTracks DESC
LIMIT 10;


// Q3) Top Tracks por “popularidade” (número de listeners)
MATCH (:User)-[:LISTENED]->(t:Track)
RETURN coalesce(t.track_name, t.title, t.name) AS track,
       count(*) AS listeners
ORDER BY listeners DESC
LIMIT 10;


// Q4) Top Artists por número de Tracks no catálogo
MATCH (a:Artist)-[:CREATED]->(:Track)
RETURN coalesce(a.artist, a.name) AS artist,
       count(*) AS tracks
ORDER BY tracks DESC
LIMIT 10;


// Q5) Recomendação colaborativa (usuários parecidos -> novas tracks)
// Troque userId "U1" se quiser testar com outro usuário.
MATCH (me:User {userId:"U1"})-[:LISTENED]->(t:Track)<-[:LISTENED]-(other:User)
WHERE me <> other
WITH me, other, count(DISTINCT t) AS overlap
ORDER BY overlap DESC
WITH me, collect(other)[0..5] AS similarUsers
UNWIND similarUsers AS sim
MATCH (sim)-[:LISTENED]->(rec:Track)
WHERE NOT (me)-[:LISTENED]->(rec)
RETURN coalesce(rec.track_name, rec.title, rec.name) AS recommended,
       count(*) AS score,
       collect(DISTINCT sim.userId)[0..3] AS fromUsers
ORDER BY score DESC
LIMIT 10;


// Q6) Recomendação por GÊNERO (precisa existir IN_GENRE)
MATCH (me:User {userId:"U1"})-[:LISTENED]->(:Track)-[:IN_GENRE]->(g:Genre)
WITH me, g, count(*) AS genreScore
ORDER BY genreScore DESC
WITH me, collect(g)[0..3] AS topGenres
UNWIND topGenres AS g
MATCH (rec:Track)-[:IN_GENRE]->(g)
WHERE NOT (me)-[:LISTENED]->(rec)
RETURN g.name AS genre,
       coalesce(rec.track_name, rec.title, rec.name) AS recommended
LIMIT 10;


// Q7) Recomendação por ARTISTA SEGUIDO (FOLLOWS -> CREATED)
MATCH (me:User {userId:"U1"})-[:FOLLOWS]->(a:Artist)-[:CREATED]->(rec:Track)
WHERE NOT (me)-[:LISTENED]->(rec)
RETURN coalesce(a.artist, a.name) AS artist,
       coalesce(rec.track_name, rec.title, rec.name) AS recommended
LIMIT 10;


// Q8) Print bonito — grafo do usuário (para screenshot)
MATCH (me:User {userId:"U1"})-[l:LISTENED]->(t:Track)
OPTIONAL MATCH (t)<-[:CREATED]-(a:Artist)
OPTIONAL MATCH (t)-[:IN_GENRE]->(g:Genre)
RETURN me, l, t, a, g
LIMIT 80;
