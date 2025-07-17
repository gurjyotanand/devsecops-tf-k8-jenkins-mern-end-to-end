// Corrected connection.js
import { MongoClient, ServerApiVersion } from "mongodb";

// 1. Read the connection string from the environment variable.
const URI = process.env.DATABASE_URL;

// 2. Add a check to ensure the variable is set. If not, the app will crash loudly.
if (!URI) {
  console.error("FATAL ERROR: DATABASE_URL environment variable is not set.");
  process.exit(1); // Exit the process with an error code
}

const client = new MongoClient(URI, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  },
});

let db;

try {
  // Connect the client to the server
  await client.connect();
  // Send a ping to confirm a successful connection
  await client.db("admin").command({ ping: 1 });
  console.log("Pinged your deployment. You successfully connected to MongoDB!");
  db = client.db("employees"); // Or your desired database name
} catch (err) {
  // If connection fails, log the error and exit.
  console.error("Failed to connect to MongoDB", err);
  process.exit(1);
}

// Export the connected database object.
export default db;
