// Create 2 nodes labeled as 'User' (r, m) with a relationship
CREATE (r:User { name: "Rachel", city: "London" }),
       (m:User { name: "Monica", city: "New York" }),
       (r)-[f:FRIEND {acceptedAt:"2021-10-05"}]-> (m)
RETURN r,f,m

// Solution to Your Turn (1)
CREATE (ph:User { name: "Phoebe", lastname: "Buffay", city: "Newark", gender: "female" }),
       (j:User { name: "Joey", lastname: "Tribbiani", city: "Arkansas", dob: "1988-01-01" }),
       (ph)-[f:FRIEND { acceptedAt: "2021-10-15"}]->(j)
RETURN ph, f, j; 

//Create more friendships
MATCH (r:User), (m:User),(ph:User),(j:User)
WHERE r.name="Rachel" AND m.name="Monica" AND p.name = "Phoebe" AND j.name="Joey"
CREATE (ph)-[f:FRIEND {acceptedAt: date() }]-> (m),
(j)-[f:FRIEND {acceptedAt: date() }]-> (r)
RETURN r,m,ph,j;

//Create a post , a comment and a reaction.
MATCH (r:User), (m:User)
WHERE r.name="Rachel" AND m.name="Monica"
CREATE (p:Post { id:"9", message: "This is a message." } ),
       (r)-[:POSTED]->(p),
       (m)-[:REACTED { type: "Love", createdAt: date() }]->(p),
       (m)-[:COMMENTED { message: "Yay!", createdAt: date() }]->(p)
RETURN r,m,p;

// Solution to Your Turn (2)  datetime() returns the current date and time
MATCH (m:User), (ph:User), (j:User)
WHERE m.name="Monica" AND ph.name="Phoebe" AND j.name="Joey"
CREATE (p10:Post { id:"10", message: "Hi, I'm Monica" } ),
       (p11:Post { id:"11", message: "Hi, I'm Phoebe" } ),
       (p12:Post { id:"12", message: "Hi, I'm Joey" } ),
       (m)-[:POSTED]->(p10),
       (ph)-[:POSTED]->(p11),
       (j)-[:POSTED]->(p12),
       (p10)<-[:REACTED { type: "Haha", createdAt: datetime() } ]-(ph),
       (p11)<-[:REACTED { type: "Care", createdAt: datetime() } ]-(j),
       (p12)<-[:REACTED { type: "Love", createdAt: datetime() } ]-(m),
       (j)-[:COMMENTED { message: "Ack", createdAt: date() }]->(p10),
       (m)-[:COMMENTED { message: "Nck", createdAt: date() }]->(p11),
       (ph)-[:COMMENTED { message: "Sure", createdAt: date() }]->(p12)
RETURN m,ph,j,p10,p11,p12;


// Query (Pattern Matching)
// 2.1 (1) Find immediate friends
MATCH (u:User)-[:FRIEND]->(f)
WHERE u.name = "Phoebe"
RETURN u,f;

// 2.1 (2) Find friends of friends
MATCH (u:User)-[:FRIEND*]->(f)
WHERE u.name = "Phoebe"
RETURN u,f;


//2.2 Make Recommendations
//Rachel is planning to go to Newark  for a business trip, so she is looking for her friends who know someone living that city. 
MATCH (r:User)-[:FRIEND]->()-[:FRIEND]-(newarkian)
WHERE r.name="Rachel" AND newarkian.city="Newark"
RETURN DISTINCT newarkian;


//Add more friends
MATCH (j:User)
WHERE j.name="Joey"
CREATE (b:User { name: "Brandon", city:"Texas", gender:"male"} ),
    (j)-[:FRIEND]->(b)
RETURN j,b;

// Your Turn (3)
//Find who reacted all Monica’s post.
MATCH (n:User)-[:REACTED]->(p:Post)<[:POSTED]-(m:User)
WHERE m.name="Monica"
RETURN n;

//Modify the above command to find all friends of the reactor of Monica’s post. 
MATCH (r:User)<-[:FRIEND]-(n:User)-[:REACTED]->(p:Post)<[:POSTED]-(m:User)
WHERE m.name="Monica"
RETURN r;

//Aggregation
//Ex5-1 Find total, average, minimum and maximum age of all users
MATCH (u:User) WHERE exists(u.age)
RETURN sum(u.age), max(u.age), min(u.age), avg(u.age);

//Ex5-2 Find Total, Average, Minimum, Maximum age of all people grouped by  users’ gender.
MATCH (u:User) WHERE exists(u.age)
RETURN u.gender, sum(u.age), max(u.age), min(u.age), avg(u.age);

//Ex6 Find total number of users
// Without a grouping key
MATCH (u:User) RETURN count(u);

// With a grouping key (user's city)
MATCH (u:User) RETURN u.city, count(u);

//EX.7  Find Total number of persons who have pet
MATCH (u:User) WHERE u.age >=60  
RETURN u.city AS City, 
u.gender AS gender, 
count(u) AS NoOfUsers;

//EX.8  Enumerate all cities of users
MATCH (u:User) 
RETURN collect(u.city), collect(DISTINCT u.city);

// Your Turn (4)
// Count  all posts grouped by each user.
MATCH(u:User)-[:POSTED]->(p:Post)
RETURN u.name AS Name, count(p) AS NoOfPosts;

//List all friends’ name of each user.  Show friends names in the same column. 
MATCH (u:User)-[:FRIEND]->(m:User)
RETURN u.name, collect(m.name);

//UPDATE
//Ex9 Set a lastname and age of 34 for Rachel.
MATCH (r:User)
SET r.lastname = "Berry", r.age=34
RETURN r.name, r.lastname, r.age;

//EX.10  Remove Rachel’s age.
MATCH (r:User {name:"Rachel"})
SET r.age = NULL
RETURN r;

//EX.11 Update Monica’s age and workplace  using += 
MATCH (m:User { name: "Monica" })
SET m += { age: 39, workplace: "World Bank" }
RETURN m.name, m.age, m.workplace;

//EX.12 Update Phoebe’s reaction on the Monica’s post by changing the reaction type to ‘Love’ and recording a current date-time. 
MATCH (:User { name : "Phoebe"})-[re:REACTED]->(p:Post)<-[:POSTED]-(:User { name : "Monica" })
SET re.type="Love", re.createdAt=datetime()
RETURN re;

//EX.13 Update Label for Johan to be Parent and Employee
MATCH (j {name:"Joey"})
SET j:User:Member
RETURN j;

// EX.14 Delete Kim’s node
MATCH (k {name: 'Kim'})
DETACH DELETE k;

// EX.15 Undo a reaction of Monica on a Joey’s post.
MATCH (m{name: 'Monica'})-[re:REACTED]->(p)<-[:POSTED]-(j{name:'Joey'})
DELETE re;

