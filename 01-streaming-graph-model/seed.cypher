// ---------- GENRES (10) ----------
UNWIND [
  "AI","Cybersecurity","Data Science","Cloud","Programming",
  "Robotics","Blockchain","UX/UI","DevOps","Sci-Fi"
] AS gname
MERGE (:Genre {name:gname});

// ---------- USERS (10) ----------
UNWIND [
  {userId:"U001", name:"Mirele"},
  {userId:"U002", name:"Mauricio"},
  {userId:"U003", name:"Ana"},
  {userId:"U004", name:"Bruno"},
  {userId:"U005", name:"Clara"},
  {userId:"U006", name:"Diego"},
  {userId:"U007", name:"Ester"},
  {userId:"U008", name:"Felipe"},
  {userId:"U009", name:"Gabi"},
  {userId:"U010", name:"Hugo"}
] AS u
MERGE (usr:User {userId:u.userId})
SET usr.name = u.name;

// ---------- MOVIES (10) ----------
UNWIND [
  {movieId:"M001", title:"Debugging Tomorrow", year:2021, genres:["Programming","Sci-Fi"]},
  {movieId:"M002", title:"The Cloud Protocol", year:2020, genres:["Cloud","DevOps"]},
  {movieId:"M003", title:"Zero Trust", year:2019, genres:["Cybersecurity","AI"]},
  {movieId:"M004", title:"Model Drift", year:2022, genres:["AI","Data Science"]},
  {movieId:"M005", title:"Container Wars", year:2021, genres:["DevOps","Programming"]},
  {movieId:"M006", title:"Neural Nights", year:2018, genres:["AI","Sci-Fi"]},
  {movieId:"M007", title:"Graph of Lies", year:2023, genres:["Data Science","Cybersecurity"]},
  {movieId:"M008", title:"Blockchain Avenue", year:2017, genres:["Blockchain","Sci-Fi"]},
  {movieId:"M009", title:"Pixel Perfect", year:2016, genres:["UX/UI","Programming"]},
  {movieId:"M010", title:"Robot’s Dilemma", year:2015, genres:["Robotics","AI"]}
] AS m
MERGE (mv:Movie {movieId:m.movieId})
SET mv.title=m.title, mv.year=m.year
WITH mv, m
UNWIND m.genres AS gname
MATCH (g:Genre {name:gname})
MERGE (mv)-[:IN_GENRE]->(g);

// ---------- SERIES (10) ----------
UNWIND [
  {seriesId:"S001", title:"CI/CD Stories", startYear:2020, genres:["DevOps","Programming"]},
  {seriesId:"S002", title:"Threat Hunters", startYear:2019, genres:["Cybersecurity","Data Science"]},
  {seriesId:"S003", title:"AI Ops", startYear:2021, genres:["AI","DevOps"]},
  {seriesId:"S004", title:"Cloud Native", startYear:2018, genres:["Cloud","DevOps"]},
  {seriesId:"S005", title:"Code Review", startYear:2017, genres:["Programming","UX/UI"]},
  {seriesId:"S006", title:"Data Lake Chronicles", startYear:2022, genres:["Data Science","Cloud"]},
  {seriesId:"S007", title:"Robotics Lab", startYear:2016, genres:["Robotics","AI"]},
  {seriesId:"S008", title:"Blockchain Builders", startYear:2020, genres:["Blockchain","Programming"]},
  {seriesId:"S009", title:"UX Debug", startYear:2015, genres:["UX/UI","Programming"]},
  {seriesId:"S010", title:"Sci-Fi Stack", startYear:2014, genres:["Sci-Fi","AI"]}
] AS s
MERGE (sr:Series {seriesId:s.seriesId})
SET sr.title=s.title, sr.startYear=s.startYear
WITH sr, s
UNWIND s.genres AS gname
MATCH (g:Genre {name:gname})
MERGE (sr)-[:IN_GENRE]->(g);

// ---------- ACTORS (10) ----------
UNWIND [
  {actorId:"A001", name:"Nina Byte"},
  {actorId:"A002", name:"Carlos Kernel"},
  {actorId:"A003", name:"Lia Script"},
  {actorId:"A004", name:"Bruno Stack"},
  {actorId:"A005", name:"Ana Cloud"},
  {actorId:"A006", name:"Diego Cipher"},
  {actorId:"A007", name:"Ester Data"},
  {actorId:"A008", name:"Felipe Graph"},
  {actorId:"A009", name:"Gabi DevOps"},
  {actorId:"A010", name:"Hugo Neural"}
] AS a
MERGE (ac:Actor {actorId:a.actorId})
SET ac.name=a.name;

// ---------- DIRECTORS (10) ----------
UNWIND [
  {directorId:"D001", name:"Dr. Lin Code"},
  {directorId:"D002", name:"Marta Secure"},
  {directorId:"D003", name:"João Pipeline"},
  {directorId:"D004", name:"Sara Tensor"},
  {directorId:"D005", name:"Paulo Cloudman"},
  {directorId:"D006", name:"Renata Query"},
  {directorId:"D007", name:"Victor Graphson"},
  {directorId:"D008", name:"Camila Block"},
  {directorId:"D009", name:"Thiago UI"},
  {directorId:"D010", name:"Helena Robo"}
] AS d
MERGE (dr:Director {directorId:d.directorId})
SET dr.name=d.name;

// ---------- ACTED_IN (Actors -> Movies/Series) ----------
UNWIND [
  {a:"A001", t:"M001"}, {a:"A002", t:"M002"}, {a:"A003", t:"M003"}, {a:"A004", t:"M004"}, {a:"A005", t:"M005"},
  {a:"A006", t:"S001"}, {a:"A007", t:"S002"}, {a:"A008", t:"S003"}, {a:"A009", t:"S004"}, {a:"A010", t:"S005"},
  {a:"A001", t:"S010"}, {a:"A010", t:"M006"}
] AS row
MATCH (ac:Actor {actorId:row.a})
CALL {
  WITH row
  OPTIONAL MATCH (m:Movie {movieId:row.t}) RETURN m AS item
  UNION
  WITH row
  OPTIONAL MATCH (s:Series {seriesId:row.t}) RETURN s AS item
}
WITH ac, item
WHERE item IS NOT NULL
MERGE (ac)-[:ACTED_IN]->(item);

// ---------- DIRECTED (Directors -> Movies/Series) ----------
UNWIND [
  {d:"D001", t:"M001"}, {d:"D002", t:"M003"}, {d:"D003", t:"M005"}, {d:"D004", t:"M004"}, {d:"D005", t:"M002"},
  {d:"D006", t:"S001"}, {d:"D007", t:"S006"}, {d:"D008", t:"S008"}, {d:"D009", t:"S009"}, {d:"D010", t:"S007"},
  {d:"D004", t:"S003"}, {d:"D002", t:"M007"}
] AS row
MATCH (dr:Director {directorId:row.d})
CALL {
  WITH row
  OPTIONAL MATCH (m:Movie {movieId:row.t}) RETURN m AS item
  UNION
  WITH row
  OPTIONAL MATCH (s:Series {seriesId:row.t}) RETURN s AS item
}
WITH dr, item
WHERE item IS NOT NULL
MERGE (dr)-[:DIRECTED]->(item);

// ---------- WATCHED with rating (Users -> Movies/Series) ----------
UNWIND [
  {u:"U001", items:[{t:"M004", r:4.9},{t:"S003", r:4.6},{t:"M007", r:4.4}]},
  {u:"U002", items:[{t:"M003", r:4.8},{t:"S002", r:4.7},{t:"S004", r:4.2}]},
  {u:"U003", items:[{t:"M001", r:4.0},{t:"S005", r:4.1},{t:"M009", r:3.9}]},
  {u:"U004", items:[{t:"M002", r:5.0},{t:"S001", r:4.5},{t:"M005", r:4.3}]},
  {u:"U005", items:[{t:"S006", r:4.7},{t:"M006", r:4.2},{t:"S010", r:4.8}]},
  {u:"U006", items:[{t:"M008", r:4.1},{t:"S008", r:4.4},{t:"M010", r:4.0}]},
  {u:"U007", items:[{t:"M004", r:4.6},{t:"S007", r:4.3},{t:"M003", r:4.5}]},
  {u:"U008", items:[{t:"S009", r:4.0},{t:"M009", r:4.2},{t:"S002", r:4.6}]},
  {u:"U009", items:[{t:"M005", r:4.4},{t:"S004", r:4.1},{t:"M002", r:4.7}]},
  {u:"U010", items:[{t:"S010", r:4.9},{t:"M007", r:4.3},{t:"S003", r:4.8}]}
] AS row
MATCH (u:User {userId: row.u})
UNWIND row.items AS it
CALL {
  WITH it
  OPTIONAL MATCH (m:Movie {movieId: it.t}) RETURN m AS item
  UNION
  WITH it
  OPTIONAL MATCH (s:Series {seriesId: it.t}) RETURN s AS item
}
WITH u, it, item
WHERE item IS NOT NULL
MERGE (u)-[w:WATCHED]->(item)
SET w.rating = it.r;

