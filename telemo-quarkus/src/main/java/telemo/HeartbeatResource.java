package telemo;

import static javax.ws.rs.core.MediaType.APPLICATION_JSON;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
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
    private static final Logger log = Logger.getLogger(HeartbeatResource.class.getName());

    @Inject
    HeartbeatService heartbeatSvc;

    @GET
    @Produces(APPLICATION_JSON)
    public Heartbeat get() {
        return Heartbeat.of();
    }

    @Path("all")
    @GET
    @Produces(APPLICATION_JSON)
    public List<Heartbeat> getAll(){
        return findAll();
    }

    @Path("stats")
    @GET
    @Produces(APPLICATION_JSON)
    public Map<String,String> getStats(){
        var stats = new HashMap<String,String>();
        var hbs = findAll();
        var count_heartbeats = hbs.size();
        var count_sources = hbs.stream()
                               .map(hb -> hb.getSourceIP())
                               .distinct()
                               .count();
        hbs.sort(Comparator.comparing(Heartbeat::getBatteryLevel));
        var min_battery = "";
        if(!hbs.isEmpty()){
            var min = hbs.get(0);
            var min_sourceUUID = min.getSourceUUID();
            var min_level = min.batteryLevel;
            min_battery = min_sourceUUID + " " + min_level + "%";
        }

        stats.put("count_heartbeats",""+count_heartbeats);
        stats.put("count_sources",""+count_sources);
        stats.put("min_battery",""+min_battery);
        return stats;
    }


    @POST
    @Consumes(APPLICATION_JSON)
    @Produces(APPLICATION_JSON)
    @Transactional
    public void put(Heartbeat hb,
                    @Context HttpRequest req) {
        hb.acceptTime = LocalDateTime.now();
        hb.sourceIP = req.getRemoteAddress();
        heartbeatSvc.persist(hb);
        log.fine(hb.toString());
    }

    private List<Heartbeat> findAll() {
        return heartbeatSvc.findAll();
    }
}