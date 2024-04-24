import cpp
import CryptoCustom

/**
 * @name A3_InsecureSymmetric
 * @id a3-cpp
 * @kind problem
 * @problem.severity warning
 */


/*
* Defines Insecure Asymmetric Calls (See Paper) and provides some helper functions for the query
*/

class InsecureAsymmetricCall extends FunctionCall {

    Expr arg;
    InsecureAsymmetricCall(){
        getAnArgument() = arg 
        and 
        (
        (arg.getValue().toInt() < 2048/8 and arg.getValue().toInt() % 8 = 0 and arg.getValue().toInt() != 0)
        or
        arg.getValue().toInt() = [192/8, 224/8, 233/8]
        )
        and
        getTarget().getADeclaration().getFile() instanceof CryptoHeaders
    }

    Expr getArg(){
        result = arg
    }

    int getArgIntValue(){
        result = arg.getValue().toInt()
    }


}





from InsecureAsymmetricCall c
select c as finding, 
"Arg: " + c.getArg().toString() +" Value: " + c.getArgIntValue().toString(),
c.getLocation().toString() as location,
"Location"