package telemo;

import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.persistence.EntityManager;

@ApplicationScoped
public class HeartbeatService {
    @Inject
    EntityManager em;

    public List<Heartbeat> findAll() {
        return em
            .createNamedQuery("Heartbeat.findAll", Heartbeat.class)
            .getResultList();
    }

    public void persist(Heartbeat hb) {
        em.persist(hb);
    }

    public Heartbeat merge(Heartbeat hb){
        return em.merge(hb);
    }


}
