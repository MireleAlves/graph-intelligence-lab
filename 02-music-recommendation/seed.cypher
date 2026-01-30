// =========================
// seed.cypher — Music Graph (Aura)
// NÃO duplica dados do CSV. Apenas complementa.
// =========================

// 0) Criar 10 usuários (caso não existam)
UNWIND range(1,10) AS i
MERGE (u:User {userId: "U" + toString(i)})
SET u.name = coalesce(u.name, "User " + toString(i));

// 1) Selecionar e marcar um pool de Tracks "populares" (para criar overlap)
MATCH (t:Track)
WITH t ORDER BY rand()
LIMIT 50
SET t.popular = true;

// 2) Cada usuário escuta 25 tracks do pool popular (gera overlap real)
//    e ainda escuta mais 25 tracks aleatórias (gera diversidade)
MATCH (u:User)
CALL {
  WITH u
  // 2.1 — populares (overlap)
  MATCH (t:Track) WHERE t.popular = true
  WITH u, t ORDER BY rand()
  LIMIT 25
  MERGE (u)-[l:LISTENED]->(t)
  SET l.count = coalesce(l.count, 0) + 1,
      l.duration_ms = coalesce(l.duration_ms, 180000),
      l.timestamp = coalesce(l.timestamp, datetime())
}
CALL {
  WITH u
  // 2.2 — aleatórias (diversidade)
  MATCH (t:Track)
  WITH u, t ORDER BY rand()
  LIMIT 25
  MERGE (u)-[l:LISTENED]->(t)
  SET l.count = coalesce(l.count, 0) + 1,
      l.duration_ms = coalesce(l.duration_ms, 180000),
      l.timestamp = coalesce(l.timestamp, datetime())
}
RETURN count(u) AS usersSeeded;

// 3) Criar LIKED a partir de parte do que foi escutado (20%)
MATCH (u:User)-[:LISTENED]->(t:Track)
WITH u, t
WHERE rand() < 0.20
MERGE (u)-[k:LIKED]->(t)
SET k.at = coalesce(k.at, datetime());

// 4) Criar FOLLOWS: usuário segue artistas que aparecem no seu histórico
//    (ajuste automático para Artist.name ou Artist.artist)
MATCH (u:User)-[:LISTENED]->(t:Track)<-[:CREATED]-(a:Artist)
WITH u, a, count(*) AS playsWithArtist
WHERE playsWithArtist >= 2
MERGE (u)-[f:FOLLOWS]->(a)
SET f.since = coalesce(f.since, date());

// 5) (Opcional, mas recomendado) Criar Genre e IN_GENRE se você ainda não tem
//    - Se já existir IN_GENRE, isso não duplica (MERGE).
UNWIND [
  "Rock","Pop","Indie","Electronic","Hip Hop",
  "Jazz","Lo-Fi","Alternative","Folk","Experimental"
] AS gname
MERGE (:Genre {name:gname});

// Atribuir 1 gênero aleatório a uma amostra de tracks (para demo / recomendação)
MATCH (t:Track)
WITH t ORDER BY rand()
LIMIT 200
MATCH (g:Genre)
WITH t, g ORDER BY rand()
WITH t, collect(g)[0] AS oneGenre
MERGE (t)-[:IN_GENRE]->(oneGenre);
