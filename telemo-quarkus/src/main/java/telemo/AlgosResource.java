package telemo;

import telemo.algos.Fibonacci;

import javax.ws.rs.*;

import static javax.ws.rs.core.MediaType.APPLICATION_JSON;

@Path("algos")
public class AlgosResource {

    @Path("fibo")
    @GET
    @Produces(APPLICATION_JSON)
    public long getFibo(@DefaultValue("42") @QueryParam("x") long x) {
        return Fibonacci.fibo(x);
    }
}
