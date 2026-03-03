import express, { type NextFunction,type Response,type Request } from "express";
import type { UUID } from "crypto";
import jwt from "jsonwebtoken";
import { db } from "../db/index.js";
import { users } from "../db/schema.js";
import { eq } from "drizzle-orm";
export interface AuthRequest extends Request{
    user?: UUID;
    token? : string
    
}
export const auth = async(req: AuthRequest,res: Response,next: NextFunction )=>{
try{
    const token = req.header("x-auth-token");
    if(!token){
       return res.status(401).json({
            error: "Token Can't be Empty"
        });
    }
   const verifyjwt = jwt.verify(token,"offLine");
   if(!verifyjwt){
    return res.status(401).json({error: "Token is not Valid"});
   }

   const verifyId = verifyjwt as {id:UUID}
   const [user] = await db.select().from(users).where(eq(users.id, verifyId.id));
   if(!user){
    return res.status(401).json({error: "User Not Found"});

   }
   req.user = verifyId.id;
   req.token = token;
   next();    
}catch(error){
   return res.status(500).json({error: error});
}

} 