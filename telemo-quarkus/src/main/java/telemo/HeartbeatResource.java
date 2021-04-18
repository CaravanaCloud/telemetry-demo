package telemo;

import static javax.ws.rs.core.MediaType.APPLICATION_JSON;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.transaction.Transactional;
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
    @Inject
    EntityManager em;

    @GET
    @Produces(APPLICATION_JSON)
    public Heartbeat get() {
        Heartbeat hb = Heartbeat.of();
        return hb;
    }

    @Path("all")
    @GET
    @Produces(APPLICATION_JSON)
    public List<Heartbeat> getAll(){
        List<Heartbeat> hbs = em
            .createQuery("SELECT hb FROM Heartbeat hb", Heartbeat.class)
            .getResultList();
        return hbs;
    }

    @POST
    @Consumes(APPLICATION_JSON)
    @Produces(APPLICATION_JSON)
    @Transactional
    public void put(Heartbeat hb,
                    @Context HttpRequest req) {
        hb.acceptTime = LocalDateTime.now();
        hb.sourceIP = req.getRemoteAddress();
        em.persist(hb);
        System.out.println(hb.toString());
    }
}