package telemo;

import static javax.ws.rs.core.MediaType.APPLICATION_JSON;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import org.jboss.resteasy.spi.HttpRequest;

@Path("/hb")
public class HeartbeatResource {
    static final List<Heartbeat> hbs = new ArrayList<>();

    @GET
    @Produces(APPLICATION_JSON)
    public Heartbeat get() {
        Heartbeat hb = Heartbeat.of();
        hbs.add(hb);
        return hb;
    }

    @Path("all")
    @GET
    @Produces(APPLICATION_JSON)
    public List<Heartbeat> getAll(){
        return hbs;
    }

    @POST
    @Consumes(APPLICATION_JSON)
    @Produces(APPLICATION_JSON)
    public void put(Heartbeat hb,
                    @Context HttpRequest req) {
        hb.acceptTime = LocalDateTime.now();
        hb.sourceIP = req.getRemoteAddress();
        System.out.println(hb.toString());
        hbs.add(hb);
    }
}