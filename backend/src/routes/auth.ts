import { Router, type Request, type Response } from "express";
import { db } from "../db/index.js";
import { users, type newUser } from "../db/schema.js";
import { eq } from "drizzle-orm";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, type AuthRequest } from "../middleware/auth_middleware.js";
import type { error } from "console";




const authRouter = Router();
 interface SignUpBody {
    name : string,
    email : string,
    password : string

 }
authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
  try {
    const { name, email, password } = req.body;

    const userExiting = await db
      .select()
      .from(users)
      .where(eq(users.email, email));

    if (userExiting.length > 0) {
      return res.status(400).json({
        error: "User already exists with this email",
      });
    }

    const hashPassword = await bcrypt.hash(password, 10);

    const addUser: newUser = {
      name,
      email,
      password: hashPassword,
    };

    const [user] = await db.insert(users).values(addUser).returning();

    return res.status(201).json(user);

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

interface LoginBody{
   email : string,
   password : string
}
authRouter.post("/Login", async (req : Request<{},{}, LoginBody>, res : Response) =>{
  try { 
    const  {email,password} = req.body;
     if(!email){
      return res.status(400).json({
        message : "Email Doesn't Exits"
      }); 
     }
      if(!password){
      return res.status(400).json({
        message : "Password Doesn't Exits"
      }); 
     }

    const [existingUser] = await db.select().from(users).where(eq(users.email , email));
      
    if(!existingUser){
      return res.status(400).json({
        message : "User Doesn't Exits from this Email"
      });      
    }
    
    const comparePassword = await bcrypt.compare(password,existingUser.password);
    if(!comparePassword){
      return res.status(401).json({
        message: "Password Doesn't Matched"
      });
    }
   const token =   jwt.sign({id:existingUser.id},"offLine");
   res.json({token , ...existingUser});
  } catch (error) {
    return res.status(500).json({ message: "Internal Server Error" });
  }
});

authRouter.post("/tokenisValid",async(req,res)=>{
  try {
    const token = req.header("x-auth-token");
    if(!token){
    return res.json(false);
    } 

    const verify = jwt.verify(token,"offLine");
    if(!verify){
      return res.json(false);
     

    }
     const verifiedToken = verify as {id:string};
      const [user] = await db.select().from(users).where(eq(users.id,verifiedToken.id))
      if (!user) return res.json(false);
        res.json(true)

    
  } catch (error) {
    return res.status(500).json(false);
  }
});


authRouter.get("/",auth, async(req: AuthRequest, res)=>{
    try {
      if(!req.user){
       return res.status(401).json({error:"User not found"})
      }

      const [user] = await db.select().from(users).where(eq(users.id,req.user));
      res.json({...user,token:req.token})
    } catch (error) {
      
    }
});

export default authRouter;
