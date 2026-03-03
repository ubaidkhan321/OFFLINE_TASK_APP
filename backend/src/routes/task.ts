import { Router } from "express";
import { auth, type AuthRequest } from "../middleware/auth_middleware.js";
import { task, users, type NewTask } from "../db/schema.js";
import { db } from "../db/index.js";
import { eq } from "drizzle-orm";
 const  taskRouter = Router();
 taskRouter.post("/",auth,async(req: AuthRequest,res)=>{
    try {
        req.body = {...req.body,dueAt : new Date(req.body.dueAt), uid: req.user};
        const newTask: NewTask = req.body;

        const [tasks] = await db.insert(task).values(newTask).returning();
        res.status(201).json(tasks);
    } catch (e) {
        console.log(e);
        res.status(500).json({error:e})
        
    }
 });

 taskRouter.get("/getTask/",auth,async(req : AuthRequest,res)=>{
try {
     const allTask = await db.select().from(task).where(eq(task.uid,req.user!));
 res.status(200).json(allTask);
} catch (error) {
    res.status(500).json(error);
}

 });

 taskRouter.delete("/deleteTask/",auth, async(req : AuthRequest,res)=>{
  try {
    const {taskId}: {taskId: string} = req.body;
  await db.delete(task).where(eq(task.id,taskId));
  res.json(true);
  } catch (error) {
    res.status(500).json(error);
  }
 });

 taskRouter.post('/SyncTask',auth, async(req: AuthRequest,res)=>{
    const sysnctask = req.body;
    console.log(sysnctask);
    const filtertedTask : NewTask [] = [];
    for(let t of sysnctask){
        t = {...t,dueAt: new Date(t.dueAt), createdAt: new Date(t.createdAt),updatedAt: new Date(t.updatedAt),uid:req.user},
        filtertedTask.push(t);
    }
    const  [pushedTasks] =  await db.insert(task).values(filtertedTask).onConflictDoNothing().returning();
    res.status(201).json(pushedTasks);
 });
 export default taskRouter;