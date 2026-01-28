// 1) Users and what they watched
MATCH (u:User)-[w:WATCHED]->(t)
RETURN u.userId, u.name, labels(t) AS type, coalesce(t.title, "") AS title, w.rating
ORDER BY u.userId, w.rating DESC;

// 2) Top genres by number of watched items
MATCH (:User)-[:WATCHED]->(t)-[:IN_GENRE]->(g:Genre)
RETURN g.name AS genre, count(*) AS watches
ORDER BY watches DESC;

// 3) Recommend: users who watched the same movies/series (collaborative hint)
MATCH (u1:User)-[:WATCHED]->(t)<-[:WATCHED]-(u2:User)
WHERE u1 <> u2
RETURN u1.userId AS user, collect(DISTINCT u2.userId) AS similarUsers, count(DISTINCT t) AS overlap
ORDER BY overlap DESC;

// 4) Actors and the titles they acted in
MATCH (a:Actor)-[:ACTED_IN]->(t)
RETURN a.name AS actor, labels(t) AS type, coalesce(t.title, "") AS title
ORDER BY actor;

// 5) Directors and the titles they directed
MATCH (d:Director)-[:DIRECTED]->(t)
RETURN d.name AS director, labels(t) AS type, coalesce(t.title, "") AS title
ORDER BY director;
