/**
 * @name Use of insufficient randomness as the key of a cryptographic algorithm
 * @description Using insufficient randomness as the key of a cryptographic algorithm can allow an attacker to compromise security.
 * @kind problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @id go/insecure-randomness
 * @tags security
 *       external/cwe/cwe-338
 */

 import go
//  import semmle.go.security.InsecureRandomness::InsecureRandomness
//  import semmle.go.security.InsecureRandomnessCustomizations
//  import DataFlow::PathGraph
import InsecureCrypto::InsecureCrypto

 
 from InsecureCrypto cfg, DataFlow::Node source, DataFlow::Node sink, string call
 where
   cfg.hasFlow(source, sink) and
   call = sink.(AllSink).getCall()
  //  exists(DataFlow::CallNode n | )

  //  and fileIsCoreMember(source.getNode().getFile())
  select source as sourceNode, 
  source.asExpr().getLocation().toString() as sourceLoc,
  sink as sinkNode, 
  sink.asExpr().getLocation().toString() as sinkLoc
 