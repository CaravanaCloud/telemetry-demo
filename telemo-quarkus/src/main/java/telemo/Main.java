package telemo;

import io.quarkus.runtime.annotations.QuarkusMain;
import io.quarkus.runtime.Quarkus;
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

@QuarkusMain
@ApplicationPath("/api")
public class Main extends Application {

    public static void main(String ... args) {
        System.out.println("Running main method");
        Quarkus.run(args);
    }
}

