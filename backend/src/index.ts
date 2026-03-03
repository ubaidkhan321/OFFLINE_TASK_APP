import express from "express";
import authRouter from "./routes/auth.js";
import taskRouter from "./routes/task.js";
 const app = express();
app.use(express.json())
 app.use("/auth",authRouter)
 app.use("/task",taskRouter)

 app.get("/",(req,res)=>{
    res.send("Welcome my first app")
 })
 app.listen(8000,"0.0.0.0",()=>{
    console.log("Server started on port 8000")
 });