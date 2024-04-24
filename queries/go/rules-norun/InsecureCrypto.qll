import go

module InsecureCrypto {
  import CryptoCustom
  import utils
  
    abstract class Source extends DataFlow::Node { }

    /**
     * A data flow sink for cryptographic algorithms that take a key as input
     */
    abstract class Sink extends DataFlow::Node {
      /** Gets a string describing the kind of sink this is. */
      abstract string getKind();
    }
   
    /**
     * A sanitizer for insufficient random sources used as cryptographic keys
     */
    abstract class Sanitizer extends DataFlow::Node { }
   
    string nonCryptoInterface() { result = ["io.Writer", "io.Reader", "sync.Mutex", "net.Listener"] }
   
    class Configuration extends TaintTracking::Configuration {
     Configuration() { this = "InsecureRandomness" }
   
     override predicate isSource(DataFlow::Node source) { source instanceof Source }
   
     override predicate isSink(DataFlow::Node sink) { this.isSinkWithKind(sink, _) }
   
     /** Holds if `sink` is a sink for this configuration with kind `kind`. */
     predicate isSinkWithKind(Sink sink, string kind) { kind = sink.getKind() }
   
     override predicate isSanitizer(DataFlow::Node node) { node instanceof Sanitizer }
   }
   
    class InsecureCrypto extends Configuration { 
    
    }

    predicate isSinkType(string s){
      s = any(AllSink snk).getType().pp()
    }
    
    class AllSource extends Source {
       AllSource(){ exists(Function fn, Package p, string name, string pkg |
          fn.hasQualifiedName(pkg, name) and pkg.regexpMatch("math/rand") |
          this = fn.getACall().getAnArgument()
       and fileIsCoreMember(this.getFile()))}
    }
   
    class AllSink extends Sink{
     string caller;
     AllSink(){exists(Function fn, Package p, string name, string pkg |
         p instanceof CryptoCustom::CryptoPackages
         and fn.hasQualifiedName(pkg, name) 
         and (pkg = p.getPath() or pkg.regexpMatch("(crypto|golang.org/x/crypto)/.*"))
       |
         not (p.getPath() = "crypto/rand" and name = "Read")
         // `crypto/cipher` APIs for reading/writing encrypted streams
         and not (p.getPath() = "crypto/cipher" and name = ["Read", "Write"]) 
         // Some interfaces in the `crypto` package are the same as interfaces
         // elsewhere, e.g. tls.listener is the same as net.Listener
         and not fn.hasQualifiedName(nonCryptoInterface(), _)
         and exists(DataFlow::CallNode call | call.getTarget() = fn and this = call.getAnArgument() and caller = call.getTarget().getName())
       )}
   
       override string getKind(){
         result = "Placeholder"
       }
       string getCall(){
         result = caller
       }
    }
}