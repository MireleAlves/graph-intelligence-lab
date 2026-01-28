// =========================
// Seed data (10 users, 6 movies, 4 series, genres, actors, directors)
// Relationships: WATCHED(rating), ACTED_IN, DIRECTED, IN_GENRE
// =========================

// Genres
UNWIND ["Action","Drama","Sci-Fi","Comedy","Thriller","Animation"] AS gname
MERGE (:Genre {name: gname});

// Users (10)
UNWIND [
  {userId:"U001", name:"Ana"},
  {userId:"U002", name:"Bruno"},
  {userId:"U003", name:"Clara"},
  {userId:"U004", name:"Diego"},
  {userId:"U005", name:"Ester"},
  {userId:"U006", name:"Felipe"},
  {userId:"U007", name:"Gabi"},
  {userId:"U008", name:"Hugo"},
  {userId:"U009", name:"Iris"},
  {userId:"U010", name:"João"}
] AS u
MERGE (usr:User {userId:u.userId})
SET usr.name = u.name;

// Movies (6)
UNWIND [
  {movieId:"M001", title:"Edge of Tomorrow", year:2014, genres:["Action","Sci-Fi"]},
  {movieId:"M002", title:"The Dark Knight", year:2008, genres:["Action","Thriller"]},
  {movieId:"M003", title:"Inside Out", year:2015, genres:["Animation","Comedy","Drama"]},
  {movieId:"M004", title:"Interstellar", year:2014, genres:["Sci-Fi","Drama"]},
  {movieId:"M005", title:"Parasite", year:2019, genres:["Drama","Thriller"]},
  {movieId:"M006", title:"The Grand Budapest Hotel", year:2014, genres:["Comedy","Drama"]}
] AS m
MERGE (mv:Movie {movieId:m.movieId})
SET mv.title = m.title,
    mv.year  = m.year
WITH mv, m
UNWIND m.genres AS gname
MATCH (g:Genre {name:gname})
MERGE (mv)-[:IN_GENRE]->(g);

// Series (4)
UNWIND [
  {seriesId:"S001", title:"Stranger Things", startYear:2016, genres:["Sci-Fi","Thriller"]},
  {seriesId:"S002", title:"The Office", startYear:2005, genres:["Comedy"]},
  {seriesId:"S003", title:"Breaking Bad", startYear:2008, genres:["Drama","Thriller"]},
  {seriesId:"S004", title:"Arcane", startYear:2021, genres:["Animation","Action","Drama"]}
] AS s
MERGE (sr:Series {seriesId:s.seriesId})
SET sr.title = s.title,
    sr.startYear = s.startYear
WITH sr, s
UNWIND s.genres AS gname
MATCH (g:Genre {name:gname})
MERGE (sr)-[:IN_GENRE]->(g);

// Actors (10)
UNWIND [
  {actorId:"A001", name:"Tom Cruise"},
  {actorId:"A002", name:"Emily Blunt"},
  {actorId:"A003", name:"Christian Bale"},
  {actorId:"A004", name:"Heath Ledger"},
  {actorId:"A005", name:"Amy Poehler"},
  {actorId:"A006", name:"Matthew McConaughey"},
  {actorId:"A007", name:"Song Kang-ho"},
  {actorId:"A008", name:"Bill Hader"},
  {actorId:"A009", name:"Bryan Cranston"},
  {actorId:"A010", name:"Hailee Steinfeld"}
] AS a
MERGE (ac:Actor {actorId:a.actorId})
SET ac.name = a.name;

// Directors (6)
UNWIND [
  {directorId:"D001", name:"Doug Liman"},
  {directorId:"D002", name:"Christopher Nolan"},
  {directorId:"D003", name:"Pete Docter"},
  {directorId:"D004", name:"Bong Joon-ho"},
  {directorId:"D005", name:"Wes Anderson"},
  {directorId:"D006", name:"The Duffer Brothers"}
] AS d
MERGE (dr:Director {directorId:d.directorId})
SET dr.name = d.name;

// ACTED_IN (sample links)
MATCH (m1:Movie {movieId:"M001"}), (m2:Movie {movieId:"M002"}), (m3:Movie {movieId:"M003"}),
      (m4:Movie {movieId:"M004"}), (m5:Movie {movieId:"M005"}), (m6:Movie {movieId:"M006"}),
      (s1:Series {seriesId:"S001"}), (s3:Series {seriesId:"S003"}), (s4:Series {seriesId:"S004"})
MATCH (a1:Actor {actorId:"A001"}), (a2:Actor {actorId:"A002"}), (a3:Actor {actorId:"A003"}), (a4:Actor {actorId:"A004"}),
      (a5:Actor {actorId:"A005"}), (a6:Actor {actorId:"A006"}), (a7:Actor {actorId:"A007"}), (a8:Actor {actorId:"A008"}),
      (a9:Actor {actorId:"A009"}), (a10:Actor {actorId:"A010"})
MERGE (a1)-[:ACTED_IN]->(m1)
MERGE (a2)-[:ACTED_IN]->(m1)
MERGE (a3)-[:ACTED_IN]->(m2)
MERGE (a4)-[:ACTED_IN]->(m2)
MERGE (a5)-[:ACTED_IN]->(m3)
MERGE (a8)-[:ACTED_IN]->(m3)
MERGE (a6)-[:ACTED_IN]->(m4)
MERGE (a7)-[:ACTED_IN]->(m5)
MERGE (a10)-[:ACTED_IN]->(s4)
MERGE (a9)-[:ACTED_IN]->(s3);

// DIRECTED (sample links)
MATCH (d1:Director {directorId:"D001"}), (d2:Director {directorId:"D002"}), (d3:Director {directorId:"D003"}),
      (d4:Director {directorId:"D004"}), (d5:Director {directorId:"D005"}), (d6:Director {directorId:"D006"})
MATCH (m1:Movie {movieId:"M001"}), (m2:Movie {movieId:"M002"}), (m3:Movie {movieId:"M003"}),
      (m4:Movie {movieId:"M004"}), (m5:Movie {movieId:"M005"}), (m6:Movie {movieId:"M006"}),
      (s1:Series {seriesId:"S001"})
MERGE (d1)-[:DIRECTED]->(m1)
MERGE (d2)-[:DIRECTED]->(m2)
MERGE (d2)-[:DIRECTED]->(m4)
MERGE (d3)-[:DIRECTED]->(m3)
MERGE (d4)-[:DIRECTED]->(m5)
MERGE (d5)-[:DIRECTED]->(m6)
MERGE (d6)-[:DIRECTED]->(s1);

// WATCHED with rating (Users watching movies/series)
UNWIND [
  {u:"U001", items:[{t:"M001", r:4.5},{t:"S001", r:4.0}]},
  {u:"U002", items:[{t:"M002", r:5.0},{t:"S003", r:4.8}]},
  {u:"U003", items:[{t:"M003", r:4.7},{t:"S002", r:4.2}]},
  {u:"U004", items:[{t:"M004", r:4.9},{t:"S001", r:4.1}]},
  {u:"U005", items:[{t:"M005", r:4.6},{t:"S003", r:5.0}]},
  {u:"U006", items:[{t:"M006", r:4.3},{t:"S002", r:4.0}]},
  {u:"U007", items:[{t:"M002", r:4.8},{t:"M004", r:4.6}]},
  {u:"U008", items:[{t:"S004", r:4.9},{t:"M003", r:4.4}]},
  {u:"U009", items:[{t:"M001", r:4.2},{t:"M005", r:4.7}]},
  {u:"U010", items:[{t:"S001", r:4.3},{t:"S004", r:4.8}]}
] AS row
MATCH (u:User {userId: row.u})
UNWIND row.items AS it
CALL {
  WITH it
  OPTIONAL MATCH (m:Movie {movieId: it.t})
  RETURN m AS item
  UNION
  WITH it
  OPTIONAL MATCH (s:Series {seriesId: it.t})
  RETURN s AS item
}
WITH u, it, item
WHERE item IS NOT NULL
MERGE (u)-[w:WATCHED]->(item)
SET w.rating = it.r;
