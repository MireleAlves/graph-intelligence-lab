// Q1) Quem segue quem? (rede de seguidores)
MATCH (a:User)-[:FOLLOWS]->(b:User)
RETURN a.userId AS follower, b.userId AS follows
ORDER BY follower, follows
LIMIT 50;

// EXPLAIN
EXPLAIN
MATCH (a:User)-[:FOLLOWS]->(b:User)
RETURN a.userId AS follower, b.userId AS follows
LIMIT 50;

// PROFILE
PROFILE
MATCH (a:User)-[:FOLLOWS]->(b:User)
RETURN a.userId AS follower, b.userId AS follows
LIMIT 50;


// Q2) Quem publicou o quê?
MATCH (u:User)-[:POSTED]->(p:Post)
RETURN u.userId AS user, p.postId AS post, p.content AS content
ORDER BY user
LIMIT 30;

// PROFILE
PROFILE
MATCH (u:User)-[:POSTED]->(p:Post)
RETURN u.userId AS user, p.postId AS post
LIMIT 30;


// Q3) Quais posts são mais curtidos? (popularidade)
MATCH (u:User)-[:LIKED]->(p:Post)
RETURN p.postId AS post, count(*) AS likes
ORDER BY likes DESC
LIMIT 10;

// PROFILE
PROFILE
MATCH (:User)-[:LIKED]->(p:Post)
RETURN p.postId AS post, count(*) AS likes
ORDER BY likes DESC
LIMIT 10;


// Q4) Quem é o usuário com mais engajamento? (likes+comments+posts)
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
OPTIONAL MATCH (u)-[:LIKED]->(lp:Post)
OPTIONAL MATCH (u)-[:COMMENTED]->(cp:Post)
RETURN u.userId AS user,
       count(DISTINCT p) AS posts,
       count(DISTINCT lp) AS likes,
       count(DISTINCT cp) AS comments,
       (count(DISTINCT p)+count(DISTINCT lp)+count(DISTINCT cp)) AS engagement
ORDER BY engagement DESC
LIMIT 10;


// Q5) Menor caminho entre dois usuários (conexões sociais)
// Troque U1 e U9 para testar
MATCH (a:User {userId:"U1"}), (b:User {userId:"U9"})
MATCH p = shortestPath((a)-[:FOLLOWS*..6]->(b))
RETURN p;

// PROFILE
PROFILE
MATCH (a:User {userId:"U1"}), (b:User {userId:"U9"})
MATCH p = shortestPath((a)-[:FOLLOWS*..6]->(b))
RETURN p;


// Q6) Comunidades de interesse por tópico (quem fala sobre o quê)
MATCH (u:User)-[:POSTED]->(p:Post)-[:TAGGED_WITH]->(t:Topic)
RETURN t.name AS topic, collect(DISTINCT u.userId)[0..10] AS users
ORDER BY topic;

// PROFILE
PROFILE
MATCH (u:User)-[:POSTED]->(p:Post)-[:TAGGED_WITH]->(t:Topic)
RETURN t.name AS topic, count(DISTINCT u) AS users
ORDER BY users DESC
LIMIT 10;


// Q7) Recomendar perfis para seguir (amigos-de-amigos)
// Para U1: pessoas seguidas por quem U1 segue, que U1 ainda não segue
MATCH (me:User {userId:"U1"})-[:FOLLOWS]->(:User)-[:FOLLOWS]->(rec:User)
WHERE rec <> me AND NOT (me)-[:FOLLOWS]->(rec)
RETURN rec.userId AS recommendedUser, count(*) AS score
ORDER BY score DESC
LIMIT 10;
