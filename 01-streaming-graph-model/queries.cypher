// =========================
// QUERIES.CYPHER — Streaming Graph Model
// =========================

// Q0) Contagem de nós por label (valida “10 de cada”)
MATCH (n)
RETURN labels(n) AS labels, count(*) AS total
ORDER BY total DESC;


// Q1) Histórico de um usuário (o que assistiu + rating)
MATCH (u:User {userId:"U001"})-[w:WATCHED]->(t)
RETURN u.userId AS user, u.name AS name, labels(t) AS type, t.title AS title, w.rating AS rating
ORDER BY rating DESC, title;


// Q2) Top conteúdos (Movie/Series) por média de rating (popularidade)
MATCH (:User)-[w:WATCHED]->(t)
RETURN labels(t) AS type, t.title AS title,
       round(avg(w.rating) * 100) / 100 AS avgRating,
       count(w) AS watches
ORDER BY avgRating DESC, watches DESC
LIMIT 15;


// Q3) Top gêneros por número de WATCHED (o que mais consomem)
MATCH (:User)-[:WATCHED]->(t)-[:IN_GENRE]->(g:Genre)
RETURN g.name AS genre, count(*) AS watches
ORDER BY watches DESC
LIMIT 10;


// Q4) Recomendação por GÊNERO (baseada no gosto do usuário)
// - Pega os gêneros mais assistidos pelo usuário e recomenda títulos desses gêneros
//   que ele ainda não assistiu.
MATCH (u:User {userId:"U001"})-[:WATCHED]->(seen)-[:IN_GENRE]->(g:Genre)
WITH u, g, count(*) AS genreScore
ORDER BY genreScore DESC
WITH u, collect(g)[0..3] AS topGenres  // top 3 gêneros
UNWIND topGenres AS g
MATCH (rec)-[:IN_GENRE]->(g)
WHERE (rec:Movie OR rec:Series)
  AND NOT (u)-[:WATCHED]->(rec)
RETURN labels(rec) AS type, rec.title AS recommended, g.name AS becauseGenre
LIMIT 20;


// Q5) Recomendação por “USUÁRIOS PARECIDOS” (colaborativa simples)
// - Encontra usuários que assistiram os mesmos títulos e recomenda o que eles viram e o usuário não viu.
MATCH (me:User {userId:"U001"})-[:WATCHED]->(t)<-[:WATCHED]-(other:User)
WHERE me <> other
WITH me, other, count(DISTINCT t) AS overlap
ORDER BY overlap DESC
WITH me, collect(other)[0..3] AS similarUsers  // top 3 usuários semelhantes
UNWIND similarUsers AS sim
MATCH (sim)-[:WATCHED]->(rec)
WHERE NOT (me)-[:WATCHED]->(rec)
RETURN labels(rec) AS type, rec.title AS recommended, sim.userId AS fromUser
LIMIT 20;


// Q6) Recomendação por ATOR (se você gosta de um ator, recomenda onde ele atuou)
MATCH (u:User {userId:"U001"})-[:WATCHED]->(t)<-[:ACTED_IN]-(a:Actor)
WITH u, a, count(*) AS actorAffinity
ORDER BY actorAffinity DESC
WITH u, collect(a)[0..2] AS favoriteActors // top 2 atores
UNWIND favoriteActors AS a
MATCH (a)-[:ACTED_IN]->(rec)
WHERE NOT (u)-[:WATCHED]->(rec)
RETURN a.name AS becauseActor, labels(rec) AS type, rec.title AS recommended
LIMIT 20;


// Q7) Recomendação por DIRETOR (similar ao ator)
MATCH (u:User {userId:"U001"})-[:WATCHED]->(t)<-[:DIRECTED]-(d:Director)
WITH u, d, count(*) AS directorAffinity
ORDER BY directorAffinity DESC
WITH u, collect(d)[0..2] AS favoriteDirectors // top 2 diretores
UNWIND favoriteDirectors AS d
MATCH (d)-[:DIRECTED]->(rec)
WHERE NOT (u)-[:WATCHED]->(rec)
RETURN d.name AS becauseDirector, labels(rec) AS type, rec.title AS recommended
LIMIT 20;


// Q8) Conteúdos relacionados a um título (mesmos gêneros)
// Útil para "Se você gostou de X, talvez goste de Y"
MATCH (base:Movie {movieId:"M004"})-[:IN_GENRE]->(g:Genre)<-[:IN_GENRE]-(rec)
WHERE rec <> base
RETURN base.title AS baseTitle, rec.title AS relatedTitle, labels(rec) AS type, collect(g.name) AS sharedGenres
LIMIT 20;


// Q9) Exploração visual: grafo do usuário (para print no GitHub)
MATCH (u:User {userId:"U001"})-[w:WATCHED]->(t)
OPTIONAL MATCH (t)-[:IN_GENRE]->(g:Genre)
RETURN u, w, t, g
LIMIT 120;


// Q10) Exploração visual: atores e diretores conectados aos títulos (para print)
MATCH (t)
WHERE t:Movie OR t:Series
OPTIONAL MATCH (a:Actor)-[:ACTED_IN]->(t)
OPTIONAL MATCH (d:Director)-[:DIRECTED]->(t)
OPTIONAL MATCH (t)-[:IN_GENRE]->(g:Genre)
RETURN t, a, d, g
LIMIT 120;

