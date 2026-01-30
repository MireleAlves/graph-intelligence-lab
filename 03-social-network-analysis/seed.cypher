// ---- Users (12) ----
UNWIND [
  {userId:"U1", name:"Mirele"},
  {userId:"U2", name:"Mauricio"},
  {userId:"U3", name:"Ana"},
  {userId:"U4", name:"Bruno"},
  {userId:"U5", name:"Clara"},
  {userId:"U6", name:"Diego"},
  {userId:"U7", name:"Ester"},
  {userId:"U8", name:"Felipe"},
  {userId:"U9", name:"Gabi"},
  {userId:"U10", name:"Hugo"},
  {userId:"U11", name:"Iris"},
  {userId:"U12", name:"Joao"}
] AS u
MERGE (usr:User {userId:u.userId})
SET usr.name = u.name;

// ---- Topics (8) ----
UNWIND ["AI","Neo4j","DevOps","Cybersecurity","Data","UX","Startups","Education"] AS t
MERGE (:Topic {name:t});

// ---- Follows (rede com clusters) ----
UNWIND [
  ["U1","U2"],["U1","U3"],["U1","U5"],["U2","U4"],["U2","U6"],["U3","U5"],
  ["U4","U1"],["U4","U2"],["U5","U7"],["U6","U4"],["U6","U8"],["U7","U9"],
  ["U8","U10"],["U9","U10"],["U10","U1"],["U11","U1"],["U11","U3"],["U12","U2"]
] AS pair
MATCH (a:User {userId: pair[0]}), (b:User {userId: pair[1]})
MERGE (a)-[:FOLLOWS]->(b);

// ---- Posts (15) ----
UNWIND [
  {postId:"P001", by:"U1", content:"Explorando grafos para recomendação.", topics:["Neo4j","AI"], createdAt: datetime()},
  {postId:"P002", by:"U2", content:"Pipeline CI/CD e boas práticas.", topics:["DevOps"], createdAt: datetime()},
  {postId:"P003", by:"U3", content:"Dicas de Cypher para iniciantes.", topics:["Neo4j","Education"], createdAt: datetime()},
  {postId:"P004", by:"U4", content:"Segurança em aplicações modernas.", topics:["Cybersecurity"], createdAt: datetime()},
  {postId:"P005", by:"U5", content:"IA aplicada a processos corporativos.", topics:["AI","Startups"], createdAt: datetime()},
  {postId:"P006", by:"U6", content:"Dados, métricas e tomada de decisão.", topics:["Data"], createdAt: datetime()},
  {postId:"P007", by:"U7", content:"UX que melhora retenção.", topics:["UX"], createdAt: datetime()},
  {postId:"P008", by:"U8", content:"Como organizar estudos em tecnologia.", topics:["Education"], createdAt: datetime()},
  {postId:"P009", by:"U9", content:"Boas práticas de segurança para times.", topics:["Cybersecurity","DevOps"], createdAt: datetime()},
  {postId:"P010", by:"U10", content:"Grafos e comunidades de interesse.", topics:["Neo4j","Data"], createdAt: datetime()},
  {postId:"P011", by:"U11", content:"Estratégia para startups de dados.", topics:["Startups","Data"], createdAt: datetime()},
  {postId:"P012", by:"U12", content:"AI + Neo4j em casos reais.", topics:["AI","Neo4j"], createdAt: datetime()},
  {postId:"P013", by:"U1", content:"Como medir engajamento com grafos.", topics:["Data","Neo4j"], createdAt: datetime()},
  {postId:"P014", by:"U5", content:"Comunidades e recomendação.", topics:["Startups","AI"], createdAt: datetime()},
  {postId:"P015", by:"U3", content:"Cypher: padrões de match úteis.", topics:["Neo4j"], createdAt: datetime()}
] AS p
MATCH (u:User {userId:p.by})
MERGE (post:Post {postId:p.postId})
SET post.content = p.content,
    post.createdAt = p.createdAt
MERGE (u)-[:POSTED]->(post)
WITH post, p
UNWIND p.topics AS topicName
MATCH (t:Topic {name: topicName})
MERGE (post)-[:TAGGED_WITH]->(t);

// ---- Likes (random but consistent) ----
MATCH (u:User), (p:Post)
WITH u, p
WHERE rand() < 0.08
MERGE (u)-[l:LIKED]->(p)
SET l.at = datetime();

// ---- Comments (random sample) ----
MATCH (u:User), (p:Post)
WITH u, p
WHERE rand() < 0.03
MERGE (u)-[c:COMMENTED]->(p)
SET c.at = datetime(),
    c.text = "Comentário de " + u.userId;
